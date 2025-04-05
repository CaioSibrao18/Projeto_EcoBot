from flask import request, jsonify
from controllers.auth_controller import AuthController

def init_auth_routes(app):
    @app.route('/')
    def home():
        return jsonify({"mensagem": "Bem-vindo à API de login!"})
    
    
    @app.route('/register', methods=['POST'])
    def register():
        dados = request.json
        return AuthController.register(
            nome=dados.get('nome'),
            data_nascimento=dados.get('data_nascimento'),
            genero=dados.get('genero'),
            email=dados.get('email'),
            senha=dados.get('senha')
        )

    @app.route('/login', methods=['POST'])
    def login():
        dados = request.json
        return AuthController.login(
            email=dados.get('email'),
            senha=dados.get('senha')
        )

    @app.route('/forgetPassword', methods=['POST'])
    def forget_password():
        dados = request.json
        return AuthController.forget_password(
            email=dados.get('email')
        )

    @app.route('/validate-reset-token', methods=['POST'])
    def validate_reset_token():
        dados = request.json
        return AuthController.validate_reset_token(
            token=dados.get('token')
        )

    @app.route('/reset-password', methods=['POST'])
    def reset_password():
        dados = request.json
        return AuthController.reset_password(
            token=dados.get('token'),
            nova_senha=dados.get('nova_senha')
        )