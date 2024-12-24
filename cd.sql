CREATE TABLE cd (
    DiskID SERIAL PRIMARY KEY,
    Disk_Name Varchar(50),
    Artist_ID int);

CREATE TABLE artist(
    ArtistID SERIAL PRIMARY KEY,
    Artist_Name varchar(50)

);
CREATE TABLE track(
    TrackID SERIAL primary key,
    Track_name varchar(50),
    release date
);
CREATE TABLE at(
    FOREIGN KEY (ArtistID) REFERENCES artist (ArtistID),
    FOREIGN KEY (TrackID) REFERENCES track (TrackID)
);


