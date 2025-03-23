from flask import Flask
from flask_mail import Mail

app = Flask(__name__)
mail = Mail(app)

from app.routes.auth import auth_bp
app.register_blueprint(auth_bp)