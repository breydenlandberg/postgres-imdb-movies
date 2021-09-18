/**
  *
	The code blocks below will normalise the database to 3NF.


	imdb_movies and imdb_principals will be normalised to 3NF by decomposing the relations in order to remove redundant data, 
	the implementation automatically ensuring 1NF and 2NF. imdb_names is already in 3NF. As mentioned previously, the data is already 
	rather clean and well structured, so there is minimal effort on our part to normalise it. Destructured tables are composed of the 3NF 
	main table and a 1NF table where where redundancy is "pushed back" to.


	The database will be in 3NF because:
	- It satisfies 1NF (single valued, unique records).
	- It satisfies 2NF (satisfies 1NF, no partial dependencies).
	- No transitive dependencies.
  *
  **/
CREATE TABLE   imdb_movies_3NF(movie_id, movie_title, movie_release_year, movie_duration, movie_production_company, movie_description, 
							   movie_avg_vote, movie_votes, movie_user_reviews, movie_critic_reviews)
	AS
		SELECT movie_id, 
		       movie_title, 
		       movie_release_year, 
		       movie_duration, 
		       movie_production_company, 
		       movie_description, 
		       movie_avg_vote, movie_votes, 
		       movie_user_reviews, 
		       movie_critic_reviews
		FROM   imdb_movies;

ALTER TABLE imdb_movies_3NF
	ADD PRIMARY KEY(movie_id);

CREATE TABLE   movie_attributes_1NF(movie_id, movie_genres, movie_countries, movie_languages, movie_directors, movie_writers, movie_actors)
	AS
		SELECT movie_id,
		       UNNEST(movie_genres),
		       UNNEST(movie_countries),
		       UNNEST(movie_languages),
		       UNNEST(movie_directors),
		       UNNEST(movie_writers),
		       UNNEST(movie_actors)
	    	FROM   imdb_movies;

DROP TABLE imdb_movies;
		
ALTER TABLE movie_attributes_1NF
	ADD CONSTRAINT movie_attributes_fk
		FOREIGN KEY(movie_id) REFERENCES imdb_movies_3NF;


ALTER TABLE imdb_names
	RENAME TO imdb_names_3NF;


CREATE  TABLE  imdb_principals_3NF(movie_id, name_order_index, name_id, name_role)
	AS
		SELECT movie_id, name_order_index, name_id, name_role
		FROM   imdb_principals;

ALTER TABLE imdb_principals_3NF
	ADD PRIMARY KEY(movie_id, name_order_index, name_id);
	
CREATE TABLE   principal_characters_1NF(movie_id, name_order_index, name_id, name_characters)
	AS
		SELECT movie_id, name_order_index, name_id, 
		       UNNEST(name_characters)
		FROM   imdb_principals;

DROP TABLE imdb_principals;

ALTER TABLE principal_characters_1NF
	ADD CONSTRAINT  pricipal_characters_fk
		FOREIGN KEY(movie_id, name_order_index, name_id) REFERENCES imdb_principals_3NF(movie_id, name_order_index, name_id);
