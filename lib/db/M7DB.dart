part of m7db;


abstract class M7DB{

  String get databaseName;

  Database _db;

  Future<Database> get database async{
    if(_db == null) _db = await _createAppDataBase();
    return _db;
  }

  Future<Database> _createAppDataBase() async {
    return await openDatabase(
        "${await getDatabasesPath()}/$databaseName",
        onCreate: onCreate,
        version: 1,
    );
  }

  // only executed when first time of initializing the Database
  FutureOr<void> onCreate(Database db, int version);

  /// [createTable] helper function to create a table
  /// it's need the tableName and fields or columns in database
  String createTable({String tableName,String fields})=>'CREATE TABLE $tableName ($fields);';



}

