import 'package:lista_compras_flutter/data/items_dao.dart';
import 'package:lista_compras_flutter/data/shoppinglist_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> getDataBase() async {
  final String path = join(await getDatabasesPath(), 'shoppinglist.db');
  return openDatabase(
    path,
    onCreate: (db, version) {
      // Criação inicial do banco na versão 1
      db.execute(ShoppingListDao.tableSql);
      db.execute(ItemsDao.tableSql);
    },
    version: 3,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Alterações específicas da versão 2
        await db.execute('ALTER TABLE Items ADD COLUMN isMarked INTEGER DEFAULT 0');
      }
    },
  );
}
