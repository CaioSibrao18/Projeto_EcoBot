import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from db import get_db_connection  

TOTAL_QUESTOES = 10  
def load_training_data():
    conn = get_db_connection()

    query = """
    SELECT
        (acertos / %s) * 100 AS porcentagem,
        tempo_segundos,
        CASE
            WHEN (acertos / %s) * 100 >= 90 THEN 'excelente'
            WHEN (acertos / %s) * 100 >= 70 THEN 'bom'
            ELSE 'precisa_melhorar'
        END AS label
    FROM desempenho
    WHERE acertos IS NOT NULL;
    """

    try:
        with conn.cursor() as cursor:
            cursor.execute(query, (TOTAL_QUESTOES, TOTAL_QUESTOES, TOTAL_QUESTOES))
            results = cursor.fetchall()

        data = pd.DataFrame(results, columns=['porcentagem', 'tempo_segundos', 'label'])

        data['porcentagem'] = pd.to_numeric(data['porcentagem'], errors='coerce')
        data['tempo_segundos'] = pd.to_numeric(data['tempo_segundos'], errors='coerce')
        data.dropna(inplace=True)

        print("🔍 Amostra dos dados de treinamento:")
        print(data.head())

        return data

    finally:
        conn.close()

def train_model():
    data = load_training_data()

    X = data[['porcentagem', 'tempo_segundos']]
    y = data['label']

    le = LabelEncoder()
    y_encoded = le.fit_transform(y)

    X_train, X_test, y_train, y_test = train_test_split(X, y_encoded, test_size=0.2, random_state=42)

    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)

    joblib.dump((model, le), 'eco_bot_model.pkl')
    print("✅ Modelo treinado e salvo como eco_bot_model.pkl")

if __name__ == '__main__':
    train_model()
