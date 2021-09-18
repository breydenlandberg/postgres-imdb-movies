/**
  *
	As previously mentioned, only the relevant data is selected for copying.
  *
  **/
INSERT INTO 	imdb_movies(movie_id, movie_title, movie_release_year, movie_genres, movie_duration, movie_countries, movie_languages, movie_directors, 
		movie_writers, movie_production_company, movie_actors, movie_description, movie_avg_vote, movie_votes, movie_user_reviews, 
		movie_critic_reviews)
	SELECT  movie_id, movie_title, movie_release_year, movie_genres, movie_duration, movie_countries, movie_languages, movie_directors, movie_writers,
	        movie_production_company, movie_actors, movie_description, movie_avg_vote, movie_votes, movie_user_reviews, movie_critic_reviews
	FROM    imdb_movies_temp;
	
INSERT INTO 	imdb_names(name_id, current_name, birth_name, biography, birth_details, death_details)
	SELECT  name_id, current_name, birth_name, biography, birth_details, death_details
	FROM    imdb_names_temp;
	
INSERT INTO 	imdb_principals(movie_id, name_order_index, name_id, name_role, name_characters)
	SELECT  movie_id, name_order_index, name_id, name_role, name_characters
	FROM	imdb_principals_temp;

	
DROP TABLE imdb_movies_temp, imdb_names_temp, imdb_principals_temp;
