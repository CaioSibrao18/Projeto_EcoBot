from flask import Flask
from routes import init_routes
from flask_cors import CORS

def create_app():
    app = Flask(__name__)
    CORS(app)
    init_routes(app)  # Esta linha registra TODAS as rotas
    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, host='0.0.0.0')