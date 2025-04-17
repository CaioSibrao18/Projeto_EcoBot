from venv import logger
from flask import jsonify
from models.user_model import UserModel
import smtplib
from email.mime.text import MIMEText
import os

class AuthController:

    @staticmethod
    def login(email, senha):
        try:
            logger.info(f"Tentativa de login: {email}")
            
            if not email or not senha:
                logger.warning("Email ou senha vazios")
                return {"status": "erro", "mensagem": "Credenciais inválidas"}, 401

            usuario = UserModel.find_by_email(email)
            if not usuario:
                logger.warning(f"Usuário não encontrado: {email}")
                return {"status": "erro", "mensagem": "Credenciais inválidas"}, 401
            
            logger.debug(f"Usuário encontrado: {usuario['email']}")
            logger.debug(f"Hash no banco: {usuario['senha']}")
            
            if not UserModel.verify_password(usuario['senha'], senha):
                logger.warning("Senha não confere")
                return {"status": "erro", "mensagem": "Credenciais inválidas"}, 401
                
            logger.info("Login bem-sucedido")
            return {
                "status": "sucesso",
                "mensagem": "Login bem-sucedido!",
                "usuario": {
                    "id": usuario['id'],
                    "nome": usuario['nome'],
                    "email": usuario['email']
                }
            }, 200
            
        except Exception as e:
            logger.error(f"Erro no login: {e}")
            return {"status": "erro", "mensagem": "Erro interno"}, 500
        
    @staticmethod
    def register(nome, data_nascimento, genero, email, senha):
        try:
          
            if not all([nome, data_nascimento, genero, email, senha]):
                return jsonify({
                    "status": "erro",
                    "mensagem": "Todos os campos são obrigatórios"
                }), 400

            if len(senha) < 6:
                return jsonify({
                    "status": "erro",
                    "mensagem": "Senha deve ter pelo menos 6 caracteres"
                }), 400

            if UserModel.email_exists(email):
                return jsonify({
                    "status": "erro",
                    "mensagem": "Email já cadastrado"
                }), 409

            user_id = UserModel.create_user(
                nome=nome,
                data_nascimento=data_nascimento,
                genero=genero,
                email=email,
                senha=senha
            )
            
            if user_id:
                return jsonify({
                    "status": "sucesso",
                    "mensagem": "Usuário registrado com sucesso!",
                    "dados": {
                        "id": user_id,
                        "email": email
                    }
                }), 201
            
            return jsonify({
                "status": "erro",
                "mensagem": "Falha ao criar usuário"
            }), 400
                
        except Exception as e:
            print(f"ERRO NO REGISTRO: {str(e)}")
            return jsonify({
                "status": "erro",
                "mensagem": "Erro interno no servidor"
            }), 500

    @staticmethod
    def _send_reset_email(email, token):
      
        try:
            reset_link = f"{os.getenv('FRONTEND_URL', 'http://localhost:3000')}/reset-password?token={token}"
            
            msg = MIMEText(f"""
            <h1>Redefinição de Senha</h1>
            <p>Clique no link abaixo para redefinir sua senha:</p>
            <a href="{reset_link}">Redefinir Senha</a>
            <p>O link expira em 1 hora.</p>
            """, 'html')
            
            msg['Subject'] = 'Redefinição de Senha'
            msg['From'] = os.getenv('SMTP_FROM', 'no-reply@seusite.com')
            msg['To'] = email
            
            with smtplib.SMTP(os.getenv('SMTP_SERVER', 'smtp.gmail.com'), 
                             int(os.getenv('SMTP_PORT', 587))) as server:
                server.starttls()
                server.login(os.getenv('SMTP_USER'), os.getenv('SMTP_PASSWORD'))
                server.send_message(msg)
                
            return True
        except Exception as e:
            print(f"Erro ao enviar email: {e}")
            return False

    @staticmethod
    def forget_password(email):
     
        try:
            if not email:
                return jsonify({
                    "status": "erro",
                    "mensagem": "Email é obrigatório"
                }), 400

  
            if not UserModel.find_by_email(email):
                return jsonify({
                    "status": "sucesso",
                    "mensagem": "Se este email estiver cadastrado, você receberá um link de redefinição"
                }), 200

            token = UserModel.initiate_password_reset(email)
            if not token:
                return jsonify({
                    "status": "erro",
                    "mensagem": "Erro ao gerar token de redefinição"
                }), 500

            if not AuthController._send_reset_email(email, token):
                return jsonify({
                    "status": "erro",
                    "mensagem": "Erro ao enviar email de redefinição"
                }), 500
                
            return jsonify({
                "status": "sucesso",
                "mensagem": "Se este email estiver cadastrado, você receberá um link de redefinição"
            }), 200
            
        except Exception as e:
            print(f"ERRO EM forget_password: {str(e)}")
            return jsonify({
                "status": "erro",
                "mensagem": "Erro ao processar solicitação"
            }), 500

    @staticmethod
    def validate_reset_token(token):

        try:
            if not token:
                return jsonify({
                    "status": "erro",
                    "mensagem": "Token é obrigatório"
                }), 400

            if not UserModel.validate_reset_token(token):
                return jsonify({
                    "status": "erro",
                    "mensagem": "Token inválido ou expirado"
                }), 400
                
            return jsonify({
                "status": "sucesso",
                "mensagem": "Token válido"
            }), 200
        except Exception as e:
            print(f"ERRO AO VALIDAR TOKEN: {str(e)}")
            return jsonify({
                "status": "erro",
                "mensagem": "Erro ao validar token"
            }), 500

    @staticmethod
    def reset_password(token, nova_senha):
    
        try:
            if not token or not nova_senha:
                return jsonify({
                    "status": "erro",
                    "mensagem": "Token e nova senha são obrigatórios"
                }), 400

            if len(nova_senha) < 6:
                return jsonify({
                    "status": "erro",
                    "mensagem": "Senha deve ter pelo menos 6 caracteres"
                }), 400

            if not UserModel.reset_password(token, nova_senha):
                return jsonify({
                    "status": "erro",
                    "mensagem": "Token inválido ou expirado"
                }), 400
                
            return jsonify({
                "status": "sucesso",
                "mensagem": "Senha redefinida com sucesso"
            }), 200
            
        except Exception as e:
            print(f"ERRO EM reset_password: {str(e)}")
            return jsonify({
                "status": "erro",
                "mensagem": "Erro ao redefinir senha"
            }), 500