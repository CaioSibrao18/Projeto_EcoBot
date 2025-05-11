from flask import request, jsonify
from controllers.auth_controller import AuthController
from controllers.result_controller import ResultController
from datetime import datetime

def init_auth_routes(app):

    @app.route('/')
    def home():
        return jsonify({
            "mensagem": "Bem-vindo à API EcoQuest",
            "status": "operacional",
            "data_hora": datetime.now().isoformat(),
            "endpoints": {
                "autenticacao": {
                    "register": "/auth/register (POST)",
                    "login": "/auth/login (POST)",
                    "recuperacao_senha": {
                        "solicitar_codigo": "/auth/forget-password (POST)",
                        "validar_codigo": "/auth/validate-reset-token (POST)",
                        "redefinir_senha": "/auth/reset-password (POST)"
                    }
                },
                "desempenho": {
                    "salvar_resultado": "/results (POST)",
                    "obter_resultados": "/results (GET)",
                    "analise_desempenho": "/results/feedback?usuario_id=<ID> (GET)"
                }
            }
        })
    


 
    @app.route('/results', methods=['POST'])
    def save_result():
        try:
            dados = request.get_json()
            
            if not all(key in dados for key in ['usuario_id', 'acertos', 'tempo_segundos']):
                return jsonify({
                    "error": "Dados incompletos",
                    "required": ["usuario_id", "acertos", "tempo_segundos"],
                    "optional": ["total_questoes"]
                }), 400
                
            resultado = ResultController.save_result({
                'usuario_id': dados['usuario_id'],
                'acertos': dados['acertos'],
                'tempo_segundos': dados['tempo_segundos'],
                'total_questoes': dados.get('total_questoes', dados['acertos'])
            })
            
            return jsonify(resultado[0]), resultado[1]
            
        except Exception as e:
            return jsonify({
                "error": "Erro ao salvar resultado",
                "details": str(e)
            }), 500

    @app.route('/results', methods=['GET'])
    def get_results_route():
        try:
            usuario_id = request.args.get('usuario_id')
            limit = request.args.get('limit', type=int)  


            response = ResultController.get_results(
                usuario_id=usuario_id,
                limit=limit
            )

       
            if response['status'] == 'error':
                return jsonify({
                    'status': 'error',
                    'message': response['message'],
                    'data': {
                        'results': [],
                        'count': 0
                    }
                }), 500

            return jsonify({
                'status': 'success',
                'message': response['message'],
                'data': {
                    'results': response['results'],
                    'count': response['count']
                }
            }), 200

        except Exception as e:
            return jsonify({
                'status': 'error',
                'message': f'Erro inesperado: {str(e)}',
                'data': {
                    'results': [],
                    'count': 0
                }
            }), 500
        
    @app.route('/results/feedback', methods=['GET'])
    def get_feedback():
        try:
            usuario_id = request.args.get('usuario_id')
            if not usuario_id:
                return jsonify({"error": "Parâmetro usuario_id é obrigatório"}), 400
            
          
            try:
                usuario_id = int(usuario_id)
            except ValueError:
                return jsonify({"error": "user_id deve ser um número"}), 400
                
            resultado = ResultController.generate_evolution_feedback(usuario_id)
            return jsonify(resultado[0]), resultado[1]
        except Exception as e:
            return jsonify({
                "error": "Erro na análise de desempenho",
                "details": str(e)
            }), 500
        

    @app.route('/auth/register', methods=['POST']) 
    @app.route('/auth/register ', methods=['POST']) 
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

    @app.route('/auth/login', methods=['POST'])
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
        
    
    # Rota unificada
    @app.route('/users', methods=['GET'])
    def handle_users():
        try:
            user_id = request.args.get('id')
            page = request.args.get('page', type=int)
            per_page = request.args.get('per_page', type=int)
            
          
            resultado, status_code = AuthController.get_users(
                user_id=user_id,
                page=page,
                per_page=per_page
            )
            return jsonify(resultado), status_code
            
        except Exception as e:
            return jsonify({
                "error": "Erro na requisição",
                "details": str(e)
            }), 500