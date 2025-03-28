from flask import Flask, request, jsonify
from bcrypt import hashpw, gensalt, checkpw
from db import get_db_connection
import secrets
from datetime import datetime, timedelta

app = Flask(__name__)

def init_routes(app):
    @app.route('/')
    def home():
        return jsonify({"mensagem": "Bem-vindo à API de login!"})

    @app.route('/login', methods=['POST'])
    def login():
        dados = request.json
        email = dados.get('email')
        senha = dados.get('senha')

        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("SELECT * FROM usuarios WHERE email = %s", (email,))
                    usuario = cursor.fetchone()
                    if usuario and checkpw(senha.encode('utf-8'), usuario['senha'].encode('utf-8')):
                        return jsonify({"status": "sucesso", "mensagem": "Login bem-sucedido!"}), 200
                    else:
                        return jsonify({"status": "erro", "mensagem": "Email ou senha incorretos."}), 401
            except Exception as e:
                return jsonify({"status": "erro", "mensagem": str(e)}), 500
            finally:
                connection.close()
        else:
            return jsonify({"status": "erro", "mensagem": "Erro ao conectar ao banco de dados."}), 500

    @app.route('/register', methods=['POST'])
    def register():
        dados = request.json
        nome = dados.get('nome')
        data_nascimento = dados.get('data_nascimento')
        genero = dados.get('genero')
        email = dados.get('email')
        senha = dados.get('senha')

        senha_hash = hashpw(senha.encode('utf-8'), gensalt()).decode('utf-8')

        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute(
                        "INSERT INTO usuarios (nome, data_nascimento, genero, email, senha) "
                        "VALUES (%s, %s, %s, %s, %s)",
                        (nome, data_nascimento, genero, email, senha_hash)
                    )
                connection.commit()
                return jsonify({"status": "sucesso", "mensagem": "Usuário registrado com sucesso!"}), 200
            except Exception as e:
                return jsonify({"status": "erro", "mensagem": str(e)}), 500
            finally:
                connection.close()
        else:
            return jsonify({"status": "erro", "mensagem": "Erro ao conectar ao banco de dados."}), 500

    @app.route('/forgetPassword', methods=['POST'])
    def forgetPassword():
        dados = request.json
        email = dados.get('email')

        if not email:
            return jsonify({"status":"erro", "mensagem": "O campo de e-mail é obrigatório"}), 400

        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("SELECT * FROM usuarios WHERE email = %s", (email,))
                    usuario = cursor.fetchone()

                    if not usuario:
                        return jsonify({"status":"erro", "mensagem":"E-mail não encontrado"}), 404

                    token = secrets.token_urlsafe(32)
                    expiracao = datetime.now() + timedelta(hours=1)

                    cursor.execute(
                        "UPDATE usuarios SET reset_token = %s, reset_token_expiracao = %s WHERE email = %s",
                        (token, expiracao, email)
                    )
                    connection.commit()

                    # Aqui você deveria implementar o envio do email
                    # com o token de redefinição

                    return jsonify({'status': "sucesso", "mensagem":"E-mail de redefinição enviado com sucesso!"}), 200
            except Exception as e:
                return jsonify({"status": "erro", "mensagem": str(e)}), 500
            finally:
                connection.close()
        else:
            return jsonify({"status": "erro", "mensagem": "Erro ao conectar ao banco de dados."}), 500

    @app.route("/saveResult", methods=['POST'])
    def save_result():
        try:
            # Obter dados do JSON
            dados = request.get_json()
            
            # Validação dos campos obrigatórios
            campos_obrigatorios = ['usuario_id', 'jogo', 'dificuldade', 'acertos', 'tempo_segundos']
            if not all(campo in dados for campo in campos_obrigatorios):
                return jsonify({'error': f'Campos obrigatórios: {", ".join(campos_obrigatorios)}'}), 400

            # Conexão com o banco
            conn = None
            try:
                conn = get_db_connection()
                if not conn:
                    return jsonify({'error': 'Erro ao conectar ao banco de dados'}), 500

                with conn.cursor() as cursor:
                    # Inserir os dados
                    cursor.execute(
                        """INSERT INTO desempenho 
                        (usuario_id, jogo, dificuldade, acertos, tempo_segundos, jogado_em) 
                        VALUES (%s, %s, %s, %s, %s, NOW())""",
                        (dados['usuario_id'], dados['jogo'], dados['dificuldade'], 
                        dados['acertos'], dados['tempo_segundos'])
                    )
                    conn.commit()

                return jsonify({'status': 'success', 'message': 'Dados salvos com sucesso'})

            except Exception as e:
                return jsonify({'error': str(e)}), 500
            finally:
                if conn: 
                    try:
                        conn.close()
                    except:
                        pass  

        except Exception as e:
            return jsonify({'error': 'Erro ao processar requisição'}), 500


init_routes(app)

if __name__ == '__main__':
    app.run(debug=True)