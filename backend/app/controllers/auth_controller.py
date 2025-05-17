from venv import logger
from flask import jsonify, make_response
from models.user_model import UserModel
import smtplib
from email.mime.text import MIMEText
import os
import random
import string
from datetime import datetime, timedelta
import secrets
import numpy as np 
from db import get_users


class AuthController:

    @staticmethod
    def login(email, senha):
        try:
            logger.info(f"Tentativa de login: {email}")
            
            if not email or not senha:
                logger.warning("Email ou senha vazios")
                return {
                    "status": "erro", 
                    "mensagem": "Credenciais inválidas"
                }, 401

            usuario = UserModel.find_by_email(email)
            if not usuario:
                logger.warning(f"Usuário não encontrado: {email}")
                return {
                    "status": "erro", 
                    "mensagem": "Credenciais inválidas"
                }, 401
            
            if not UserModel.verify_password(usuario['senha'], senha):
                logger.warning("Senha não confere")
                return {
                    "status": "erro", 
                    "mensagem": "Credenciais inválidas"
                }, 401
                
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
            return {
                "status": "erro", 
                "mensagem": "Erro interno",
                "details": str(e)
            }, 500
        
    @staticmethod
    def register(nome, data_nascimento, genero, email, senha):
        try:
            if not all([nome, data_nascimento, genero, email, senha]):
                return {"status": "erro", "mensagem": "Todos os campos são obrigatórios"}, 400

            if len(senha) < 6:
                return {"status": "erro", "mensagem": "Senha deve ter pelo menos 6 caracteres"}, 400

            if UserModel.email_exists(email):
                return {"status": "erro", "mensagem": "Email já cadastrado"}, 409

            user_id = UserModel.create_user(
                nome=nome,
                data_nascimento=data_nascimento,
                genero=genero,
                email=email,
                senha=senha
            )
            
            if user_id:
                if os.getenv('SMTP_USER'):
                    AuthController._send_welcome_email(email, nome)
                
                return {
                    "status": "sucesso",
                    "mensagem": "Usuário registrado com sucesso!",
                    "dados": {
                        "id": user_id,
                        "email": email
                    }
                }, 201  
            
            return {"status": "erro", "mensagem": "Falha ao criar usuário"}, 400
                
        except Exception as e:
            logger.error(f"ERRO NO REGISTRO: {str(e)}")
            return {"status": "erro", "mensagem": "Erro interno no servidor", "details": str(e)}, 500


    @staticmethod
    def _send_welcome_email(email, nome):
     
        try:
            msg = MIMEText(f"""
            <h1>Bem-vindo(a) ao nosso serviço, {nome}!</h1>
            <p>Sua conta foi criada com sucesso.</p>
            <p>Aproveite todos os recursos disponíveis.</p>
            """, 'html')
            
            msg['Subject'] = 'Bem-vindo ao nosso serviço!'
            msg['From'] = os.getenv('SMTP_FROM', 'no-reply@seusite.com')
            msg['To'] = email
            
            with smtplib.SMTP(os.getenv('SMTP_SERVER', 'smtp.gmail.com'), 
                             int(os.getenv('SMTP_PORT', 587))) as server:
                server.starttls()
                server.login(os.getenv('SMTP_USER'), os.getenv('SMTP_PASSWORD'))
                server.send_message(msg)
                
            return True
        except Exception as e:
            logger.error(f"Erro ao enviar email de boas-vindas: {e}")
            return False

    @staticmethod
    def _send_reset_code_email(email, code):
 
        try:
            msg = MIMEText(f"""
            <h1>Recuperação de Senha</h1>
            <p>Você solicitou a redefinição de senha.</p>
            <p>Seu código de verificação é: <strong>{code}</strong></p>
            <p>Este código é válido por 15 minutos.</p>
            <p>Se você não solicitou esta alteração, por favor ignore este e-mail.</p>
            """, 'html')
            
            msg['Subject'] = 'Código de Recuperação de Senha'
            msg['From'] = os.getenv('SMTP_FROM', 'no-reply@seusite.com')
            msg['To'] = email
            
            with smtplib.SMTP(os.getenv('SMTP_SERVER', 'smtp.gmail.com'), 
                             int(os.getenv('SMTP_PORT', 587))) as server:
                server.starttls()
                server.login(os.getenv('SMTP_USER'), os.getenv('SMTP_PASSWORD'))
                server.send_message(msg)
                
            return True
        except Exception as e:
            logger.error(f"Erro ao enviar email de recuperação: {e}")
            return False

    @staticmethod
    def forget_password(email):
        try:
            if not email:
                return {"status": "erro", "mensagem": "Email é obrigatório"}, 400

            
            user = UserModel.find_by_email(email.lower().strip())
            if not user:
          
                return {
                    "status": "sucesso",
                    "mensagem": "Se este email estiver cadastrado, você receberá um código de recuperação"
                }, 200

          
            reset_code = ''.join(random.choices(string.digits, k=6))
            expiration = datetime.now() + timedelta(minutes=15)

          
            if not UserModel.create_password_reset_code(
                user_id=user['id'],
                code=reset_code,
                expires_at=expiration
            ):
                return {"status": "erro", "mensagem": "Erro ao gerar código de recuperação"}, 500

           
            if os.getenv('SMTP_USER'):
                if not AuthController._send_reset_code_email(email, reset_code):
                    return {"status": "erro", "mensagem": "Erro ao enviar e-mail de recuperação"}, 500
            else:
               
                logger.info(f"Código de recuperação para {email}: {reset_code}")

            return {
                "status": "sucesso",
                "mensagem": "Se este email estiver cadastrado, você receberá um código de recuperação",
                "debug_code": reset_code if os.getenv('FLASK_ENV') == 'development' else None
            }, 200
            
        except Exception as e:
            logger.error(f"ERRO EM forget_password: {str(e)}")
            return {"status": "erro", "mensagem": "Erro ao processar solicitação"}, 500

    @staticmethod
    def validate_reset_code(email, code):
        try:
            if not email or not code:
                return {"status": "erro", "mensagem": "Email e código são obrigatórios"}, 400

           
            user = UserModel.find_by_email(email.lower().strip())
            if not user:
                return {"status": "erro", "mensagem": "Código inválido"}, 400

            is_valid = UserModel.validate_reset_code(
                user_id=user['id'],
                code=code.strip()
            )

            if not is_valid:
                return {"status": "erro", "mensagem": "Código inválido ou expirado"}, 400
                
            
            reset_token = UserModel.generate_reset_token(user['id'])
            if not reset_token:
                return {"status": "erro", "mensagem": "Erro ao gerar token de redefinição"}, 500

            return {
                "status": "sucesso",
                "mensagem": "Código válido",
                "reset_token": reset_token
            }, 200
        except Exception as e:
            logger.error(f"ERRO AO VALIDAR CÓDIGO: {str(e)}")
            return {"status": "erro", "mensagem": "Erro ao validar código"}, 500

    @staticmethod
    def reset_password(email, token, nova_senha):
        user = UserModel.find_by_email(email)
        
        if not user:
            return {"success": False, "error": "Usuário não encontrado."}
        
        if not UserModel.validate_reset_code(user['id'], token):
            return {"success": False, "error": "Token inválido ou expirado."}
        
        sucesso = UserModel.reset_password_with_token(token, nova_senha)
        
        if not sucesso:
            return {"success": False, "error": "Erro ao redefinir a senha."}
        
        return {"success": True, "message": "Senha redefinida com sucesso."}
    

    @staticmethod
    def get_users(user_id=None, page=None, per_page=None):
        try:
            users = get_users(user_id, page, per_page)
            
            if user_id:  
                if not users:
                    return {"error": "Usuário não encontrado"}, 404
                return {"success": True, "user": users}, 200
            
            else:
                if not users:
                    return {"message": "Nenhum usuário encontrado"}, 404
                return {
                    "success": True,
                    "count": len(users),
                    "users": users
                }, 200
                
        except Exception as e:
            error_msg = "Erro ao buscar usuário" if user_id else "Erro ao listar usuários"
            return {"error": error_msg, "details": str(e)}, 500