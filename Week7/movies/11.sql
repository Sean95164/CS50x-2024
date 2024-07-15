SELECT title FROM movies JOIN stars, people, ratings ON movies.id = stars.movie_id AND stars.movie_id = ratings.movie_id AND stars.person_id = people.id
WHERE people.name = "Chadwick Boseman"
ORDER BY ratings.rating DESC
LIMIT 5;
