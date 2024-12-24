from bottle import route, run, template
import psycopg2


connection = psycopg2.connect(
    database = "bonusql",
    host = "localhost",
    port = "5434",
    password="postgres",
    user="postgres")

connection.autocommit = True

@route('/borrow')
def borrow():
    return template('borrow.tpl')

# Route für die URL `/`
@route('/')
def home():
    return template('index.tpl')



# Route für die URL `/hello/<name>`
@route('/hello/<name>')
def hello(name):
    return template('<b>Hello {{name}}</b>!', name=name)
@route('/search')
def search():
    return template('search.tpl')
@route('/add')
def add():
    return template('add.tpl')
run(host='localhost', port=8080,debug=True)