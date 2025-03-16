class UserModel:
    # Simulação de um banco de dados de usuários
    users = {
        "gabriel": {"senha": "senha123"},
    }

    @classmethod
    def get_user(cls, username):
        return cls.users.get(username)

    @classmethod
    def verify_password(cls, username, senha):
        user = cls.get_user(username)
        if user and user['senha'] == senha:
            return True
        return False

    @classmethod
    def add_user(cls, username, senha):
        if username in cls.users:
            return False  # Usuário já existe
        cls.users[username] = {"senha": senha}
        return True