# backend/app/routes/result_routes.py
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
        # Remova jogo e dificuldade se não estiver usando
        return ResultController.get_results(usuario_id=usuario_id)