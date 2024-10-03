import 'package:Lista_Compras_Flutter/Data/database.dart';
import 'package:Lista_Compras_Flutter/components/items.dart';
import 'package:sqflite/sqflite.dart';

class ItemsDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      '$_idItem INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$_idList INTEGER, ' // Foreign Key para ShoppingList
      '$_item TEXT NOT NULL, '
      '$_qty INTEGER NOT NULL, '
      '$_value REAL, '
      '$_totalValue REAL, '
      'FOREIGN KEY($_idList) REFERENCES  ShoppingList(SPL_IdList))';

  static const String _tableName = 'Items';
  static const String _idItem = 'SLI_IdItem';
  static const String _idList = 'SLI_IdList';
  static const String _item = 'SLI_Item';
  static const String _qty = 'SLI_Qty';
  static const String _value = 'SLI_Value';
  static const String _totalValue = 'SLI_TotalValue';

  save(Items aItem) async {
    final Database bancoDados = await getDataBase();
    final Map<String, dynamic> itemMap = toMap(aItem);
    if (aItem.idItem == null) {
      return await bancoDados.insert(_tableName, itemMap);
    } else {
      return await bancoDados.update(
        _tableName,
        itemMap,
        where: '$_idItem = ?',
        whereArgs: [aItem.idItem],
      );
    }
  }

  Future<List<Items>> findAllByIdList(int aIdList) async {
    final Database bancoDados = await getDataBase();
    final List<Map<String, dynamic>> result = await bancoDados
        .query(_tableName, where: '$_idList = ?', whereArgs: [aIdList]);
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

  Map<String, dynamic> toMap(Items aItem) {
    final Map<String, dynamic> itemMap = {};
    itemMap[_idItem] = aItem.idItem;
    itemMap[_idList] = aItem.idList;
    itemMap[_item] = aItem.nomeItem;
    itemMap[_qty] = aItem.qtdItem;
    itemMap[_value] = aItem.valorItem;
    itemMap[_totalValue] = aItem.valorTotalItem;
    return itemMap;
  }

  List<Items> toList(List<Map<String, dynamic>> aItemsMap) {
    final List<Items> listItems = [];
    for (var linha in aItemsMap) {
      final Items item = Items(
        linha[_idItem],
        linha[_idList],
        linha[_item],
        linha[_qty],
        linha[_value],
        linha[_totalValue],
      );
      listItems.add(item);
    }
    return listItems;
  }
}
