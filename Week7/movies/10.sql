SELECT DISTINCT(name) FROM people
JOIN directors, ratings ON people.id = directors.person_id AND ratings.movie_id = directors.movie_id
WHERE ratings.rating >= 9.0;
