import 'package:flutter/material.dart';
import '../../classes/Verificacao.dart';
import '../../config/Network.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ListarVerificacao extends StatefulWidget {
  const ListarVerificacao({super.key});

  @override
  State<ListarVerificacao> createState() => _ListarVerificacaoState();
}

class _ListarVerificacaoState extends State<ListarVerificacao> {
  late Future<List<Verificacao>> _verificacoesFuture;

  // Guarda quais cards estão sendo processados
  final Set<String> _processando = {};

  @override
  void initState() {
    super.initState();
    _carregarVerificacoes();
  }

  Future<void> _carregarVerificacoes() async {
    setState(() {
      _verificacoesFuture = Verificacao.getAll();
      debugPrint("Carregando verificações..." + _verificacoesFuture.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Verificações",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/imagens/HCB_app-background.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          FutureBuilder<List<Verificacao>>(
            future: _verificacoesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar verificações: ${snapshot.error}',
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma verificação encontrada.',
                  ),
                );
              }

              final verificacoes = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: verificacoes.length,
                itemBuilder: (context, index) {
                  final verificacao = verificacoes[index];

                  // Identificador único para controlar o loading
                  final cardId =
                      '${verificacao.id_inventario}_${verificacao.num_artigo}';

                  final estaProcessando = _processando.contains(cardId);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Informações da verificação
                          Text(
                            verificacao.nome_artigo,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Artigo: ${verificacao.num_artigo}',
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Data de Registo: '
                            '${verificacao.data_registo.toLocal()}\nEstado: ${verificacao.isSynced == 1 ? "Sincronizado" : "Pendente"}',
                          ),

                          const SizedBox(height: 12),

                          // Botão para processar esta verificação
                          SizedBox(
                            width: double.infinity,
                            child: verificacao.isSynced == 1
                                ? ElevatedButton.icon(
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Sincronizado'),
                                  )
                                : ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: estaProcessando
                                          ? Colors.grey
                                          : Colors.blue[900],
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: estaProcessando
                                        ? null
                                        : () async {
                                            await processarVerificacao(
                                                verificacao.num_artigo
                                                    .toString(),
                                                verificacao.id_inventario
                                                    .toString(),
                                                cardId);
                                          },
                                    icon: estaProcessando
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.sync),
                                    label: Text(
                                      estaProcessando
                                          ? 'Processando...'
                                          : 'Processar',
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> processarVerificacao(
    String numArtigo,
    String idInventario,
    String cardId,
  ) async {
    // Ativar loading apenas neste card
    setState(() {
      _processando.add(cardId);
    });

    try {
      final url = Uri.parse(
        "http://$address_port/api/Artigo/updateAsset"
        "?numVelho=$numArtigo"
        "&codListt=$idInventario",
      );

      print("Chamando API: $url");

      final response =
          await http.post(url).timeout(const Duration(seconds: 10));

      print("Status: ${response.statusCode}");
      print("Resposta: ${response.body}");

      // Artigo não encontrado
      if (response.statusCode == 404) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Artigo não encontrado: $numArtigo',
            ),
          ),
        );

        return;
      }

      // Qualquer status diferente de 200 é tratado como erro
      if (response.statusCode != 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao processar o artigo: ${response.statusCode}',
            ),
          ),
        );

        return;
      }

      final body = jsonDecode(response.body);

      if (body["artigo"] == null) {
        throw Exception(
          "Resposta inválida do servidor: artigo não encontrado.",
        );
      }

      // Caso a API também devolva a verificação
      if (body["verificacao"] != null) {
        final verificacaoAtualizada =
            Verificacao.fromServerMap(body["verificacao"]);

        print(
          "Verificação processada: "
          "${verificacaoAtualizada.num_artigo}",
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Artigo $numArtigo processado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Verificacao.updateSyncStatus(idInventario, numArtigo, 1);
      // Se quiser atualizar a lista depois de processar:
      await _carregarVerificacoes();
    } on TimeoutException catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tempo limite excedido. Não foi possível contactar o servidor.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao processar a verificação: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Remover o loading deste card
      if (mounted) {
        setState(() {
          _processando.remove(cardId);
        });
      }
    }
  }
}
