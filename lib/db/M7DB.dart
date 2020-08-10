part of m7db;


abstract class M7DB{

  final String databaseName;
  M7DB(this.databaseName);

  Database _db;

  Future<Database> get database async{
    if(_db == null) _db = await _createAppDataBase();
    return _db;
  }

  Future<Database> _createAppDataBase() async {
    return await openDatabase(
        "${await getDatabasesPath()}/$databaseName",
        onCreate: onCreate,
        version: 1
    );
  }

  FutureOr<void> onCreate(Database db, int version);
}

