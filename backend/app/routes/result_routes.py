from flask import Blueprint, request, jsonify
from controllers.result_controller import ResultController


result_bp = Blueprint('result_bp', __name__)

@result_bp.route("/saveResult", methods=['POST'])
def save_result():
    data = request.get_json()
    return ResultController.save_result(data)

@result_bp.route("/getResults", methods=['GET'])
def get_results():
    user_id = request.args.get('user_id')
    return ResultController.get_results(user_id)

def init_result_routes(app):

    app.register_blueprint(result_bp, url_prefix='/api')