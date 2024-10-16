import 'package:lista_compras_flutter/data/items_dao.dart';
import 'package:lista_compras_flutter/data/shoppinglist_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> getDataBase() async {
  final String path = join(await getDatabasesPath(), 'shoppinglist.db');
  return openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(ShoppingListDao.tableSql);
      db.execute(ItemsDao.tableSql);
    },
    version: 2,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Se precisar fazer upgrades, como adicionar tabelas ou campos
        await db.execute(ItemsDao.tableSql);
      }
    },
  );
}
