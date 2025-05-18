from flask import Flask
from routes import init_routes
from flask_cors import CORS
import joblib

def create_app():
    app = Flask(__name__)
    CORS(app)

    # Carrega modelo e label encoder
    model, le = joblib.load('eco_bot_model.pkl')
    app.model = model
    app.le = le

    init_routes(app)  # registra rotas
    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, host='0.0.0.0')
