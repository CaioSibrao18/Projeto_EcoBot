from flask import request
from controllers.result_controller import ResultController

def init_result_routes(app):
    @app.route("/saveResult", methods=['POST'])
    def save_result():
        dados = request.get_json()
        return ResultController.save_result(dados)

    @app.route("/getResults", methods=['GET'])
    def get_results():
        usuario_id = request.args.get('usuario_id', type=int)
        jogo = request.args.get('jogo')
        dificuldade = request.args.get('dificuldade')
        
        return ResultController.get_results(
            usuario_id=usuario_id,
            jogo=jogo,
            dificuldade=dificuldade
        )