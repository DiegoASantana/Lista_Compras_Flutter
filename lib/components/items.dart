// arquivo: lib/components/items.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lista_compras_flutter/components/shopping_list.dart';
import 'package:lista_compras_flutter/data/items_dao.dart';
import '../data/shoppinglist_dao.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class Items extends StatefulWidget {
  final int? idItem;
  final int idList;
  final String nomeItem;
  final double qtdItem;
  final double valorItem;
  final double valorTotalItem;
  final int orderItem;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;

  const Items({this.idItem, required this.idList, required this.nomeItem, required this.qtdItem,
      required this.valorItem, required this.valorTotalItem, required this.orderItem,
      super.key, this.onUpdate, this.onDelete});

  factory Items.fromMap(Map<String, dynamic> map) {
    return Items(
      idItem: map['_idItem'],
      idList: map['_idList'],
      nomeItem: map['_item'],
      qtdItem: (map['_qty'] as num).toDouble(),
      valorItem: (map['_value'] as num?)?.toDouble() ?? 0.0,
      valorTotalItem: (map['_totalValue'] as num?)?.toDouble() ?? 0.0,
      orderItem: map['_orderItem'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_idItem': idItem,
      '_idList': idList,
      '_item': nomeItem,
      '_qty': qtdItem,
      '_value': valorItem,
      '_totalValue': valorTotalItem,
      '_orderItem': orderItem,
    };
  }

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  String nomeLista = 'Carregando...';
  late double quantidade;
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

  @override
  void didUpdateWidget(covariant Items oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.qtdItem != oldWidget.qtdItem ||
        widget.valorItem != oldWidget.valorItem ||
        widget.valorTotalItem != oldWidget.valorTotalItem) {
      setState(() {
        quantidade = widget.qtdItem;
        valorUnitario = widget.valorItem;
        valorTotal = widget.valorTotalItem;
        _valorController.text = valorUnitario.toStringAsFixed(2);
      });
    }
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
    ItemsDao()
        .update(
      widget.idItem!,
      aNameItem: widget.nomeItem,
      aQtdItem: quantidade,
      aValueUnit: valorUnitario,
      aValueTotal: valorUnitario * quantidade,
      aOrdemItem: widget.orderItem,
    )
        .then((_) {
      if (widget.onUpdate != null) {
        widget.onUpdate!();
      }
    });
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

  Future<void> _showDialogNameItem() async {
    String nomeItemCompleto = widget.nomeItem;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(nomeItemCompleto),
          );
        });
  }

  Future<void> _showEditDialog() async {
    String novoNome = widget.nomeItem;
    double novaQuantidade = quantidade;
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
                  textCapitalization: TextCapitalization.sentences,
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
                      TextEditingController(text: '${(novaQuantidade % 1 == 0) ? novaQuantidade.toInt() : novaQuantidade}'),
                  onChanged: (value) {
                    novaQuantidade = double.tryParse(value) ?? novaQuantidade;
                  },
                ),
                const SizedBox(height: 8),
                // Campo para editar o valor unitário
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Valor Unitário'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    CurrencyInputFormatter(
                      leadingSymbol: 'R\$',
                      useSymbolPadding: true,
                      thousandSeparator: ThousandSeparator.Period,
                      mantissaLength: 2,
                    ),
                  ],
                  controller: TextEditingController(
                      text: formatarValor(novoValorUnitario)),
                  onChanged: (value) {
                    value = value.replaceFirst('R\$ ', '');
                    value = value.replaceAll('.', '');
                    double? parsed =
                        double.tryParse(value.replaceAll(',', '.'));
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
                  await ItemsDao()
                      .update(
                    widget.idItem!,
                    aNameItem: novoNome,
                    aQtdItem: novaQuantidade,
                    aValueUnit: novoValorUnitario,
                    aValueTotal: novaQuantidade * novoValorUnitario,
                    aOrdemItem: widget.orderItem,
                  )
                      .then((_) {
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
    return Container(
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
            child: InkWell(
              onTap: _showDialogNameItem,
              child: Text(
                widget.nomeItem,
                style: const TextStyle(
                    fontSize: 20, overflow: TextOverflow.ellipsis),
                maxLines: 3,
              ),
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
                  '${(quantidade % 1 == 0) ? quantidade.toInt() : quantidade.toStringAsFixed(2)}',
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
          // Valor Total
          SizedBox(
            width: 90,
            child: Text(
              formatarValor(valorTotal),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert), // Ícone de três pontinhos
            onSelected: (String result) {
              // Ação quando uma opção for selecionada
              if (result == 'Editar') {
                _showEditDialog();
              } else if (result == 'Remover') {
                _confirmDelete();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Editar',
                child: Text('Editar'),
              ),
              const PopupMenuItem<String>(
                value: 'Remover',
                child: Text('Remover'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
