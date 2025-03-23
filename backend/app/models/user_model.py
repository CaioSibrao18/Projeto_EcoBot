from db import db
from bcrypt import hashpw, gensalt, checkpw

class UserModel(db.Model):
    __tablename__ = 'usuarios'

    id = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(100), nullable=False)
    data_nascimento = db.Column(db.Date, nullable=False)
    genero = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    senha = db.Column(db.String(100), nullable=False)

    @classmethod
    def find_by_email(cls, email):
        return cls.query.filter_by(email=email).first()

    @classmethod
    def create_user(cls, nome, data_nascimento, genero, email, senha):
     
        senha_hash = hashpw(senha.encode('utf-8'), gensalt()).decode('utf-8')
        novo_usuario = cls(
            nome=nome,
            data_nascimento=data_nascimento,
            genero=genero,
            email=email,
            senha=senha_hash
        )
        db.session.add(novo_usuario)
        db.session.commit()
        return novo_usuario

    @staticmethod
    def verify_password(senha_hash, senha):
        return checkpw(senha.encode('utf-8'), senha_hash.encode('utf-8'))