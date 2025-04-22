from flask import request, jsonify
from controllers.auth_controller import AuthController
from datetime import datetime

def init_auth_routes(app):
    @app.route('/')
    def home():
        return jsonify({
            "mensagem": "Bem-vindo à API de autenticação",
            "status": "operacional",
            "data_hora": datetime.now().isoformat(),
            "endpoints": {
                "register": "/register (POST)",
                "login": "/login (POST)",
                "recuperacao_senha": {
                    "solicitar_codigo": "/forget-password (POST)",
                    "validar_codigo": "/validate-reset-token (POST)",
                    "redefinir_senha": "/reset-password (POST)"
                }
            }
        })
    
    @app.route('/register', methods=['POST'])
    def register():
        try:
            dados = request.get_json()
            
         
            if not all(key in dados for key in ['nome', 'email', 'senha']):
                return jsonify({
                    "error": "Dados incompletos",
                    "required": ["nome", "email", "senha"],
                    "optional": ["data_nascimento", "genero"]
                }), 400
            
          
            resultado, status_code = AuthController.register(
                nome=dados.get('nome'),
                data_nascimento=dados.get('data_nascimento'),
                genero=dados.get('genero'),
                email=dados.get('email').lower().strip(),
                senha=dados.get('senha')
            )
            
          
            return jsonify(resultado), status_code

        except Exception as e:
            return jsonify({
                "error": "Erro no processamento",
                "details": str(e)
            }), 500

    @app.route('/login', methods=['POST'])
    def login():
        try:
            dados = request.get_json()
            
            if not all(key in dados for key in ['email', 'senha']):
                return jsonify({
                    "error": "Credenciais necessárias",
                    "required": ["email", "senha"]
                }), 400
                
            resultado, status_code = AuthController.login(
                email=dados.get('email').lower().strip(),
                senha=dados.get('senha')
            )
            
            return jsonify(resultado), status_code
            
        except Exception as e:
            return jsonify({
                "error": "Erro no login",
                "details": str(e)
            }), 500

    @app.route('/forget-password', methods=['POST'])
    def forget_password():
        try:
            dados = request.get_json()
            
            if 'email' not in dados:
                return jsonify({
                    "error": "Email é obrigatório",
                    "required": ["email"]
                }), 400
                
            resultado, status_code = AuthController.forget_password(
                email=dados.get('email').lower().strip()
            )
            
            
            if app.debug and resultado.get('success'):
                resultado['debug_token'] = resultado.get('token')
                
            return jsonify(resultado), status_code
            
        except Exception as e:
            return jsonify({
                "error": "Erro ao processar solicitação",
                "details": str(e)
            }), 500


    @app.route('/validate-reset-token', methods=['POST'])
    def validate_reset_token():
        try:
            dados = request.get_json()
            
            if not all(key in dados for key in ['email', 'token']):
                return jsonify({
                    "error": "Dados incompletos",
                    "required": ["email", "token"]
                }), 400
                
            resultado = AuthController.validate_reset_token(
                email=dados.get('email').lower().strip(),
                token=dados.get('token').strip()
            )
            
            return jsonify(resultado), 200 if resultado.get('success') else 400
            
        except Exception as e:
            return jsonify({
                "error": "Erro na validação do token",
                "details": str(e)
            }), 500

    @app.route('/reset-password', methods=['POST'])
    def reset_password():
        try:
            dados = request.get_json()
            
            if not all(key in dados for key in ['email', 'token', 'nova_senha']):
                return jsonify({
                    "error": "Dados incompletos",
                    "required": ["email", "token", "nova_senha"]
                }), 400
                
            if len(dados.get('nova_senha')) < 8:
                return jsonify({
                    "error": "Senha muito curta",
                    "min_length": 8
                }), 400
                
            resultado = AuthController.reset_password(
                email=dados.get('email').lower().strip(),
                token=dados.get('token').strip(),
                nova_senha=dados.get('nova_senha')
            )
            
            return jsonify(resultado), 200 if resultado.get('success') else 400
            
        except Exception as e:
            return jsonify({
                "error": "Erro ao redefinir senha",
                "details": str(e)
            }), 500
