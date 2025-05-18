from flask import jsonify, request, current_app
from models.result_model import ResultModel
from datetime import datetime, timedelta
import numpy as np
from db import get_db_connection  
import joblib
import os
from functools import lru_cache
import traceback

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

    @classmethod
    @lru_cache(maxsize=1)
    def _get_ai_model(cls):
        try:
            if os.path.exists('eco_bot_model.pkl'):
                return joblib.load('eco_bot_model.pkl')
            else:
                print("Modelo IA não encontrado.")
                return None
        except Exception as e:
            print(f"Erro ao carregar IA: {e}")
            return None

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

    from datetime import datetime

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

                # Garantir que jogado_em é datetime para cada registro
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
        acc = [d['porcentagem'] for d in data]
        speed = [d['tempo_por_questao'] for d in data]
        return {
            'accuracy_avg': round(np.mean(acc), 2),
            'speed_avg': round(np.mean(speed), 2),
            'consistency': round(np.std(acc), 2),
            'best_score': round(max(acc), 2),
            'count': len(data)
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

            # Verificação se existem dados
            if not historical_data:
                return {
                    "status": "info",
                    "message": "Nenhum resultado encontrado",
                    "suggestion": "Complete um quiz para receber feedback"
                }, 200

            # Processa os dados para garantir campos necessários
            processed_data = []
            for d in historical_data:
                # Calcula porcentagem se não existir
                if 'porcentagem' not in d:
                    total_questoes = d.get('total_questoes', d.get('acertos', 1))
                    d['porcentagem'] = (d.get('acertos', 0) / total_questoes) * 100 if total_questoes > 0 else 0
                
                # Calcula tempo por questão se não existir
                if 'tempo_por_questao' not in d:
                    d['tempo_por_questao'] = d.get('tempo_segundos', 0) / d.get('acertos', 1) if d.get('acertos', 0) > 0 else 0
                
                processed_data.append(d)

            # Caso tenha apenas 1 quiz
            if len(processed_data) == 1:
                single_result = processed_data[0]
                feedback = []
                
                # Feedback baseado na precisão
                accuracy = single_result['porcentagem']
                for min_val, max_val, messages in ResultController.FEEDBACK_RULES['accuracy']:
                    if min_val <= accuracy <= max_val:
                        feedback.extend(messages)
                        break
                        
                # Feedback baseado na velocidade
                speed = single_result['tempo_por_questao']
                for min_val, max_val, messages in ResultController.FEEDBACK_RULES['speed']:
                    if min_val <= speed <= max_val:
                        feedback.extend(messages)
                        break
                
                return {
                    "status": "success",
                    "analysis": {
                        "current_period": {
                            "accuracy_avg": round(accuracy, 2),
                            "speed_avg": round(speed, 2),
                            "consistency": 0,  # Não há como calcular consistência com 1 ponto
                            "best_score": round(accuracy, 2),
                            "count": 1
                        },
                        "feedback": feedback or ["📊 Bom começo! Continue praticando!"],
                        "message": "Feedback baseado no seu primeiro quiz"
                    }
                }, 200

            # Restante do código original para quando há mais de 1 quiz...
            now = datetime.now()
            four_weeks_ago = now - timedelta(weeks=4)
            eight_weeks_ago = now - timedelta(weeks=8)

            recent_period = [d for d in processed_data if d['jogado_em'] >= four_weeks_ago]
            older_period = [d for d in processed_data if eight_weeks_ago <= d['jogado_em'] < four_weeks_ago]

            recent_stats = ResultController._calculate_stats(recent_period)
            older_stats = ResultController._calculate_stats(older_period) if older_period else None

            feedback = ResultController._generate_feedback(recent_stats, older_stats or {})

            analysis = {
                "current_period": recent_stats,
                "previous_period": older_stats,
                "trends": None,
                "feedback": feedback
            }

            if older_stats:
                trends = {
                    'accuracy': round(recent_stats['accuracy_avg'] - older_stats['accuracy_avg'], 2),
                    'speed': round(recent_stats['speed_avg'] - older_stats['speed_avg'], 2),
                    'consistency': round(recent_stats['consistency'] - older_stats['consistency'], 2)
                }
                analysis['trends'] = trends

            return {"status": "success", "analysis": analysis}, 200

        except Exception as e:
            traceback.print_exc()
            return {
                "error": f"Erro na análise: {str(e)}",
                "status": "error"
            }, 500





    @staticmethod
    def _generate_feedback(recent_stats, older_stats=None):
        # Se for um único quiz (older_stats é None e count é 1)
        if older_stats is None and recent_stats.get('count', 0) == 1:
            accuracy = recent_stats['accuracy_avg']
            speed = recent_stats['speed_avg']
            
            feedback = []
            
            # Feedback de precisão
            for min_val, max_val, messages in ResultController.FEEDBACK_RULES['accuracy']:
                if min_val <= accuracy <= max_val:
                    feedback.extend(messages)
                    break
                    
            # Feedback de velocidade
            for min_val, max_val, messages in ResultController.FEEDBACK_RULES['speed']:
                if min_val <= speed <= max_val:
                    feedback.extend(messages)
                    break
            
            return feedback or ["📊 Bom começo! Continue praticando!"]
        
        # Restante da lógica original para múltiplos quizzes...
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
