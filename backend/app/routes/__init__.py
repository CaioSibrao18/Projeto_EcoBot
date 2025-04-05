from .auth_routes import init_auth_routes
from .result_routes import init_result_routes

def init_routes(app):
    init_auth_routes(app)
    init_result_routes(app)