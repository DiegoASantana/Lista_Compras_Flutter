import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lista_compras_flutter/components/items.dart';
import 'package:lista_compras_flutter/components/shopping_list.dart';
import 'package:lista_compras_flutter/components/utilities_functions.dart';
import 'package:lista_compras_flutter/data/items_dao.dart';
import 'package:lista_compras_flutter/data/shoppinglist_dao.dart';
import 'package:lista_compras_flutter/screens/form_newlist.dart';
import 'package:lista_compras_flutter/screens/list_screen.dart';

class InitialScreen extends StatefulWidget {
  final bool
      isPremiumUser; // Adicione o parâmetro para receber o status premium

  const InitialScreen({super.key, required this.isPremiumUser});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  List<ShoppingList> allLists = [];

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    List<ShoppingList> lists = await ShoppingListDao().findAll();
    setState(() {
      allLists = lists;
    });
  }

  Future<void> _importList() async {
    if (!widget.isPremiumUser) {
      // Bloqueia o recurso se o usuário não for premium
      Dialogs.showPremiumRequiredDialog(context);
      return;
    }

    TextEditingController controller = TextEditingController();
    bool success = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Importar Lista'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Cole o JSON da lista aqui',
              border: OutlineInputBorder(),
            ),
            maxLines: 10,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancelar
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String input = controller.text;
                try {
                  // Parse o JSON
                  Map<String, dynamic> jsonData = jsonDecode(input);

                  // Extrair o nome da lista
                  String nameList = jsonData['nomeLista'];
                  int qtyItems = jsonData['QtdItens'];
                  int idColor = jsonData['IdColor'];
                  List<dynamic> itemsJson = jsonData['itens'];

                  // Gerar a data atual
                  String dateHour =
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

                  // Inserir a nova lista no banco de dados
                  int newListId = await ShoppingListDao().save(
                    ShoppingList(
                        null, nameList, qtyItems, idColor, dateHour, null),
                  );

                  // Inserir os itens no banco de dados
                  for (var itemJson in itemsJson) {
                    // Extrair os campos do item
                    String nomeItem = itemJson['_item'];
                    double qtdItem = (itemJson['_qty'] as num).toDouble();
                    double valorItem = (itemJson['_value'] as num).toDouble();
                    double valorTotalItem =
                        (itemJson['_totalValue'] as num).toDouble();
                    int orderItem = itemJson['_orderItem'];
                    bool isMarked = itemJson['_isMaked'];

                    // Criar uma instância de Item
                    Items newItem = Items(
                      idItem: null,
                      idList: newListId,
                      nomeItem: nomeItem,
                      qtdItem: qtdItem,
                      valorItem: valorItem,
                      valorTotalItem: valorTotalItem,
                      orderItem: orderItem,
                      isMarked: isMarked,
                    );

                    // Inserir o item no banco de dados
                    await ItemsDao().save(newItem);
                  }

                  success = true;
                  Navigator.pop(context); // Fechar diálogo
                } catch (e) {
                  // Tratar erro de parsing ou de inserção
                  setState(() {
                    _loadLists();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao importar lista: $e')),
                  );
                }
              },
              child: const Text('Importar'),
            ),
          ],
        );
      },
    );

    if (success) {
      setState(() {
        _loadLists();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista importada com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: Container(),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            onSelected: (int result) {
              if (result == 1) {
                _importList();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  title: Text('Importar Lista'),
                  dense: true, // Reduz o espaçamento vertical
                  contentPadding: EdgeInsets.zero, // Remove o padding padrão
                ),
              ),
            ],
          )
        ],
        title: const Text(
          'Listas de Compras',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.black12,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 70),
          child: (allLists.isEmpty)
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 128,
                      ),
                      Text(
                        'Não há nenhuma Lista',
                        style: TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: allLists.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ShoppingList list = allLists[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListScreen(
                              list.idList!,
                              nomeLista: list.nameList,
                              isPremiumUser: widget.isPremiumUser,
                            ),
                          ),
                        ).then((_) {
                          setState(() {
                            _loadLists();
                          });
                        });
                      },
                      child: ShoppingList(
                        list.idList,
                        list.nameList,
                        list.quantityItems,
                        list.idColor,
                        list.dateHour,
                        list.image,
                        onDeleteList: () {
                          setState(() {
                            _loadLists();
                          });
                        },
                        onUpdateList: () {
                          setState(() {
                            _loadLists();
                          });
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (contextNew) => FormNewlist(
                listContext: context,
              ),
            ),
          ).then((_) {
            setState(() {
              _loadLists();
            });
          });
        },
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }
}
