from ..models.user_model import UserModel  

class AuthView:
    @staticmethod
    def login(email, senha):
        if UserModel.verify_password(email, senha):
            return {"status": "sucesso", "mensagem": "Login bem-sucedido!"}
        else:
            return {"status": "erro", "mensagem": "Usuário ou senha incorretos"}

    @staticmethod
    def register(nome, senha):
        if UserModel.add_user(nome, senha):
            return {"status": "sucesso", "mensagem": "Usuário registrado com sucesso!"}
        else:
            return {"status": "erro", "mensagem": "Usuário já existe"}