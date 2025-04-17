# backend/app/controllers/result_controller.py
from flask import jsonify
from models.result_model import ResultModel

class ResultController:
    @staticmethod
    def save_result(data):
        required_fields = ['usuario_id', 'acertos', 'tempo_segundos']
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Todos os campos são obrigatórios'}), 400

        try:
            success = ResultModel.save_result(
                usuario_id=int(data['usuario_id']),
                acertos=float(data['acertos']),
                tempo_segundos=int(data['tempo_segundos'])
            )
            
            if success:
                return jsonify({'message': 'Resultado salvo com sucesso'}), 201
            return jsonify({'error': 'Erro ao salvar resultado'}), 500
                
        except ValueError:
            return jsonify({'error': 'Dados inválidos'}), 400
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    @staticmethod
    def get_results(usuario_id=None):
        try:
            resultados = ResultModel.get_results(usuario_id=usuario_id)
            return jsonify({
                'status': 'success',
                'count': len(resultados),
                'results': resultados
            }), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500