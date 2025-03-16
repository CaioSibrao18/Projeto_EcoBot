from flask import Flask

def create_app():
    app = Flask(__name__)

    # Carregar configurações
    app.config.from_pyfile('config.py')

    # Registrar rotas
    from .routes import init_routes
    init_routes(app)

    return app