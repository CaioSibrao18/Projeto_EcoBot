from flask import Flask
from routes import init_routes
from flask_cors import CORS
import os
import joblib

def create_app():
    app = Flask(__name__)
    CORS(app)

    # Caminho absoluto até o modelo .pkl
    model_path = os.path.join(os.path.dirname(__file__), 'eco_bot_model.pkl')
    model, le = joblib.load(model_path)

    app.model = model
    app.le = le

    init_routes(app)
    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, host='0.0.0.0')