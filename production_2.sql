------------------------------
-- functions
------------------------------

/**
  *
	*- - - FUNCTION (AGGREGATE) - - -*
	
	PURPOSE: Takes a JSONB type parameter and returns a set containing the JSONB data casted to TEXT[].
	
	PARAMETERS: array_param JSONB, a TEXT containing a JSON array structure, casted to JSONB.
	
	RETURNS: A set of TEXT[] typed records built from the JSONB data, arrived at by taking individual JSONBs 
			 and using the JSONB_ARRAY_ELEMENTS_TEXT function over them.
  *
  **/
CREATE OR REPLACE FUNCTION JSONB_ARRAY_TO_TEXT_ARRAY(array_param JSONB)
	RETURNS TEXT[]
	LANGUAGE sql
	IMMUTABLE
AS $$

SELECT ARRAY_AGG(set_of_text)::TEXT[] FROM JSONB_ARRAY_ELEMENTS_TEXT(array_param) AS set_of_text;

$$;

------------------------------
-- inserts
------------------------------

/**
  *
	As previously mentioned, only the relevant data is selected for copying.
  *
  **/
INSERT INTO    imdb_movies(movie_id, movie_title, movie_release_year, movie_genres, movie_duration, movie_countries, movie_languages, movie_directors, 
			    movie_writers, movie_production_company, movie_actors, movie_description, movie_avg_vote, movie_votes, movie_user_reviews, 
			    movie_critic_reviews)
	SELECT  movie_id, movie_title, movie_release_year, movie_genres, movie_duration, movie_countries, movie_languages, movie_directors, movie_writers,
		movie_production_company, movie_actors, movie_description, movie_avg_vote, movie_votes, movie_user_reviews, movie_critic_reviews
	FROM    imdb_movies_temp;
	
INSERT INTO    imdb_names(name_id, current_name, birth_name, biography, birth_details, death_details)
	SELECT  name_id, current_name, birth_name, biography, birth_details, death_details
	FROM    imdb_names_temp;
	
INSERT INTO    imdb_principals(movie_id, name_order_index, name_id, name_role, name_characters)
	SELECT  movie_id, name_order_index, name_id, name_role, name_characters
	FROM	imdb_principals_temp;

	
DROP TABLE imdb_movies_temp, imdb_names_temp, imdb_principals_temp;

------------------------------
-- table modifications
------------------------------

/**
  *
    Begin data cleansing and table alterations to pave the the way for the final normalised database.

    The code blocks below will use UPDATE/ALTER on the existing tables containing relevant data from the IMDb datasets.

    This is pre processing by data cleansing before beginning the normalisation process.


    The columns are cleaned in the following ways:
    - Corrected formatting (e.g. using regex to format movie_release_year from imdb_movies as YYYY).
    - Casting to the correct type or to arrays (e.g. from TEXT to INTEGER, from TEXT to TEXT[] using the STRING_TO_ARRAY function).
    - Replacing empty strings ('') and empty arrays ({}) with null.
    - Adding primary keys.
  *
  **/
UPDATE imdb_movies SET movie_production_company = null WHERE movie_production_company LIKE '';
UPDATE imdb_movies SET movie_description 	  = null WHERE movie_description        LIKE '';

ALTER TABLE imdb_movies
	ADD PRIMARY KEY(movie_id),

	ALTER COLUMN movie_release_year TYPE INTEGER USING NULLIF(REGEXP_REPLACE(movie_release_year, '[^0-9.]*', '', 'g'), '')::INTEGER,

	ALTER COLUMN movie_genres 	 TYPE TEXT[] USING NULLIF(STRING_TO_ARRAY(movie_genres,    ', '), '{}'),
	ALTER COLUMN movie_countries    TYPE TEXT[] USING NULLIF(STRING_TO_ARRAY(movie_countries, ', '), '{}'),
	ALTER COLUMN movie_languages    TYPE TEXT[] USING NULLIF(STRING_TO_ARRAY(movie_languages, ', '), '{}'),
	ALTER COLUMN movie_directors    TYPE TEXT[] USING NULLIF(STRING_TO_ARRAY(movie_directors, ', '), '{}'),
	ALTER COLUMN movie_writers 	 TYPE TEXT[] USING NULLIF(STRING_TO_ARRAY(movie_writers,   ', '), '{}'),
	ALTER COLUMN movie_actors 	 TYPE TEXT[] USING NULLIF(STRING_TO_ARRAY(movie_actors,    ', '), '{}'),

	ALTER COLUMN movie_user_reviews   TYPE INTEGER USING NULLIF(movie_user_reviews,   '')::REAL::INTEGER,
	ALTER COLUMN movie_critic_reviews TYPE INTEGER USING NULLIF(movie_critic_reviews, '')::REAL::INTEGER;


UPDATE imdb_names SET biography      = null WHERE biography 	   LIKE '';
UPDATE imdb_names SET birth_details  = null WHERE birth_details  LIKE '';
UPDATE imdb_names SET death_details  = null WHERE death_details  LIKE '';

ALTER TABLE imdb_names
	ADD PRIMARY KEY(name_id);


/**
  *
	Update name_characters from imdb_principals using the JSONB_ARRAY_TO_TEXT_ARRAY function, an aggregate function (returns a set).
  *
  **/
UPDATE imdb_principals SET name_characters = null WHERE name_characters LIKE '';
UPDATE imdb_principals
SET    name_characters = subquery.name_characters_text_array
FROM (SELECT 
	movie_id, 
  	name_order_index, 
  	name_id, 
  	JSONB_ARRAY_TO_TEXT_ARRAY(name_characters::JSONB) AS name_characters_text_array
      FROM imdb_principals) AS subquery
WHERE imdb_principals.movie_id         = subquery.movie_id
AND   imdb_principals.name_order_index = subquery.name_order_index
AND   imdb_principals.name_id          = subquery.name_id;

ALTER TABLE imdb_principals
	ADD PRIMARY KEY(movie_id, name_order_index, name_id),

	ALTER COLUMN name_characters TYPE TEXT[] USING name_characters::TEXT[];

------------------------------
-- normalisation
------------------------------

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
		SELECT movie_id, movie_title, 
		       movie_release_year, 
		       movie_duration, 
		       movie_production_company, 
		       movie_description, 
		       movie_avg_vote, 
		       movie_votes, 
		       movie_user_reviews, 
		       movie_critic_reviews
		FROM   imdb_movies;

ALTER TABLE imdb_movies_3NF
	ADD PRIMARY KEY(movie_id);

CREATE TABLE movie_attributes_1NF(movie_id, movie_genres, movie_countries, movie_languages, movie_directors, movie_writers, movie_actors)
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


ALTER TABLE   imdb_movies_3NF
	RENAME TO imdb_movies;
ALTER TABLE   movie_attributes_1NF
	RENAME TO movie_attributes;
ALTER TABLE   imdb_names_3NF
	RENAME TO imdb_names;
ALTER TABLE   imdb_principals_3NF
	RENAME TO imdb_principals;
ALTER TABLE   principal_characters_1NF
	RENAME TO principal_characters;
