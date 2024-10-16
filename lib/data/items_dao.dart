import 'package:lista_compras_flutter/Data/database.dart';
import 'package:lista_compras_flutter/components/items.dart';
import 'package:sqflite/sqflite.dart';

class ItemsDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      '$_idItem INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$_idList INTEGER, ' // Foreign Key para ShoppingList
      '$_item TEXT NOT NULL, '
      '$_qty REAL NOT NULL, '
      '$_value REAL, '
      '$_totalValue REAL, '
      '$_orderItem INTEGER NOT NULL, '
      'FOREIGN KEY($_idList) REFERENCES  ShoppingList(SPL_IdList))';

  static const String _tableName = 'Items';
  static const String _idItem = 'ITM_IdItem';
  static const String _idList = 'ITM_IdList';
  static const String _item = 'ITM_Item';
  static const String _qty = 'ITM_Qty';
  static const String _value = 'ITM_Value';
  static const String _totalValue = 'ITM_TotalValue';
  static const String _orderItem = 'ITM_OrderItem';

  save(Items aItem) async {
    final Database bancoDados = await getDataBase();
    final Map<String, dynamic> itemMap = toMap(aItem);
    return await bancoDados.insert(_tableName, itemMap);
  }

  Future<List<Items>> findAllByIdList(int aIdList) async {
    final Database bancoDados = await getDataBase();
    final List<Map<String, dynamic>> result = await bancoDados.query(_tableName,
        where: '$_idList = ?', whereArgs: [aIdList], orderBy: _orderItem);
    return toList(result);
  }

  Future<List<Items>> findOneId(int aIdItem) async {
    final Database bancoDados = await getDataBase();
    final List<Map<String, dynamic>> result = await bancoDados.query(
      _tableName,
      where: '$_idItem = ?',
      whereArgs: [aIdItem],
    );
    return toList(result);
  }

  Future<int> findQtd(int aIdList) async {
    final Database bancoDados = await getDataBase();

    // Fazendo a consulta com COUNT para contar a quantidade de itens na lista
    final List<Map<String, dynamic>> result = await bancoDados.rawQuery(
      'SELECT COUNT(*) as total FROM $_tableName WHERE $_idList = ?',
      [aIdList],
    );

    // Retorna o total de itens da lista
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  Future<int> findOrderItemMax(int aIdList) async {
    final Database bancoDados = await getDataBase();
    final List<Map<String, dynamic>> result = await bancoDados.rawQuery(
        'SELECT MAX($_orderItem)+1 AS ordem FROM $_tableName WHERE $_idList = ?',
        [aIdList]);

    // Retorna o Max + 1 do campo OrderItem
    int maxIncrement = Sqflite.firstIntValue(result) ?? 1;
    return maxIncrement;
  }

  delete(int aIdItem) async {
    final Database bancoDados = await getDataBase();
    return await bancoDados.delete(
      _tableName,
      where: '$_idItem = ?',
      whereArgs: [aIdItem],
    );
  }

  deleteByIdList(int aIdList) async {
    final Database bancoDados = await getDataBase();
    return await bancoDados.delete(
      _tableName,
      where: '$_idList = ?',
      whereArgs: [aIdList],
    );
  }

  updateResetValuesByIdList(int aIdList, aIdParams) async {
    final Database bancoDados = await getDataBase();
    final List<Object?> values = [];
    final StringBuffer query = StringBuffer('UPDATE $_tableName SET ');

    if(aIdParams == 1){
      query.write('$_value = 0, $_totalValue = 0');
    }else if(aIdParams == 2){
      query.write('$_qty = 1, $_totalValue = 0');
    }else if(aIdParams == 3){
      query.write('$_value = 0, $_qty = 1, $_totalValue = 0');
    }

    query.write(' WHERE $_idList = ?');
    values.add(aIdList);

    return await bancoDados.rawUpdate(
      query.toString(),
      values, // Define os parâmetros para evitar injeção de SQL
    );
  }

  Future<int> update(int aIdItem,
      {String? aNameItem,
      double? aQtdItem,
      double? aValueUnit,
      double? aValueTotal,
      int? aOrdemItem}) async {
    final Database bancoDados = await getDataBase();

    // Cria uma lista para armazenar os valores a serem atualizados
    final List<Object?> values = [];
    final StringBuffer query = StringBuffer('UPDATE $_tableName SET ');

    // Adiciona os campos a serem atualizados
    bool isFirst = true; // Variável para rastrear o primeiro campo

    if (aNameItem != null) {
      query.write('$_item = ?');
      values.add(aNameItem);
      isFirst =
          false; // Atualiza o status para que não adicione vírgula novamente
    }
    if (aQtdItem != null) {
      if (!isFirst) query.write(', ');
      query.write('$_qty = ?');
      values.add(aQtdItem);
      isFirst = false;
    }
    if (aValueUnit != null) {
      if (!isFirst) query.write(', ');
      query.write('$_value = ?');
      values.add(aValueUnit);
      isFirst = false;
    }
    if (aValueTotal != null) {
      if (!isFirst) query.write(', ');
      query.write('$_totalValue = ?');
      values.add(aValueTotal);
    }
    if (aOrdemItem != null) {
      if (!isFirst) query.write(', ');
      query.write('$_orderItem = ?');
      values.add(aOrdemItem);
    }

    // Verifica se pelo menos um campo foi passado
    if (values.isEmpty) {
      throw Exception('Nenhum parâmetro para atualizar.');
    }

    // Adiciona a condição WHERE
    query.write(' WHERE $_idItem = ?');
    values.add(aIdItem); // Adiciona o ID da lista aos valores

    // Executa a atualização
    return await bancoDados.rawUpdate(
      query.toString(),
      values, // Define os parâmetros para evitar injeção de SQL
    );
  }

  Map<String, dynamic> toMap(Items aItem) {
    final Map<String, dynamic> itemMap = {};
    itemMap[_idItem] = aItem.idItem;
    itemMap[_idList] = aItem.idList;
    itemMap[_item] = aItem.nomeItem;
    itemMap[_qty] = aItem.qtdItem;
    itemMap[_value] = aItem.valorItem;
    itemMap[_totalValue] = aItem.valorTotalItem;
    itemMap[_orderItem] = aItem.orderItem;
    return itemMap;
  }

  List<Items> toList(List<Map<String, dynamic>> aItemsMap) {
    final List<Items> listItems = [];
    for (var linha in aItemsMap) {
      final Items item = Items(idItem: linha[_idItem], idList: linha[_idList], nomeItem: linha[_item],
          qtdItem: linha[_qty], valorItem: linha[_value], valorTotalItem: linha[_totalValue], orderItem: linha[_orderItem]);
      listItems.add(item);
    }
    return listItems;
  }
}
