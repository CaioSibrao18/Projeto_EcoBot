import 'package:flutter/material.dart';
import 'package:ecoquest/services/api_service.dart';

class AppTelalogin extends StatefulWidget {
  final IApiService apiService;

  const AppTelalogin({required this.apiService, super.key});

  @override
  State<AppTelalogin> createState() => _AppTelaloginState();
}

class _AppTelaloginState extends State<AppTelalogin> {
  final TextEditingController _controller = TextEditingController();
  String _mensagem = '';

  Future<void> _fazerLogin() async {
    final usuarioId = int.tryParse(_controller.text) ?? 0;
    final resposta = await widget.apiService.enviarResultado(
      usuarioId: usuarioId,
      acertos: 0,
      tempoSegundos: 0,
    );
    setState(() {
      _mensagem = resposta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          TextField(key: const Key('usuarioField'), controller: _controller),
          ElevatedButton(
            key: const Key('enviarButton'),
            onPressed: _fazerLogin,
            child: const Text('Enviar'),
          ),
          Text(_mensagem, key: const Key('mensagemText')),
        ],
      ),
    );
  }
}
