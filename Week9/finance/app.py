import os

from cs50 import SQL
from flask import Flask, flash, redirect, render_template, request, session
from flask_session import Session
from werkzeug.security import check_password_hash, generate_password_hash

from helpers import apology, login_required, lookup, usd
import datetime

# Configure application
app = Flask(__name__)

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/")
@login_required
def index():
    """Show portfolio of stocks"""
    # Update
    boughts = db.execute(
        "SELECT symbol, price, SUM(shares), SUM(amount) FROM history WHERE id=? GROUP BY symbol HAVING SUM(shares) > 0", session["user_id"])
    cash = db.execute("SELECT cash FROM users WHERE id=?", session["user_id"])[0]["cash"]
    return render_template("index.html", boughts=boughts, cash=cash)


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    """Buy shares of stock"""

    if request.method == "GET":
        return render_template("buy.html")

    elif request.method == "POST":

        # get the input data
        symbol = request.form.get("symbol")
        try:
            shares = request.form.get("shares")
            if shares.isdigit():
                shares = int(shares)
            else:
                return apology("Input a valid number!")

        except ValueError:
            return apology("Input a valid number!")

        results = lookup(symbol)

        # check the data exists
        if results is None:
            return apology("The symbol does not exist.")
        elif shares <= 0:
            return apology("Please input a positive number in shares!")

        # calculate total cost from buying stock
        price = results["price"]
        total_cost = price * shares
        user_assets = float(db.execute("SELECT cash FROM users where id=?",
                            session["user_id"])[0]["cash"])
        if user_assets < total_cost:
            return apology("You can\'t affort it!")

        # insert transaction record
        db.execute("INSERT INTO history (id, symbol, price, shares, amount, transacted) VALUES (?, ?, ?, ?, ?, ?)",
                   session["user_id"], symbol, price, shares, price * shares, datetime.datetime.now())
        # deduct the transaction amount from the property
        db.execute("UPDATE users SET cash=? WHERE id=?", user_assets-total_cost, session["user_id"])

        return redirect("/")


@app.route("/history")
@login_required
def history():
    """Show history of transactions"""
    historys = db.execute(
        "SELECT symbol, shares, price, transacted FROM history WHERE id=?", session["user_id"])
    return render_template("history.html", historys=historys)


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":
        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute(
            "SELECT * FROM users WHERE username = ?", request.form.get("username")
        )

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(
            rows[0]["hash"], request.form.get("password")
        ):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():
    """Get stock quote."""

    # return apology("TODO")
    if request.method == "GET":
        return render_template("quote.html")

    elif request.method == "POST":
        symbol = request.form.get("symbol")
        results = lookup(symbol)
        if results is not None:
            return render_template("quoted.html", results=results)
        else:
            return apology("Invalid ticker symbol!")


@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""
    if request.method == "GET":
        return render_template("register.html")

    elif request.method == "POST":

        # Check filled with the form
        if not request.form.get("username"):
            return apology("Empty username!")
        elif not request.form.get("password"):
            return apology("Empty password!")
        elif not request.form.get("confirmation"):
            return apology("Empty confirmation!")

        # try to get the inquire in the database, if no result, raise ValueError
        try:
            username = request.form.get("username")
            password = request.form.get("password")
            confirmation = request.form.get("confirmation")

            if password != confirmation:
                return apology("Password not equals to confirmation")

            db.execute("INSERT INTO users (username, hash) VALUES (?, ?)",
                       username, generate_password_hash(password))

        except ValueError:
            return apology("Account had existed")

        return redirect("/")


@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():
    """Sell shares of stock"""

    if request.method == "GET":
        # query user data.
        results = db.execute(
            "SELECT symbol, SUM(shares) FROM history WHERE id=? GROUP BY symbol HAVING SUM(shares) > 0", session["user_id"])
        return render_template("sell.html", results=results)
    elif request.method == "POST":
        # user input
        symbol = request.form.get("symbol")
        symbol_info = lookup(symbol)

        try:
            sell_number = request.form.get("shares")

            # check for non-numeric
            if sell_number.isdigit():
                sell_number = int(sell_number)
            else:
                return apology("Input a valid number!")

            # check for negative
            if sell_number <= 0:
                return apology("Input a valid number!")
        except ValueError:
            return apology("Input a valid number!")

        # check for data correction
        if not symbol_info:
            return apology("Symbol doesn\'t exists")

        # extract user data
        user_own = db.execute(
            "SELECT symbol, SUM(shares) FROM history WHERE id=? AND symbol=? GROUP BY symbol", session["user_id"], symbol)[0]
        user_own_shares = int(user_own["SUM(shares)"])
        user_assets = float(db.execute("SELECT cash FROM users where id=?",
                            session["user_id"])[0]["cash"])

        # check for own enough shares
        if user_own_shares < sell_number:
            return apology("You don\'t own enough shares!")

        price = float(symbol_info["price"])

        # update history
        db.execute("INSERT INTO history (id, symbol, price, shares, amount, transacted) VALUES (?, ?, ?, ?, ?, ?)",
                   session["user_id"], symbol, price, -sell_number, price * -sell_number, datetime.datetime.now())

        # update user asset
        db.execute("UPDATE users SET cash=? WHERE id=?",
                   user_assets+price*sell_number, session["user_id"])

        return redirect("/")
