from flask import request, jsonify
from .views.auth_view import AuthView  # Importação relativa

def init_routes(app):
    @app.route('/')
    def home():
        return jsonify({"mensagem": "Bem-vindo à API de login!"})

    @app.route('/login', methods=['POST'])
    def login():
        dados = request.json
        username = dados.get('username')
        senha = dados.get('senha')

        resposta = AuthView.login(username, senha)
        return jsonify(resposta), 200 if resposta['status'] == 'sucesso' else 401

    @app.route('/register', methods=['POST'])
    def register():
        dados = request.json
        username = dados.get('username')
        senha = dados.get('senha')

        resposta = AuthView.register(username, senha)
        return jsonify(resposta), 200 if resposta['status'] == 'sucesso' else 400