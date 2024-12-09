from bottle import route, run, template

# Route für die URL `/`
@route('/')
def home():
    return "Willkommen! Besuchen Sie /hello/<name>, um einen Namen einzugeben."

# Route für die URL `/hello/<name>`
@route('/hello/<name>')
def hello(name):
    return template('<b>Hello {{name}}</b>!', name=name)

run(host='localhost', port=8080)