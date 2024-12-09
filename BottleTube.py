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

def add_regal():
    cursor.execute("INSERT INTO regal DEFAULT VALUES ")

def add_reihe():
    type = input("Um welche Art Medium handelt es sich? ")
    regal = input("Bitte Regalnummer eingeben: ")
    item = input("Wie ist die Media_ID? ")
    type = "'" + type + "'"

    try:
        cursor.execute(f"INSERT INTO reihe (regalid, item_id, item_type) VALUES ({regal}, {item}, {type})")
    except psycopg2.errors.ForeignKeyViolation:
        print("Foreign Key verletzt. Prüfe ob alle Werte stimmen")
