part of m7db;

abstract class M7DB{

  /// database name will saved in sqlite
  String get databaseName;

  /// database version for migrations
  int get version ;

  /// the actual represent of the database
  Database _db;

  /// getter for the [_db] which represent the real database
  Future<Database> get database async{
    if(_db == null) _db = await _createAppDataBase();
    return _db;
  }

  /// to create the [_db] object
  Future<Database> _createAppDataBase() async {
    return await openDatabase(
        "${await getDatabasesPath()}/$databaseName",
        onCreate: onCreate,
        version: this.version,
    );
  }

  // only executed when first time of initializing the Database
  FutureOr<void> onCreate(Database db, int version);

  /// [createTableStatement] helper function to create a table
  /// it's need the tableName and fields or columns in database
  String createTableStatement({String tableName,String fields})=>'CREATE TABLE $tableName ($fields);';



}

