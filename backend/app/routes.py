from flask import request, jsonify
from bcrypt import hashpw, gensalt
from bcrypt import checkpw
from db import get_db_connection  
from flask_mail import Mail, Message
import secrets
from datetime import datetime, timedelta


def init_routes(app):
    @app.route('/')
    def home():
        return jsonify({"mensagem": "Bem-vindo à API de login!"})


        app.config['MAIL_SERVER'] = 'smtp.example.com'
        app.config['MAIL_PORT'] = 587
        app.config['MAIL_USE_TLS'] = True
        app.config['MAIL_USERNAME'] = 'gabriel.freire@sou.unifeob.edu.br'
        app.config['MAIL_PASSWORD'] = 'freire159'
        mail = Mail(app)



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


    @app.route('/forgetPassword', methods=['POST'])
    def forgetPassword():
        dados = request.json
        email = dados.get('email')

        if not email:
            return jsonify({"status":"erro", "mensagem": "O campo de e-mail é obrigatorio"}), 404

            connection = get_db_connection()
            if connection:
                try:
                    with connection.cursor() as cursor:
                        cursor.execute("SELECT * FROM usuarios WHERE email = %s", (email,))
                        usuario = cursor.fetchone()

                        if not usuario:
                            return jsonify({"status":"erro", "mensagem":"E-mail nao encontrado" }),404

                        token = secrets.token_urlsafe(32)
                        expiracao = datetime.now() + timedelta(hours=1)

                        cursor.execute(
                            "UPDATE usuarios SET reset_token = %s, reset_token_expiracao = WHERE email = %s"(token, expiracao, email)

                        )
                        connection.commit()

                        link = f"https://seusite.com/redefinir-senha?token={token}"
                        msg = Message(
                            subject="Redefinição de Senha",
                            sender="seu_email@example.com",
                            recipients=[email]
                            )

                        msg.body = f"Clique no link abaixo para redefinir sua senha:\n{link}"
                        mail.send(msg)

                        return jsonify({'status': "sucesso", "mensagem":"E=mail de redefinição enviado com sucesso!"}),200
                except Exception as e:
                    return jsonify({"status": "erro", "mensagem": str(e)}), 500
                finally:
                    connection.close()
            else:
                return jsonify({"status": "erro", "mensagem": "Erro ao conectar ao banco de dados."}), 500



