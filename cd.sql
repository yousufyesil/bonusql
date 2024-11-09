CREATE TABLE CD(
    isbn varchar(13) NOT NULL,
    title varchar(50) NOT NULL,
    artist varchar(50) NOT NULL,
)

CREATE TABLE artist(
    artist_id int NOT NULL AUTO_INCREMENT,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES CD(isbn),
    PRIMARY KEY (artist_id),
);

CREATE TABLE track(
    track_id int,
    title varchar(50) NOT NULL,
    FOREIGN KEY(isbn) REFERENCES CD(isbn),
    PRIMARY KEY (track_id,isbn),
);