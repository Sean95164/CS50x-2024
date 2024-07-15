-- Keep a log of any SQL queries you execute as you solve the mystery.

-- initial clues
-- The theft took place on July 28, 2023 and that it took place on Humphrey Street.

/* all tables
airports              crime_scene_reports   people
atm_transactions      flights               phone_calls
bakery_security_logs  interviews
bank_accounts         passengers
*/

-- Find crime description
SELECT description FROM crime_scene_reports
WHERE month = 7 AND day = 28 AND year = 2023
AND street = "Humphrey Street";


/*
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|                                                                                                       description                                                                                                        |
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery. Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery. |
| Littering took place at 16:36. No known witnesses.                                                                                                                                                                       |
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
*/

SELECT * FROM interviews
WHERE year = 2023 AND month = 7 AND day = 28;

/*
+-----+---------+------+-------+-----+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| id  |  name   | year | month | day |                                                                                                                                                     transcript                                                                                                                                                      |
+-----+---------+------+-------+-----+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 158 | Jose    | 2023 | 7     | 28  | “Ah,” said he, “I forgot that I had not seen you for some weeks. It is a little souvenir from the King of Bohemia in return for my assistance in the case of the Irene Adler papers.”                                                                                                                               |
| 159 | Eugene  | 2023 | 7     | 28  | “I suppose,” said Holmes, “that when Mr. Windibank came back from France he was very annoyed at your having gone to the ball.”                                                                                                                                                                                      |
| 160 | Barbara | 2023 | 7     | 28  | “You had my note?” he asked with a deep harsh voice and a strongly marked German accent. “I told you that I would call.” He looked from one to the other of us, as if uncertain which to address.                                                                                                                   |
| 161 | Ruth    | 2023 | 7     | 28  | *this* --> Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.                                                          |
| 162 | Eugene  | 2023 | 7     | 28  | *this* --> I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.                                                                                                 |
| 163 | Raymond | 2023 | 7     | 28  | *this* --> As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket. |
| 191 | Lily    | 2023 | 7     | 28  | Our neighboring courthouse has a very annoying rooster that crows loudly at 6am every day. My sons Robert and Patrick took the rooster to a city far, far away, so it may never bother us again. My sons have successfully arrived in Paris.                                                                        |
+-----+---------+------+-------+-----+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
*/

-- Sometime within ten minutes of the theft, the thief get into a car in the bakery parking lot and drive away.
-- ATM on Leggett Street, saw the thief there withdrawing some money
-- called someone who talked to them for less than a minute
-- they were planning to take the earliest flight out of Fiftyville tomorrow

SELECT * FROM people
WHERE license_plate IN (
    SELECT license_plate FROM bakery_security_logs
    WHERE activity = "exit" AND year = 2023 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 60
)
AND phone_number IN (
    SELECT caller FROM phone_calls
    WHERE year = 2023 AND month = 7 AND day = 28 AND duration < 60
)
AND people.id IN (
    SELECT person_id FROM bank_accounts
    WHERE bank_accounts.account_number IN (
        SELECT account_number
        FROM atm_transactions
        WHERE year = 2023 AND month = 7 AND day = 28 AND transaction_type = "withdraw" AND atm_location = "Leggett Street"
    )
);

/* There are three suspects
+--------+--------+----------------+-----------------+---------------+
|   id   |  name  |  phone_number  | passport_number | license_plate |
+--------+--------+----------------+-----------------+---------------+
| 449774 | Taylor | (286) 555-6063 | 1988161715      | 1106N58       |
| 514354 | Diana  | (770) 555-1861 | 3592750733      | 322W7JE       |
| 686048 | Bruce  | (367) 555-5533 | 5773159633      | 94KL13X       |
+--------+--------+----------------+-----------------+---------------+
*/

-- Check who they called for
SELECT * FROM people
WHERE phone_number IN (
    SELECT receiver FROM phone_calls
    WHERE year = 2023 AND month = 7 AND day = 28 AND duration < 60 AND caller IN ("(286) 555-6063", "(770) 555-1861", "(367) 555-5533")
);

/* 3 people might be accomlices
+--------+--------+----------------+-----------------+---------------+
|   id   |  name  |  phone_number  | passport_number | license_plate |
+--------+--------+----------------+-----------------+---------------+
| 250277 | James  | (676) 555-6554 | 2438825627      | Q13SVG6       |
| 847116 | Philip | (725) 555-3243 | 3391710505      | GW362R6       |
| 864400 | Robin  | (375) 555-8161 | NULL            | 4V16VO0       |
+--------+--------+----------------+-----------------+---------------+
*/

SELECT * FROM phone_calls
WHERE year = 2023 AND month = 7 AND day = 28 AND duration < 60
AND caller IN ("(286) 555-6063", "(770) 555-1861", "(367) 555-5533")
AND receiver IN ("(676) 555-6554", "(725) 555-3243", "(375) 555-8161");

/*
+-----+----------------+----------------+------+-------+-----+----------+
| id  |     caller     |    receiver    | year | month | day | duration |
+-----+----------------+----------------+------+-------+-----+----------+
| 233 | (367) 555-5533 | (375) 555-8161 | 2023 | 7     | 28  | 45       |  Bruce -> Robin
| 254 | (286) 555-6063 | (676) 555-6554 | 2023 | 7     | 28  | 43       |  Taylor -> James
| 255 | (770) 555-1861 | (725) 555-3243 | 2023 | 7     | 28  | 49       |  Diana -> Philip
+-----+----------------+----------------+------+-------+-----+----------+
*/

SELECT * FROM flights
JOIN airports ON airports.id = flights.origin_airport_id
WHERE flights.year = 2023 AND flights.month = 7 AND flights.day = 29
AND flights.hour BETWEEN 0 AND 12 AND airports.city = "Fiftyville"
ORDER BY flights.hour, flights.minute;

/*
+----+-------------------+------------------------+------+-------+-----+------+--------+----+--------------+-----------------------------+------------+
| id | origin_airport_id | destination_airport_id | year | month | day | hour | minute | id | abbreviation |          full_name          |    city    |
+----+-------------------+------------------------+------+-------+-----+------+--------+----+--------------+-----------------------------+------------+
| 36 | 8                 | 4                      | 2023 | 7     | 29  | 8    | 20     | 8  | CSF          | Fiftyville Regional Airport | Fiftyville |
| 43 | 8                 | 1                      | 2023 | 7     | 29  | 9    | 30     | 8  | CSF          | Fiftyville Regional Airport | Fiftyville |
| 23 | 8                 | 11                     | 2023 | 7     | 29  | 12   | 15     | 8  | CSF          | Fiftyville Regional Airport | Fiftyville |
+----+-------------------+------------------------+------+-------+-----+------+--------+----+--------------+-----------------------------+------------+
*/

SELECT full_name, city FROM airports
WHERE id IN (1, 4, 11);

/*
+-------------------------------------+---------------+
|              full_name              |     city      |
+-------------------------------------+---------------+
| O'Hare International Airport        | Chicago       |
| LaGuardia Airport                   | New York City |
| San Francisco International Airport | San Francisco |
+-------------------------------------+---------------+
*/

SELECT name, passport_number FROM people
WHERE people.name IN ("Bruce", "Taylor", "Diana", "James", "Philip", "Robin")
AND passport_number IN (
    SELECT passport_number FROM passengers
    JOIN flights ON flights.id = passengers.flight_id
    JOIN airports ON airports.id = flights.origin_airport_id
    WHERE flights.year = 2023 AND flights.month = 7 AND flights.day = 29 AND flights.hour BETWEEN 0 AND 12
    AND flights.origin_airport_id IN (
        SELECT airports.id FROM airports
        WHERE airports.city = "Fiftyville"
    )
    AND flights.destination_airport_id IN (
        SELECT airports.id FROM airports
        WHERE airports.city IN ("New York City", "Chicago", "San Francisco")
    )
);


/* Find two suspects
+--------+-----------------+
|  name  | passport_number |
+--------+-----------------+
| Taylor | 1988161715      |
| Bruce  | 5773159633      |
+--------+-----------------+
*/

SELECT full_name, city, passport_number, flights.destination_airport_id, flights.hour, flights.minute FROM airports
JOIN flights ON flights.origin_airport_id = airports.id
JOIN passengers ON passengers.flight_id = flights.id
WHERE flights.year = 2023 AND flights.month = 7 AND flights.day = 29 AND hour BETWEEN 0 AND 12
AND passengers.passport_number IN (
    SELECT passport_number FROM people
    WHERE people.name IN ("Bruce", "Taylor", "Diana", "James", "Philip", "Robin")
);


/*
+-----------------------------+------------+-----------------+------------------------+------+--------+
|          full_name          |    city    | passport_number | destination_airport_id | hour | minute |
+-----------------------------+------------+-----------------+------------------------+------+--------+
| Fiftyville Regional Airport | Fiftyville | 5773159633      | 4                      | 8    | 20     | 4 is LaGuardia Airport (New York City)
| Fiftyville Regional Airport | Fiftyville | 1988161715      | 4                      | 8    | 20     |
+-----------------------------+------------+-----------------+------------------------+------+--------+
*/

SELECT full_name, city FROM airports
WHERE id IN (4);

/*
+-------------------+---------------+
|     full_name     |     city      |
+-------------------+---------------+
| LaGuardia Airport | New York City |
+-------------------+---------------+
*/

