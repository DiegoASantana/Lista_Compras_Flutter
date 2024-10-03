import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:Lista_Compras_Flutter/data/items_dao.dart';
import 'package:Lista_Compras_Flutter/data/shoppinglist_dao.dart';

class ShoppingList extends StatefulWidget {
  final int? idList;
  final String nameList;
  final int quantityItems;
  final int idColor;
  final String dateHour;
  final String? image;
  final VoidCallback? onDeleteList;
  final VoidCallback? onUpdateList;

  const ShoppingList(this.idList, this.nameList, this.quantityItems,
      this.idColor, this.dateHour, this.image,
      {this.onDeleteList, this.onUpdateList, super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final Map<int, Color> colorOptions = {
    1: Colors.red,
    2: Colors.green,
    3: Colors.blue,
    4: Colors.yellow,
    5: Colors.purple,
  };

  final ImagePicker _picker = ImagePicker();

  Future<void> _confirmDelete() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover'),
          content: const Text('Deseja remover esta lista?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirma
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
      await ShoppingListDao().delete(widget.idList!);
      if (widget.onDeleteList != null) {
        widget.onDeleteList!();
      }
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
                title: const Text('Editar Lista'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Excluir Lista'),
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
    String novoNomeLista = widget.nameList;
    int? novaCor = widget.idColor;
    String? novaFoto = widget.image;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Usando StatefulBuilder para atualizar o estado dentro do diálogo
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Editar Lista'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Campo para editar o nome da lista
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Nome da Lista'),
                      controller: TextEditingController(text: novoNomeLista),
                      onChanged: (value) {
                        novoNomeLista = value;
                      },
                    ),
                    const SizedBox(height: 8),
                    // Campo para editar a imagem
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 2, color: Colors.blue),
                      ),
                      child: (novaFoto != null)
                          ? Image.file(
                              File(novaFoto!),
                              fit: BoxFit.cover,
                            )
                          : Image.asset('assets/images/noPhoto.png',
                              fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final XFile? pickedImage = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (pickedImage != null) {
                          setState(() {
                            novaFoto = pickedImage
                                .path; // Atualiza a nova foto com o caminho selecionado
                          });
                        }
                      },
                      child: const Text('Selecionar Imagem'),
                    ),
                    // Dropdown para seleção de cor
                    SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Cor',
                              ),
                              value: novaCor,
                              items: colorOptions.entries.map((entry) {
                                return DropdownMenuItem<int>(
                                  alignment: Alignment.center,
                                  value: entry.key,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    color: entry.value,
                                  ),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  novaCor = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
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
                    if (novoNomeLista.isNotEmpty && novaCor != null) {
                      // Atualiza a lista com os novos valores
                      final DateTime now = DateTime.now();
                      final String formattedDate =
                          DateFormat('dd/MM/yyyy HH:mm').format(now);
                      await ShoppingListDao()
                          .update(widget.idList!,
                              newName: novoNomeLista,
                              newDateHours: formattedDate,
                              newColor: novaCor!)
                          .then((_) {
                        if (widget.onUpdateList != null) {
                          widget.onUpdateList!();
                        }
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Lista Alterada com Sucesso')),
                          ); // Fecha o diálogo após salvar
                        }
                      });
                    } else {
                      // Mostrar erro ou notificação
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Preencha todos os campos corretamente')),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showOptions,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                  color: colorOptions[widget.idColor],
                  borderRadius: BorderRadius.circular(5)),
            ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(5)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: (widget.image != null)
                                ? Image.file(
                                    File(widget.image!),
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset('assets/images/noPhoto.png',
                                    fit: BoxFit
                                        .cover)), // Corrigido para usar uma imagem padrão se vazio
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 200,
                              child: Text(
                                widget.nameList,
                                style: const TextStyle(
                                    fontSize: 20,
                                    overflow: TextOverflow.ellipsis),
                              )),
                          Text(widget.dateHour),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 35,
                          height: 35,
                          child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Remover'),
                                        content: const Text(
                                            'Deseja remover esta lista?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              await ItemsDao().deleteByIdList(
                                                  widget.idList!);
                                              await ShoppingListDao()
                                                  .delete(widget.idList!)
                                                  .then((_) {
                                                Navigator.pop(context, 'Sim');
                                                widget.onDeleteList!();
                                              });
                                            },
                                            child: const Text('Sim'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'Não');
                                            },
                                            child: const Text('Não'),
                                          )
                                        ],
                                      );
                                    });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                              ),
                              child: const Icon(Icons.delete)),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Qtd Items: ${widget.quantityItems}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
