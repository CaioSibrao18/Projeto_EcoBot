from flask import jsonify, request, current_app
from models.result_model import ResultModel
from datetime import datetime, timedelta

import pandas as pd 
from db import get_db_connection  
import joblib
import os
from functools import lru_cache
import traceback
from datetime import datetime
import warnings
from sklearn.exceptions import DataConversionWarning

warnings.filterwarnings(action='ignore', category=DataConversionWarning)

class ResultController:

   
    FEEDBACK_RULES = {
        'accuracy': [
            (85, 100, ["🎯 Excelente precisão!", "💡 Nível avançado!"]),
            (70, 84, ["👏 Bom desempenho!", "💡 Você está no caminho certo"]),
            (0, 69, ["📉 Foque nos fundamentos"])
        ],
        'speed': [
            (0, 5, ["⚡ Velocidade impressionante!"]),
            (6, 10, ["⏳ Bom ritmo"]),
            (11, 20, ["🐢 Pode melhorar o tempo"])
        ]
    }

    AI_FEEDBACK_MAP = {
        'excelente': ["🚀 Desempenho excepcional!", "💎 Você está entre os melhores!"],
        'bom': ["👍 Bom trabalho!", "📈 Continue evoluindo!"],
        'precisa_melhorar': ["✨ Potencial a ser explorado", "🔍 Foque em seus pontos fracos"]
    }

    @classmethod
    @lru_cache(maxsize=1)
    def _get_ai_model(cls):
        try:
            if os.path.exists('eco_bot_model.pkl'):
                model, le = joblib.load('eco_bot_model.pkl')
             
                if hasattr(model, 'predict') and hasattr(le, 'transform'):
                    return model, le
                print("Modelo ou LabelEncoder inválidos")
            return None, None
        except Exception as e:
            print(f"Erro ao carregar IA: {e}")
            return None, None



    @staticmethod
    def get_historical_data(usuario_id, weeks=12):
        conn = None
        try:
            conn = get_db_connection()
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT id, usuario_id, 
                        COALESCE(acertos, 0) as acertos,
                        COALESCE(tempo_segundos, 0) as tempo_segundos,
                        COALESCE(jogado_em, NOW()) as jogado_em,
                        COALESCE(acertos, 0) as porcentagem,
                        CASE WHEN acertos > 0 THEN tempo_segundos / acertos ELSE 0.0 END as tempo_por_questao
                    FROM desempenho
                    WHERE usuario_id = %s AND jogado_em >= %s
                    ORDER BY jogado_em DESC
                """, (usuario_id, datetime.now() - timedelta(weeks=weeks)))
                data = cursor.fetchall()

             
                for d in data:
                    if isinstance(d['jogado_em'], str):
                        d['jogado_em'] = datetime.strptime(d['jogado_em'], '%Y-%m-%d %H:%M:%S')

                return data or []
        except Exception as e:
            print(f"Erro ao buscar histórico: {e}")
            traceback.print_exc()
            return []
        finally:
            if conn:
                conn.close()



    @staticmethod
    def _calculate_stats(data):
        if not data:
            return None

        df = pd.DataFrame(data)
        acc = df['porcentagem']
        speed = df['tempo_por_questao']

        return {
            'accuracy_avg': round(acc.mean(), 2),
            'speed_avg': round(speed.mean(), 2),
            'consistency': round(acc.std(), 2),
            'best_score': round(acc.max(), 2),
            'count': len(df)
        }

    @staticmethod
    def _generate_feedback(recent_stats, older_stats):
        ai_model = ResultController._get_ai_model()
        if ai_model:
            try:
                features = [[
                    recent_stats['accuracy_avg'],
                    recent_stats['speed_avg'],
                    recent_stats['consistency']
                ]]
                prediction = ai_model.predict(features)[0]
                if prediction == 'excelente':
                    return ["🎯 Excelente desempenho via IA!", "⚡ Velocidade top!", "💡 Desafie-se!"]
                elif prediction == 'bom':
                    return ["👏 Bom trabalho via IA!", "⏳ Continue assim!"]
            except Exception as e:
                print(f"Erro na IA: {e}")

        feedback = []
        accuracy = recent_stats['accuracy_avg']
        
        for min_val, max_val, messages in ResultController.FEEDBACK_RULES['accuracy']:
            if min_val <= accuracy <= max_val:
                feedback.extend(messages)
                break
                
        speed = recent_stats['speed_avg']
        for min_val, max_val, messages in ResultController.FEEDBACK_RULES['speed']:
            if min_val <= speed <= max_val:
                feedback.extend(messages)
                break
                
        return feedback or ["📊 Continue praticando!"]

    @staticmethod
    def generate_evolution_feedback(usuario_id):
        try:
            historical_data = ResultController.get_historical_data(usuario_id)

            if not historical_data:
                return {
                    "status": "info",
                    "message": "Nenhum resultado encontrado",
                    "suggestion": "Complete um quiz para receber feedback"
                }, 200

            processed_data = []
            for d in historical_data:
                if 'porcentagem' not in d:
                    total = 10  # valor fixo conforme o banco
                    d['porcentagem'] = (d.get('acertos', 0) / total) * 100 if total > 0 else 0

                if 'tempo_por_questao' not in d:
                    d['tempo_por_questao'] = d.get('tempo_segundos', 0) / d.get('acertos', 1) if d.get('acertos', 0) > 0 else 0

                processed_data.append(d)

            # Ordena os dados do mais recente para o mais antigo
            processed_data = sorted(processed_data, key=lambda x: x['jogado_em'], reverse=True)

            # Pega o último resultado como recent_period (lista com 1 elemento)
            recent_period = processed_data[:1]

            # Pega o restante como older_period (todos os anteriores)
            older_period = processed_data[1:] if len(processed_data) > 1 else []

            recent_stats = ResultController._calculate_stats(recent_period)
            older_stats = ResultController._calculate_stats(older_period) if older_period else None

            rules_feedback = ResultController._generate_rules_feedback(recent_stats)
            ai_feedback = ResultController._generate_ai_feedback(recent_stats)

            combined_feedback = list(dict.fromkeys(rules_feedback + (ai_feedback['messages'] if ai_feedback else [])))

            response = {
                "current_period": recent_stats,
                "previous_period": older_stats,
                "trends": None,
                "feedback": combined_feedback,
                "feedback_detail": {
                    "rules": rules_feedback,
                    "ai": ai_feedback
                } if ai_feedback else None
            }

            if older_stats:
                response['trends'] = {
                    'accuracy': round(recent_stats['accuracy_avg'] - older_stats['accuracy_avg'], 2),
                    'speed': round(recent_stats['speed_avg'] - older_stats['speed_avg'], 2),
                    'consistency': round(recent_stats['consistency'] - older_stats['consistency'], 2)
                }

            return {"status": "success", "analysis": response}, 200

        except Exception as e:
            traceback.print_exc()
            return {"status": "error", "error": str(e)}, 500




    @staticmethod
    def _generate_ai_feedback(stats):
     
        if not stats:
            return None
            
        model, le = ResultController._get_ai_model()
        if not model or not le:
            return None
            
        try:
          
            features = pd.DataFrame([{
                'porcentagem': stats['accuracy_avg'],
                'tempo_segundos': stats['speed_avg'] * 10 
            }])

            prediction_encoded = model.predict(features)[0]
            prediction = le.inverse_transform([prediction_encoded])[0]
            
            return {
                'prediction': prediction,
                'messages': ResultController.AI_FEEDBACK_MAP.get(
                    prediction,
                    ["🤖 Análise: Seu desempenho foi avaliado"]
                ),
                'source': 'ai_model'
            }
        except Exception as e:
            print(f"Erro na predição IA: {e}")
            return None


    @staticmethod
    def _generate_rules_feedback(stats):
      
        if not stats:
            return []
            
        feedback = []
        accuracy = stats['accuracy_avg']
        
        for min_val, max_val, messages in ResultController.FEEDBACK_RULES['accuracy']:
            if min_val <= accuracy <= max_val:
                feedback.extend(messages)
                break
                
        speed = stats['speed_avg']
        for min_val, max_val, messages in ResultController.FEEDBACK_RULES['speed']:
            if min_val <= speed <= max_val:
                feedback.extend(messages)
                break
                
        return feedback or ["📊 Continue praticando!"]





    @staticmethod
    def _generate_feedback(recent_stats, older_stats=None):
   
        if older_stats is None and recent_stats.get('count', 0) == 1:
            accuracy = recent_stats['accuracy_avg']
            speed = recent_stats['speed_avg']
            
            feedback = []
            
          
            for min_val, max_val, messages in ResultController.FEEDBACK_RULES['accuracy']:
                if min_val <= accuracy <= max_val:
                    feedback.extend(messages)
                    break
                    
          
            for min_val, max_val, messages in ResultController.FEEDBACK_RULES['speed']:
                if min_val <= speed <= max_val:
                    feedback.extend(messages)
                    break
            
            return feedback or ["📊 Bom começo! Continue praticando!"]
        
     
        ai_model = ResultController._get_ai_model()
        if ai_model:
            try:
                features = [[
                    recent_stats['accuracy_avg'],
                    recent_stats['speed_avg'],
                    recent_stats['consistency']
                ]]
                prediction = ai_model.predict(features)[0]
                if prediction == 'excelente':
                    return ["🎯 Excelente desempenho via IA!", "⚡ Velocidade top!", "💡 Desafie-se!"]
                elif prediction == 'bom':
                    return ["👏 Bom trabalho via IA!", "⏳ Continue assim!"]
            except Exception as e:
                print(f"Erro na IA: {e}")

        feedback = []
        accuracy = recent_stats['accuracy_avg']
        
        for min_val, max_val, messages in ResultController.FEEDBACK_RULES['accuracy']:
            if min_val <= accuracy <= max_val:
                feedback.extend(messages)
                break
                
        speed = recent_stats['speed_avg']
        for min_val, max_val, messages in ResultController.FEEDBACK_RULES['speed']:
            if min_val <= speed <= max_val:
                feedback.extend(messages)
                break
                
        return feedback or ["📊 Continue praticando!"]

    @staticmethod
    def get_user_stats(usuario_id):
        conn = None
        try:
            conn = get_db_connection()
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT 
                        COUNT(*) AS total,
                        AVG(acertos) AS avg_accuracy,
                        AVG(tempo_segundos) AS avg_time
                    FROM desempenho
                    WHERE usuario_id = %s
                """, (usuario_id,))
                result = cursor.fetchone()
                return result
        except Exception as e:
            traceback.print_exc()
            return None
        finally:
            if conn:
                conn.close()


    @staticmethod
    def save_result(data):
        required_fields = ['usuario_id', 'acertos', 'tempo_segundos']
        
        if not all(field in data for field in required_fields):
            return {'error': 'Campos obrigatórios: usuario_id, acertos, tempo_segundos'}, 400

        try:
            success = ResultModel.save_result(
                usuario_id=int(data['usuario_id']),
                acertos=float(data['acertos']),
                tempo_segundos=int(data['tempo_segundos'])
            )
            
            if success:
                return {'message': 'Resultado salvo com sucesso'}, 201
            else:
                return {'error': 'Falha ao salvar no banco de dados'}, 500
                
        except ValueError as e:
            return {'error': f'Dados inválidos: {str(e)}'}, 400
        except Exception as e:
            traceback.print_exc()
            return {'error': f'Erro interno: {str(e)}'}, 500

    @staticmethod
    def get_results(usuario_id=None, limit=None):
        conn = None
        try:
            conn = get_db_connection()
            if not conn:
                return {
                    'status': 'error',
                    'message': 'Falha na conexão com o banco',
                    'results': [],
                    'count': 0
                }

            with conn.cursor() as cursor:
                query = """
                    SELECT 
                        id, usuario_id, acertos, tempo_segundos, jogado_em,
                        porcentagem, tempo_por_questao
                    FROM desempenho
                    {}
                    ORDER BY jogado_em DESC
                    {}
                """.format(
                    "WHERE usuario_id = %s" if usuario_id else "",
                    "LIMIT %s" if limit else ""
                )

                params = []
                if usuario_id:
                    params.append(usuario_id)
                if limit:
                    params.append(limit)

                cursor.execute(query, tuple(params) if params else None)
                results = cursor.fetchall()

                return {
                    'status': 'success',
                    'message': 'Dados recuperados com sucesso',
                    'results': results,
                    'count': len(results)
                }

        except Exception as e:
            traceback.print_exc()
            return {
                'status': 'error',
                'message': f'Erro ao buscar resultados: {str(e)}',
                'results': [],
                'count': 0
            }
        finally:
            if conn:
                conn.close()
