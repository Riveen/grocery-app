import 'package:grocery_app/models/item_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/users.dart';

class DatabaseHelper {
  final databaseName = "item.db";
  String itemTable =
      "CREATE TABLE items (itemId INTEGER PRIMARY KEY AUTOINCREMENT, itemTitle TEXT NOT NULL, itemPrice TEXT NOT NULL, itemImage TEXT NOT NULL, colorValue INTEGER)";

  String usersTable =
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, usrPassword TEXT)";
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: ((db, version) async {
      await db.execute(usersTable);
      await db.execute(itemTable);
    }));
  }

  // login method
  Future<bool> login(Users user) async {
    final Database db = await initDB();

    var result = await db.rawQuery(
        "SELECT * FROM users WHERE usrName = '${user.usrName}' AND usrPassword = '${user.usrPassword}'");
    // check whether result is empty
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // sign up method
  Future<int> signup(Users user) async {
    final Database db = await initDB();

    return db.insert("users", user.toMap());
  }

  // CRUD Methods

  // Create Item
  Future<int> createItem(ItemModel item) async {
    final Database db = await initDB();
    return db.insert("items", item.toMap());
  }

  // Read Item
  Future<List<ItemModel>> getItems() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query("items");
    return result.map((e) => ItemModel.fromMap(e)).toList();
  }

  // Update Item
  Future<int> updateItems(title, price, image, colorValue, itemId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        "UPDATE items SET itemTitle = ?, itemPrice = ?, itemImage = ?, colorValue = ? where itemId = ?",
        [title, price, image, colorValue, itemId]);
  }

  // Delete Item
  Future<int> deleteItems(int id) async {
    final Database db = await initDB();
    return db.delete("items", where: "itemId = ?", whereArgs: [id]);
  }

  // delete all records
  deleteAll() async {
    final Database db = await initDB();
    return await db.rawDelete("Delete from items");
  }
}
