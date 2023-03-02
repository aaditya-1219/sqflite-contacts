import 'dart:async';
import 'dart:core';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper{
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        phone TEXT,
        email TEXT,
        street TEXT,
        city TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'contactstable.db',
      version: 2,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String name, String? phone, String email, String street, String city) async {
    final db = await SQLHelper.db();

    final data = {'name': name, 'phone': phone, 'email': email, 'street': street, 'city': city};
    final id = await db.insert(
        'contacts',
        data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('contacts', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('contacts', where: "id= ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
        int id, String name, String phone, String email, String street, String city
      ) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'phone': phone,
      'email': email,
      'street': street,
      'city': city,
      'createdAt': DateTime.now().toString()
    };

    final result = await db.update('contacts', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("contacts", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Failed to delete item: $err");
    }
  }
}