SELECT name FROM people
JOIN stars, movies ON people.id = stars.person_id AND movies.id = stars.movie_id
WHERE movies.title = "Toy Story";
