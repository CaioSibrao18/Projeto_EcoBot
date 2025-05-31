# 🌱 App Educacional sobre Sustentabilidade

Este é um aplicativo desenvolvido com **Flutter**, **Python (Flask)** e **MySQL**, com integração de **Inteligência Artificial** (RandomForestClassifier), voltado para **auxiliar psicopedagogos a acompanhar o desenvolvimento de crianças com deficiência intelectual** por meio de jogos educativos sobre sustentabilidade.

## Funcionalidades

- Tela de login, recuperação de senha com token por e-mail
- 6 jogos educativos:
  - Coleta Seletiva (Fácil e Difícil)
  - Soletrar por Sílabas (Fácil) e por Letras (Difícil)
  - Quiz sobre Sustentabilidade (Fácil e Difícil)
- Feedback com IA ao final dos jogos, avaliando:
  - Tempo de resposta
  - Quantidade de acertos
  - Evolução em relação à tentativa anterior

---

##  Como rodar o projeto na sua máquina

### Pré-requisitos

- [Python 3.8+](https://www.python.org/downloads/)
- [Flutter](https://flutter.dev/docs/get-started/install)
- [MySQL Workbench](https://www.mysql.com/products/workbench/)

---

### Passo a passo

# CLONE O REPOSITÓRIO
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio

# CONFIGURE O .env DO BACKEND
# (Abra o arquivo backend/.env e troque a senha do banco pela sua senha MySQL)
# Exemplo:
# DB_PASSWORD=sua_senha_mysql

# INSTALE AS DEPENDÊNCIAS DO BACKEND (IA)
cd backend

pip install cryptography
pip install flask
pip install bcrypt
pip install pymysql
pip install flask-sqlalchemy
pip install flask-login
pip install python-dotenv
pip install pandas
pip install scikit-learn
pip install joblib
python -m pip install flask-cors

# (Se necessário, reinicie o computador)

# INICIE O BACKEND
cd backend
python app/app.py

# EM OUTRO TERMINAL, INICIE O FLUTTER
cd flutter
flutter run

# ESCOLHA O EMULADOR/PLATAFORMA
# CRIE UMA CONTA NO APP PARA ACESSAR OS JOGOS

# PRONTO! O PROJETO ESTÁ FUNCIONANDO NORMALMENTE.
