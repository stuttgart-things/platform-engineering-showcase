from flask import Flask

app = Flask(__name__)

@app.route('/hello')
def hello():
    return 'hello'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

# Linting issue: bad indentation and unused variable
def bad_function():
 x= 42
 print('This function has bad formatting')
