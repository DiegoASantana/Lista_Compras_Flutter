// arquivo: lib/components/items.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:Lista_Compras_Flutter/components/shopping_list.dart';
import 'package:Lista_Compras_Flutter/data/items_dao.dart';
import '../data/shoppinglist_dao.dart';

class Items extends StatefulWidget {
  final int? idItem;
  final int idList;
  final String nomeItem;
  final int qtdItem;
  final double valorItem;
  final double valorTotalItem;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;

  const Items(this.idItem, this.idList, this.nomeItem, this.qtdItem,
      this.valorItem, this.valorTotalItem,
      {super.key, this.onUpdate, this.onDelete});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  String nomeLista = 'Carregando...';
  late int quantidade;
  late double valorUnitario;
  late double valorTotal;

  final TextEditingController _valorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNomeLista();
    quantidade = widget.qtdItem;
    valorUnitario = widget.valorItem;
    valorTotal = widget.valorTotalItem;
    _valorController.text = valorUnitario.toStringAsFixed(2);
  }

  String formatarValor(double valorTotal) {
    final NumberFormat formato =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formato.format(valorTotal);
  }

  Future<void> _loadNomeLista() async {
    List<ShoppingList> lista = await ShoppingListDao().findOneId(widget.idList);
    if (lista.isNotEmpty) {
      setState(() {
        nomeLista = lista.first.nameList;
      });
    } else {
      setState(() {
        nomeLista = 'Lista não encontrada';
      });
    }
  }

  Future<void> _updateItem() async {
    Items updatedItem = Items(
      widget.idItem,
      widget.idList,
      widget.nomeItem,
      quantidade,
      valorUnitario,
      valorUnitario * quantidade,
    );

    await ItemsDao().save(updatedItem);
    if (widget.onUpdate != null) {
      widget.onUpdate!();
    }
  }

  void _incrementQuantity() {
    setState(() {
      quantidade += 1;
      valorTotal = quantidade * valorUnitario;
    });
    _updateItem();
  }

  void _decrementQuantity() {
    if (quantidade > 1) {
      setState(() {
        quantidade -= 1;
        valorTotal = quantidade * valorUnitario;
      });
      _updateItem();
    }
  }

  Future<void> _showOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Excluir'),
                onTap: () async {
                  Navigator.pop(context);
                  await _confirmDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog() async {
    String novoNome = widget.nomeItem;
    int novaQuantidade = quantidade;
    double novoValorUnitario = valorUnitario;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Campo para editar o nome do item
                TextField(
                  decoration: const InputDecoration(labelText: 'Nome do Item'),
                  controller: TextEditingController(text: novoNome),
                  onChanged: (value) {
                    novoNome = value;
                  },
                ),
                const SizedBox(height: 8),
                // Campo para editar a quantidade
                TextField(
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                  controller:
                      TextEditingController(text: novaQuantidade.toString()),
                  onChanged: (value) {
                    novaQuantidade = int.tryParse(value) ?? novaQuantidade;
                  },
                ),
                const SizedBox(height: 8),
                // Campo para editar o valor unitário
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Valor Unitário'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: TextEditingController(
                      text: novoValorUnitario
                          .toStringAsFixed(2)
                          .replaceAll('.', ',')),
                  onChanged: (value) {
                    double? parsed = double.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      novoValorUnitario = parsed;
                    } else {
                      novoValorUnitario = 0;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo sem salvar
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (novoNome.isNotEmpty && novaQuantidade > 0) {
                  // Atualiza o item com os novos valores
                  Items updatedItem = Items(
                    widget.idItem,
                    widget.idList,
                    novoNome,
                    novaQuantidade,
                    novoValorUnitario,
                    novaQuantidade * novoValorUnitario,
                  );
                  await ItemsDao().save(updatedItem).then((_) {
                    if (widget.onUpdate != null) {
                      widget.onUpdate!();
                    }
                    if (mounted) {
                      Navigator.pop(context); // Fecha o diálogo após salvar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item Alterado')),
                      );
                    }
                  }); // Fecha o diálogo após salvar
                } else {
                  // Mostrar erro ou notificação
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Preencha todos os campos corretamente')),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover'),
          content: const Text('Deseja remover este item da lista?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirma
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Removendo Item...')),
                );
              },
              child: const Text('Sim'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Não confirma
              },
              child: const Text('Não'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ItemsDao().delete(widget.idItem!);
      if (widget.onDelete != null) {
        widget.onDelete!();
      }
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showOptions, // Detecta o long press
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Nome do Item
            Expanded(
              flex: 3,
              child: Text(
                widget.nomeItem,
                style: const TextStyle(
                    fontSize: 20, overflow: TextOverflow.ellipsis),
              ),
            ),
            SizedBox(
              width: 130,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove,
                      size: 16,
                    ),
                    onPressed: _decrementQuantity,
                  ),
                  Text(
                    '$quantidade',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      size: 16,
                    ),
                    onPressed: _incrementQuantity,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Valor Total
            SizedBox(
              width: 90,
              child: Text(
                formatarValor(valorTotal),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
