from flask import request, jsonify
from bcrypt import hashpw, gensalt
from bcrypt import checkpw
from db import get_db_connection  

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

if __name__ == '__main__':
    app.run(debug=True)

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