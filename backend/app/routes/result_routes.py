from flask import Blueprint, request, jsonify
from controllers.result_controller import ResultController


result_bp = Blueprint('result_bp', __name__)

@result_bp.route("/saveResult", methods=['POST'])
def save_result():
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Dados JSON necessários'}), 400
            
        # Remove a verificação extra - agora o controller sempre retorna o formato correto
        return ResultController.save_result(data)
        
    except Exception as e:
        return jsonify({'error': f'Erro na requisição: {str(e)}'}), 500
            
    except Exception as e:
        return jsonify({'error': f'Erro inesperado: {str(e)}'}), 500

@result_bp.route("/getResults", methods=['GET'])
def get_results():
    user_id = request.args.get('user_id')
    return ResultController.get_results(user_id)

def init_result_routes(app):

    app.register_blueprint(result_bp, url_prefix='/api')