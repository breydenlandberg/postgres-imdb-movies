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
