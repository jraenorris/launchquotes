DROP TABLE IF EXISTS blog, tags, type, contributer;


CREATE TABLE blog(
  id SERIAL PRIMARY KEY,
  url VARCHAR(1000) UNIQUE NOT NULL,
  description TEXT,
  type INTEGER,  
  );
