from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'HE EVERYONE thank you so much everyone for attaneding!!!'
