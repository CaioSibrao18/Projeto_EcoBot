import pandas as pd
from backend.app.db import get_db_connection
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
import joblib

def load_training_data():

    conn = get_db_connection()
    
    try:
        query = """
        SELECT 
            (acertos / total_questoes) * 100 as porcentagem,
            tempo_segundos,
            CASE
                WHEN (acertos / total_questoes) >= 0.9 THEN 'excelente'
                WHEN (acertos / total_questoes) >= 0.7 THEN 'bom'
                ELSE 'precisa_melhorar'
            END as label
        FROM desempenho
        WHERE total_questoes > 0
        """
        
        data = pd.read_sql(query, conn)
        return data
    
    finally:
        if conn:
            conn.close()

def train_model():
    data = load_training_data()
    
    if len(data) < 30:
        print(f"Apenas {len(data)} registros disponíveis. Mínimo recomendado: 30")
        return None
    
    X = data[['porcentagem', 'tempo_segundos']]
    y = data['label']
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    model = RandomForestClassifier(n_estimators=150, max_depth=5)
    model.fit(X_train, y_train)
    
    accuracy = model.score(X_test, y_test)
    print(f"Acurácia do modelo: {accuracy:.2f}")
    print("\nExemplos de previsão:")
    print("Porcentagem | Tempo | Previsão")
    for i in range(5):
        sample = X_test.iloc[i]
        print(f"{sample['porcentagem']:.1f}% | {sample['tempo_segundos']:.1f}s | {model.predict([sample])[0]}")
    
    joblib.dump(model, 'eco_bot_model.pkl')
    print("\nModelo treinado e salvo com sucesso!")
    return model

if __name__ == '__main__':
    train_model()
