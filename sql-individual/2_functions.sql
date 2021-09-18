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