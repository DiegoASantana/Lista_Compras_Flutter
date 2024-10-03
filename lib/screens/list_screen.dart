import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Lista_Compras_Flutter/components/items.dart';
import 'package:Lista_Compras_Flutter/data/items_dao.dart';
import 'package:Lista_Compras_Flutter/data/shoppinglist_dao.dart';

class ListScreen extends StatefulWidget {
  final String nomeLista;
  final int idList;

  const ListScreen(this.idList, {super.key, required this.nomeLista});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Items> allItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  String formatarValor(double valorTotal) {
    final NumberFormat formato =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formato.format(valorTotal);
  }

  // Método para carregar os itens da lista específica
  Future<void> _loadItems() async {
    List<Items> listItems = await ItemsDao().findAllByIdList(widget.idList);
    setState(() {
      allItems = listItems;
    });
  }

  // Método para adicionar um novo item
  Future<void> _addItem(String nome, int qtd, double valor) async {
    final int qtdItemsAtualizado;
    Items newItem = Items(
      null,
      widget.idList,
      nome,
      qtd,
      valor,
      qtd * valor,
    );
    await ItemsDao().save(newItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Novo item adicionado...')),
      );
    }

    _loadItems();
    qtdItemsAtualizado = allItems.length + 1;
    await _updateQtdItemsList(qtdItemsAtualizado);
  }

  // Atualiza a quantidade de itens na lista
  Future<void> _updateQtdItemsList(int qtdItemsUpdt) async {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);
    await ShoppingListDao().update(widget.idList,
        newQty: qtdItemsUpdt, newDateHours: formattedDate);
  }

  // Função para calcular o valor total da compra
  double get totalValor {
    return allItems.fold(0.0, (sum, item) => sum + (item.valorTotalItem));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nomeLista,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 30),
            onPressed: () {
              setState(() {
                _loadItems();
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 70),
        child: Container(
          color: Colors.black12,
          width: double.infinity,
          height: double.infinity,
          child: (allItems.isEmpty)
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 128,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Não há nenhum Item',
                        style: TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: allItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Items item = allItems[index];
                    return Items(
                      item.idItem,
                      item.idList,
                      item.nomeItem,
                      item.qtdItem,
                      item.valorItem,
                      item.valorTotalItem,
                      onUpdate: () {
                        setState(() {
                          _loadItems();
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _updateQtdItemsList(allItems.length - 1);
                          _loadItems();
                        });
                      },
                    );
                  },
                ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          border: const Border(
            top: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Itens: ${allItems.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              formatarValor(totalValor),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String nomeItem = '';
              int quantidadeItem = 1;
              double valorItem = 0.0;

              return SingleChildScrollView(
                child: AlertDialog(
                  title: const Text('Adicionar Item'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration:
                            const InputDecoration(labelText: 'Nome do Item'),
                        onChanged: (value) {
                          nomeItem = value;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration:
                            const InputDecoration(labelText: 'Quantidade'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          quantidadeItem = int.tryParse(value) ?? 1;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration:
                            const InputDecoration(labelText: 'Valor Unitário'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (value) {
                          value = value.replaceAll('.', '');
                          valorItem =
                              double.tryParse(value.replaceAll(',', '.')) ??
                                  0.0;
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (nomeItem.isNotEmpty && quantidadeItem > 0) {
                          _addItem(nomeItem, quantidadeItem, valorItem);
                          Navigator.pop(context,
                              true); // Retorna um resultado para indicar a atualização
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Preencha todos os campos corretamente')),
                          );
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
