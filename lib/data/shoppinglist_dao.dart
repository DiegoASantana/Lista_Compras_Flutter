import 'package:Lista_Compras_Flutter/Data/database.dart';
import 'package:Lista_Compras_Flutter/components/shopping_list.dart';
import 'package:sqflite/sqflite.dart';

class ShoppingListDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      '$_id INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$_nameList TEXT NOT NULL, '
      '$_qtyItems INTEGER NOT NULL, '
      '$_dateHours TEXT, ' // Armazenando como TEXT para o formato DATETIME
      '$_colorList INTEGER, '
      '$_image TEXT)';

  static const String _tableName = 'ShoppingList';
  static const String _id = 'SPL_IdList';
  static const String _nameList = 'SPL_NameList';
  static const String _qtyItems = 'SPL_QtyItems';
  static const String _colorList = 'SPL_IdColor';
  static const String _dateHours = 'SPL_DateHours';
  static const String _image = 'SPL_Image';

  save(ShoppingList aList) async {
    final Database bancoDados = await getDataBase();
    Map<String, dynamic> listMap = toMap(aList);
    return await bancoDados.insert(_tableName, listMap);
  }

  Future<List<ShoppingList>> findAll() async {
    final Database bancoDados = await getDataBase();
    final List<Map<String, dynamic>> result =
        await bancoDados.query(_tableName, orderBy: '$_dateHours DESC');
    return toList(result);
  }

  Future<List<ShoppingList>> findOneId(int aIdLista) async {
    final Database bancoDados = await getDataBase();
    final List<Map<String, dynamic>> result = await bancoDados.query(
      _tableName,
      where: '$_id = ?',
      whereArgs: [aIdLista],
    );
    return toList(result);
  }

  Future<int> update(int aIdList,
      {int? newQty,
      String? newName,
      int? newColor,
      String? newDateHours}) async {
    final Database bancoDados = await getDataBase();

    // Cria uma lista para armazenar os valores a serem atualizados
    final List<Object?> values = [];
    final StringBuffer query = StringBuffer('UPDATE $_tableName SET ');

    // Adiciona os campos a serem atualizados
    bool isFirst = true; // Variável para rastrear o primeiro campo

    if (newQty != null) {
      query.write('$_qtyItems = ?');
      values.add(newQty);
      isFirst =
          false; // Atualiza o status para que não adicione vírgula novamente
    }
    if (newName != null) {
      if (!isFirst) query.write(', ');
      query.write('$_nameList = ?');
      values.add(newName);
      isFirst = false;
    }
    if (newColor != null) {
      if (!isFirst) query.write(', ');
      query.write('$_colorList = ?');
      values.add(newColor);
      isFirst = false;
    }
    if (newDateHours != null) {
      if (!isFirst) query.write(', ');
      query.write('$_dateHours = ?');
      values.add(newDateHours);
    }

    // Verifica se pelo menos um campo foi passado
    if (values.isEmpty) {
      throw Exception('Nenhum parâmetro para atualizar.');
    }

    // Adiciona a condição WHERE
    query.write(' WHERE $_id = ?');
    values.add(aIdList); // Adiciona o ID da lista aos valores

    // Executa a atualização
    return await bancoDados.rawUpdate(
      query.toString(),
      values, // Define os parâmetros para evitar injeção de SQL
    );
  }

  delete(int aIdList) async {
    final Database bancoDados = await getDataBase();
    return bancoDados.delete(
      _tableName,
      where: '$_id = ?',
      whereArgs: [aIdList],
    );
  }

  Map<String, dynamic> toMap(ShoppingList aList) {
    final Map<String, dynamic> mapList = {};
    mapList[_id] = aList.idList;
    mapList[_nameList] = aList.nameList;
    mapList[_qtyItems] = aList.quantityItems;
    mapList[_colorList] = aList.idColor;
    mapList[_dateHours] = aList.dateHour;
    mapList[_image] = aList.image;

    return mapList;
  }

  List<ShoppingList> toList(List<Map<String, dynamic>> aListaCompras) {
    final List<ShoppingList> listas = [];
    for (Map<String, dynamic> linha in aListaCompras) {
      final ShoppingList lista = ShoppingList(
          linha[_id],
          linha[_nameList],
          linha[_qtyItems],
          linha[_colorList],
          linha[_dateHours],
          linha[_image]);

      listas.add(lista);
    }
    return listas;
  }
}
