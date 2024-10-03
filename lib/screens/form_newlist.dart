import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:Lista_Compras_Flutter/components/shopping_list.dart';
import 'package:Lista_Compras_Flutter/data/shoppinglist_dao.dart';

class FormNewlist extends StatefulWidget {
  final BuildContext listContext;

  const FormNewlist({super.key, required this.listContext});

  @override
  State<FormNewlist> createState() => _FormNewlistState();
}

class _FormNewlistState extends State<FormNewlist> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameListController = TextEditingController();
  String? imagePath;
  int? selectedColorId;

  final ImagePicker _picker = ImagePicker();

  // Mapeamento de ID para cores
  final Map<int, Color> colorOptions = {
    1: Colors.red,
    2: Colors.green,
    3: Colors.blue,
    4: Colors.yellow,
    5: Colors.purple,
  };

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imagePath = pickedImage.path;
      });
    }
  }

  bool valueValidator(String? value) {
    if (value != null && value.isEmpty) {
      if (int.parse(value) > 5 || int.parse(value) < 1) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool difficultyValidator(String? value) {
    if (value != null && value.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            title: const Text(
              'Nova Lista',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                height: 575,
                width: 390,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 2)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: nameListController,
                        validator: (value) {
                          if (valueValidator(value)) {
                            return 'Insira um nome pra sua Lista';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Nome da Lista',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fillColor: Colors.white70,
                          filled: true,
                        ),
                      ),
                    ),
                    Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 2, color: Colors.blue)),
                        child: (imagePath != null)
                            ? Image.file(
                                File(imagePath!),
                                fit: BoxFit.cover,
                              )
                            : Image.asset('assets/images/noPhoto.png',
                                fit: BoxFit.cover)),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Selecione a Imagem'),
                        )),
                    // DropdownButton para seleção de cor
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Cor',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fillColor: Colors.white70,
                                  filled: true,
                                ),
                                value: selectedColorId,
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
                                    selectedColorId = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Selecione uma cor';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final DateTime now = DateTime.now();
                              final String formattedDate =
                                  DateFormat('dd/MM/yyyy HH:mm').format(now);
                              ShoppingListDao().save(ShoppingList(
                                null,
                                nameListController.text,
                                0,
                                selectedColorId!,
                                formattedDate,
                                imagePath,
                              ));

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Criando nova Lista')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text(
                            'Criar Lista',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
