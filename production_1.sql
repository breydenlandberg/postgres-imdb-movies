DROP SCHEMA "public" CASCADE;

CREATE SCHEMA "public";

------------------------------
-- tables
------------------------------

/**
  *
	The code blocks below will create temporary tables, which will have data from the IMDb datasets copied into them 
	from bash externally, using the \copy command.

	Below are the tables for:
	1. IMDb movies (imdb_movies_temp) - temporary table for self explanatory content

	2. IMDb names (imdb_names_temp) - temporary table containing data about individuals that have played a role in any 
					   piece of media existing in the IMDb database, e.g. actors, directors, producers.

	3. IMDb principals (imdb_principals_temp) - temporary table containing name roles and characters.

	The data provided from the dataset (https://www.kaggle.com/trentpark/imdb-data) is reasonably clean, requiring structurally few changes to get into 
	3NF. In situations where the data is often incorrectly typed, it is usually copied as the TEXT type, and then cleaned later (in production_2.sql).
	This is also because the dataset contains empty strings ('') instead of null, which prevents direct copying into the correct type.
  *
  **/
CREATE TABLE imdb_movies_temp(
	movie_id TEXT PRIMARY KEY, -- Identification system used by IMDb, beginning with 'tt' for titles.
	movie_title TEXT NOT NULL,
	movie_original_title TEXT NOT NULL,
	movie_release_year TEXT NOT NULL,
	movie_release_date TEXT NOT NULL,
	movie_genres TEXT NOT NULL,
	movie_duration INTEGER NOT NULL, -- In minutes.
	movie_countries TEXT NOT NULL,
	movie_languages TEXT NOT NULL,
	movie_directors TEXT NOT NULL,
	movie_writers TEXT NOT NULL,
	movie_production_company TEXT NOT NULL,
	movie_actors TEXT NOT NULL,
	movie_description TEXT NOT NULL,
	movie_avg_vote NUMERIC(2, 1) NOT NULL, -- Rephrased: average rating of movie.
	movie_votes INTEGER NOT NULL,
	movie_budget TEXT NOT NULL,
	movie_usa_gross_income TEXT NOT NULL,
	movie_worldwide_gross_income TEXT NOT NULL,
	movie_metascore TEXT NOT NULL,
	movie_user_reviews TEXT NOT NULL,
	movie_critic_reviews TEXT NOT NULL
);

CREATE TABLE imdb_names_temp(
	name_id TEXT PRIMARY KEY, -- Identification system used by IMDb, beginning with nm for names.
	current_name TEXT NOT NULL,
	birth_name TEXT NOT NULL,
	height TEXT NOT NULL,
	biography TEXT NOT NULL,
	birth_details TEXT NOT NULL,
	date_of_birth TEXT NOT NULL,
	place_of_birth TEXT NOT NULL,
	death_details TEXT NOT NULL,
	date_of_death TEXT NOT NULL,
	place_of_death TEXT NOT NULL,
	reason_of_death TEXT NOT NULL,
	spouses_name TEXT NOT NULL,
	spouses_count INTEGER NOT NULL,
	divorces_count INTEGER NOT NULL,
	spouses_with_children INTEGER NOT NULL,
	children_count INTEGER NOT NULL
);

CREATE TABLE imdb_principals_temp(
	movie_id TEXT NOT NULL,
	name_order_index INTEGER NOT NULL,
	name_id TEXT NOT NULL,
	name_role TEXT NOT NULL,
	name_specific_role TEXT NOT NULL,
	name_characters TEXT NOT NULL,
	PRIMARY KEY(movie_id, name_order_index, name_id)
);


/**
  *
	It was decided that the included IMDb ratings dataset will not be utilised, as it contains too much irrelevant data. All of the desired 
	ratings data is already in the movies table.

	The code block below will create the final tables, which will have relevant data from the temporary tables copied into them.
	"[Ir]relevant data" in this situation means only the data [un]desired for display in the context of this database, which is to be 
	used for public web applications.

	Below are the respective tables for the corresponding tables previously created.
  *
  **/
CREATE  TABLE  imdb_movies(movie_id, movie_title, movie_release_year, movie_genres, movie_duration, movie_countries, movie_languages, movie_directors, movie_writers,
			    movie_production_company, movie_actors, movie_description, movie_avg_vote, movie_votes, movie_user_reviews, movie_critic_reviews)
	AS
		SELECT movie_id, movie_title, movie_release_year, movie_genres, movie_duration, movie_countries, movie_languages, movie_directors, movie_writers,
		       movie_production_company, movie_actors, movie_description, movie_avg_vote, movie_votes, movie_user_reviews, movie_critic_reviews
		FROM   imdb_movies_temp;
		
CREATE  TABLE  imdb_names(name_id, current_name, birth_name, biography, birth_details, death_details)
	AS
		SELECT name_id, current_name, birth_name, biography, birth_details, death_details
		FROM   imdb_names_temp;
		
CREATE  TABLE  imdb_principals(movie_id, name_order_index, name_id, name_role, name_characters)
	AS
		SELECT movie_id, name_order_index, name_id, name_role, name_characters
		FROM   imdb_principals_temp;
