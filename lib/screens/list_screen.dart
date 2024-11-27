import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:lista_compras_flutter/components/banners_ad.dart';
import 'package:lista_compras_flutter/components/items.dart';
import 'package:lista_compras_flutter/components/utilities_functions.dart';
import 'package:lista_compras_flutter/data/items_dao.dart';
import 'package:lista_compras_flutter/data/shoppinglist_dao.dart';

class ListScreen extends StatefulWidget {
  final String nomeLista;
  final int idList;
  final bool isPremiumUser;

  const ListScreen(this.idList,
      {super.key, required this.nomeLista, required this.isPremiumUser});

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
  Future<void> _addItem(String nome, double qtd, double valor) async {
    final int orderItem = await ItemsDao().findOrderItemMax(widget.idList);
    final int qtdItemsAtualizado;
    Items newItem = Items(
      idItem: null,
      idList: widget.idList,
      nomeItem: nome,
      qtdItem: qtd,
      valorItem: valor,
      valorTotalItem: qtd * valor,
      orderItem: orderItem,
      isMarked: false,
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

  Future<void> _reorderItems(int oldIndex, int newIndex) async {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      // Move o item dentro da lista localmente
      final item = allItems.removeAt(oldIndex);
      allItems.insert(newIndex, item);
    });

    final itemsDao = ItemsDao();

    // Atualiza a ordem dos itens no banco de dados
    for (int i = 0; i < allItems.length; i++) {
      final item = allItems[i];
      // Atualiza o campo ITM_OrderItem com base no novo índice
      await itemsDao.update(
        item.idItem!,
        aOrdemItem: i + 1, // A nova ordem do item será seu índice + 1
      );
    }

    // Recarrega os itens após a atualização
    _loadItems();
  }

  Future<void> _confirmZerar(int aIdParam) async {
    if (!widget.isPremiumUser) {
      // Bloqueia o recurso se o usuário não for premium
      Dialogs.showPremiumRequiredDialog(context);
      return;
    }
    String msg = '';
    String msgSnackBar = '';
    if (aIdParam == 1) {
      msg = 'Deseja zerar todos os Valores?';
      msgSnackBar = 'Zerando todos os valores...';
    }
    if (aIdParam == 2) {
      msg = 'Resetar todas as Quantidades?';
      msgSnackBar = 'Resetando todas as quantidades...';
    } else if (aIdParam == 3) {
      msg = 'Deseja zerar todos Valores e resetar todas as Quantidades?';
      msgSnackBar = 'Zerando todos os valores e resetando as quantidades...';
    }
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zerar'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Não confirma
              },
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirma
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msgSnackBar)),
                );
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ItemsDao()
          .updateResetValuesByIdList(widget.idList, aIdParam)
          .then((_) {
        setState(() {
          _loadItems();
        });
      });
    }
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
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert), // Ícone de três pontinhos
            onSelected: (int result) {
              _confirmZerar(result);
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
                  title: Text('Resetar Valores'),
                  dense: true, // Reduz o espaçamento vertical
                  contentPadding: EdgeInsets.zero, // Remove o padding padrão
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  title: Text('Resetar Quantidades'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: ListTile(
                  leading: Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  title: Text('Resetar Tudo'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: Container(
          color: Colors.white30,
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
              : ReorderableListView.builder(
                  itemCount: allItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Items item = allItems[index];
                    return Items(
                      key: Key('$index'),
                      idItem: item.idItem,
                      idList: item.idList,
                      nomeItem: item.nomeItem,
                      qtdItem: item.qtdItem,
                      valorItem: item.valorItem,
                      valorTotalItem: item.valorTotalItem,
                      orderItem: item.orderItem,
                      isMarked: item.isMarked,
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
                  onReorder: _reorderItems,
                ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatarValor(totalValor),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const BannerAdWidget(), // Adicionado abaixo do bottomNavigationBar
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          FocusNode nomeItemFocusNode = FocusNode();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String nomeItem = '';
              double quantidadeItem = 1;
              double valorItem = 0.0;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                FocusScope.of(context).requestFocus(nomeItemFocusNode);
              });

              return AlertDialog(
                title: const Text('Adicionar Item'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration:
                            const InputDecoration(labelText: 'Nome do Item'),
                        onChanged: (value) {
                          nomeItem = value;
                        },
                        textCapitalization: TextCapitalization.sentences,
                        focusNode: nomeItemFocusNode,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration:
                            const InputDecoration(labelText: 'Quantidade'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          quantidadeItem = double.tryParse(value) ?? 1;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration:
                            const InputDecoration(labelText: 'Valor Unitário'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          CurrencyInputFormatter(
                            leadingSymbol: 'R\$',
                            useSymbolPadding: true,
                            thousandSeparator: ThousandSeparator.Period,
                          ),
                        ],
                        onChanged: (value) {
                          value = value.replaceFirst('R\$ ', '');
                          value = value.replaceAll('.', '');
                          valorItem =
                              double.tryParse(value.replaceAll(',', '.')) ??
                                  0.0;
                        },
                      ),
                    ],
                  ),
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
              );
            },
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
