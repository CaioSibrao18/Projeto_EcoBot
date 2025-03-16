import os

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'uma-chave-secreta-muito-segura')
    DEBUG = True