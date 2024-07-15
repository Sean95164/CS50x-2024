SELECT name FROM people
JOIN stars, movies ON people.id = stars.person_id AND stars.movie_id = movies.id
WHERE movies.id IN
    (SELECT movies.id FROM movies -- Find all the movie Kevin Bacon (1958) starred in
    JOIN people AS p1, stars ON p1.id = stars.person_id AND stars.movie_id = movies.id
    WHERE p1.name = "Kevin Bacon" AND p1.birth = 1958)
AND name != "Kevin Bacon";
