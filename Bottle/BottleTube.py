import psycopg2
from sqlalchemy.sql.functions import concat

connection = psycopg2.connect(
    database = "bonusql",
    host = "localhost",
    port = "5434",
    password="postgres",
    user = "postgres",
)
connection.autocommit = True

cursor = connection.cursor()

def getBooks():
    cursor.execute("SELECT * FROM books")
    return cursor.fetchall()

def getAllAuthors():
    cursor.execute("SELECT * FROM author")
    return cursor.fetchall()

def getAuthor(name):
    cursor.execute(f"SELECT * FROM author WHERE name = '{name}'")
    return cursor.fetchall()

