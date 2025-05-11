from flask import jsonify
from models.result_model import ResultModel
from datetime import datetime, timedelta
import numpy as np
from db import get_db_connection  
import traceback
import joblib
import os
from functools import lru_cache

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
            return joblib.load('eco_bot_model.pkl') if os.path.exists('eco_bot_model.pkl') else None
        except Exception as e:
            print(f"Erro ao carregar IA: {e}")
            return None

    @staticmethod
    def save_result(data):
   
        required_fields = ['usuario_id', 'acertos', 'tempo_segundos']
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Campos obrigatórios: usuario_id, acertos, tempo_segundos'}), 400

        try:
            success = ResultModel.save_result(
                usuario_id=int(data['usuario_id']),
                acertos=float(data['acertos']),
                tempo_segundos=int(data['tempo_segundos'])
            )
            return jsonify({'message': 'Resultado salvo com sucesso'}), 201 if success else \
                   jsonify({'error': 'Erro ao salvar resultado'}), 500
        except ValueError:
            return jsonify({'error': 'Dados inválidos'}), 400
        except Exception as e:
            return jsonify({'error': str(e)}), 500

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

                cursor.execute(query, params or None)
                results = cursor.fetchall()

                return {
                    'status': 'success',
                    'message': 'Dados recuperados com sucesso',
                    'results': results,
                    'count': len(results)
                }

        except Exception as e:
            return {
                'status': 'error',
                'message': f'Erro ao buscar resultados: {str(e)}',
                'results': [],
                'count': 0
            }
        finally:
            if conn:
                conn.close()

    @staticmethod
    def get_historical_data(usuario_id, weeks=12):
      
        try:
            conn = get_db_connection()
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT id, usuario_id, 
                           CAST(COALESCE(acertos, 0) AS DECIMAL(10,2)) as acertos,
                           CAST(COALESCE(tempo_segundos, 0) AS DECIMAL(10,2)) as tempo_segundos,
                           COALESCE(jogado_em, NOW()) as jogado_em,
                           CASE WHEN acertos > 0 THEN 100.0 ELSE 0.0 END as porcentagem,
                           CASE WHEN acertos > 0 THEN tempo_segundos/acertos ELSE 0.0 END as tempo_por_questao
                    FROM desempenho
                    WHERE usuario_id = %s AND jogado_em >= %s
                    ORDER BY jogado_em DESC
                """, (usuario_id, datetime.now() - timedelta(weeks=weeks)))
                return cursor.fetchall() or []
        except Exception as e:
            print(f"Erro ao buscar histórico: {e}")
            return []
        finally:
            if conn:
                conn.close()

    @staticmethod
    def _calculate_stats(data):
       
        if not data: return None
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
            if len(historical_data) < 2:
                return {"status": "info", "message": "Dados insuficientes"}, 200

            recent, older = historical_data[:2] 
            recent_stats = ResultController._calculate_stats([recent])
            older_stats = ResultController._calculate_stats([older])

            return {
                "status": "success",
                "analysis": {
                    "current_period": {**recent_stats, "start_date": (datetime.now() - timedelta(weeks=4)).strftime('%Y-%m-%d')},
                    "previous_period": older_stats,
                    "trends": {
                        "accuracy": round(((recent_stats['accuracy_avg'] - older_stats['accuracy_avg']) / older_stats['accuracy_avg']) * 100, 1) if older_stats['accuracy_avg'] != 0 else 0,
                        "speed": round(((recent_stats['speed_avg'] - older_stats['speed_avg']) / older_stats['speed_avg']) * 100, 1) if older_stats['speed_avg'] != 0 else 0,
                        "consistency": round(recent_stats['consistency'] - older_stats['consistency'], 1)
                    },
                    "feedback": ResultController._generate_feedback(recent_stats, older_stats)
                }
            }, 200
        except Exception as e:
            return {"error": str(e)}, 500

    @staticmethod
    def generate_feedback(usuario_id):
        return ResultController.generate_evolution_feedback(usuario_id)