from ..models.user_model import UserModel  # Importação relativa

class AuthView:
    @staticmethod
    def login(username, senha):
        if UserModel.verify_password(username, senha):
            return {"status": "sucesso", "mensagem": "Login bem-sucedido!"}
        else:
            return {"status": "erro", "mensagem": "Usuário ou senha incorretos"}

    @staticmethod
    def register(username, senha):
        if UserModel.add_user(username, senha):
            return {"status": "sucesso", "mensagem": "Usuário registrado com sucesso!"}
        else:
            return {"status": "erro", "mensagem": "Usuário já existe"}