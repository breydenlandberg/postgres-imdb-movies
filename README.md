# A PostgreSQL database for IMDb movies
Data sourced from: https://www.kaggle.com/trentpark/imdb-data

## Background
A web application was to be built around the data linked above. It would manipulate the data in various ways; display it, filter it, find from it. Therefore, this PostgreSQL database was constructed to facilitate this. PostgreSQL was chosen because it is a robust, powerful RDBMS.

The web application built around this can be found at: {website}\
It is deployed on Heroku and built using {?}.

## Description
The database will have been cleaned and normalised to 3NF. The original datasets were reasonably 
clean and well structured already, so it was not an extensive 
effort to do so. It contains detailed data relating to:
- Movies, and **only** movies - not TV shows, plays, etc
- Names - actors, directors, writers, etc.
- Principals - specific roles of and characters played by names.

In the normalisation process, this database ultimately looks like the following tables:
- imdb_movies in 3NF
- movie_attributes in 1NF `FK(movie_id) in imdb_movies`
- imdb_names in 3NF
- imdb_principals in 3NF
- principal_characters in 1NF `FK(movie_id, name_order_index, name_id) in imdb_principals`

## Usage
Creating the database is easy, simply:

1. Run production_1.sql
2. Use the `\copy` psql command to copy the data in from the .csv files
3. Run production_2.sql

Demonstrated below:

### Local
**ASSUMING A DATABASE NAMED `postgres-imdb-movies`**

In the folder containing the production_[1|2].sql files, build the tables to copy the data into:
```bash
psql -h localhost -U postgres -d postgres-imdb-movies -a -f production_1.sql
```
\
Run psql as postgres in the postgres-imdb-movies database:
```bash
sudo -u postgres psql -d postgres-imdb-movies
```
\
Which `\dt` will show as:
```bash
            List of relations
 Schema |         Name         | Type  |  Owner   
--------+----------------------+-------+----------
 public | imdb_movies          | table | postgres
 public | imdb_movies_temp     | table | postgres
 public | imdb_names           | table | postgres
 public | imdb_names_temp      | table | postgres
 public | imdb_principals      | table | postgres
 public | imdb_principals_temp | table | postgres
 ```
\
Copy in the data:
```bash
\copy imdb_movies_temp FROM '~/path/to/imdb-movies-filename.csv' NULL '\N' DELIMITER ',' CSV HEADER;
```
returning `COPY 85855`
```bash
\copy imdb_names_temp FROM '~/path/to/imdb-names-filename.csv' NULL '\N' DELIMITER ',' CSV HEADER;
```
returning `COPY 297705`
```bash
\copy imdb_principals_temp FROM '~/path/to/imdb-principals-filename.csv' NULL '\N' DELIMITER ',' CSV HEADER;
```
returning `COPY 835513`

Exit postgres psql:
```bash
\q
```
\
Insert data, modify and normalise tables:
```bash
psql -h localhost -U postgres -d postgres-imdb-movies -a -f production_2.sql
```

On completion, the database is finished and ready to be used!

`\dt`:
```bash
           List of relations
 Schema |         Name         | Type  |  Owner   
--------+----------------------+-------+----------
 public | imdb_movies          | table | postgres
 public | imdb_names           | table | postgres
 public | imdb_principals      | table | postgres
 public | movie_attributes     | table | postgres
 public | principal_characters | table | postgres
```

### Heroku
In the folder containing the production_[1|2].sql files, build the tables to copy the data into, using `heroku`:
```bash
heroku pg:psql --app app-name < production_1.sql
```
\
Run psql as heroku:
```bash
heroku pg:psql --app app-name
```
\
Which `\dt` will show as:
```bash
            List of relations
 Schema |         Name         | Type  |     Owner      
--------+----------------------+-------+----------------
 public | imdb_movies          | table | herokuusername
 public | imdb_movies_temp     | table | herokuusername
 public | imdb_names           | table | herokuusername
 public | imdb_names_temp      | table | herokuusername
 public | imdb_principals      | table | herokuusername
 public | imdb_principals_temp | table | herokuusername
 ```
\
Copy in the data:
```bash
\copy imdb_movies_temp FROM '~/path/to/imdb-movies-filename.csv' NULL '\N' DELIMITER ',' CSV HEADER;
```
returning `COPY 85855`
```bash
\copy imdb_names_temp FROM '~/path/to/imdb-names-filename.csv' NULL '\N' DELIMITER ',' CSV HEADER;
```
returning `COPY 297705`
```bash
\copy imdb_principals_temp FROM '~/path/to/imdb-principals-filename.csv' NULL '\N' DELIMITER ',' CSV HEADER;
```
returning `COPY 835513`

Exit postgres psql:
```bash
\q
```
\
Insert data, modify and normalise tables (again, in the folder containing the production_[1|2].sql files):
```bash
heroku pg:psql --app app-name < production_2.sql
```
This may take quite a while.

On completion, the database is finished and ready to be used!

`\dt`:
```bash
            List of relations
 Schema |         Name         | Type  |     Owner      
--------+----------------------+-------+----------------
 public | imdb_movies          | table | herokuusername
 public | imdb_names           | table | herokuusername
 public | imdb_principals      | table | herokuusername
 public | movie_attributes     | table | herokuusername
 public | principal_characters | table | herokuusername
```

### Further information
In order to connect the Heroku database to PGAdmin4, see: https://medium.com/analytics-vidhya/how-to-use-pgadmin-to-connect-to-a-heroku-database-c69b7cbfccd8

## License
https://www.kaggle.com/terms

https://help.imdb.com/article/imdb/general-information/can-i-use-imdb-data-in-my-software/G5JTRESSHJBBHTGX?ref_=helpart_nav_25#

The MIT License (2021)

## Project Status
Finished.
