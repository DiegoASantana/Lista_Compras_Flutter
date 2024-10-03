import 'package:flutter/material.dart';
import 'package:Lista_Compras_Flutter/components/shopping_list.dart';
import 'package:Lista_Compras_Flutter/data/shoppinglist_dao.dart';
import 'package:Lista_Compras_Flutter/screens/form_newlist.dart';
import 'package:Lista_Compras_Flutter/screens/list_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: Container(),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _loadLists();
              });
            },
            icon: const Icon(Icons.refresh, size: 30),
          )
        ],
        title: const Text(
          'Listas de Compras',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.black12, // Cor do fundo para todo o body
        width: double.infinity, // Preencher toda a largura
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
                        // Navegar para o ListScreen e passar o nome da lista clicada
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListScreen(
                              list.idList!,
                              nomeLista:
                                  list.nameList, // Passando o nome da lista
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
                            _loadLists(); // Recarrega a lista de itens após a exclusão
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
