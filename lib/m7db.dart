library m7db;

import 'package:sqflite/sqflite.dart'
    show Database, openDatabase, getDatabasesPath, ConflictAlgorithm;
import 'dart:async' show FutureOr, StreamController;
import 'package:flutter/material.dart' show required;

// db
part './db/M7Dao.dart';
part './db/M7DB.dart';
part './db/M7Table.dart';
