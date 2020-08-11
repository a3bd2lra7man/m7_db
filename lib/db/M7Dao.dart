part of m7db;


class AppDB extends M7DB{

  // override databaseName
  @override
  String get databaseName => 'App.db';

  // database version
  @override
  int get version => 1;

  // create your tables
  @override
  FutureOr<void> onCreate(Database db, int version) async{

    /// create your tables by [createTableStatement] helper function
    await db.execute(createTableStatement(tableName: 'User',fields:'id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,email TEXT'));
    // or use the normal way
    await db.execute('CREATE TABLE Normal_way (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,email TEXT);');

    /// [createTableStatement] helper function M7DB provides to create tables
    createTableStatement(tableName: 'User',fields:'id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,email TEXT');

  }

}
class UserDao extends M7Dao {

  // must override
  UserDao(Database database, String tableName) : super(database, tableName);

  // must override u can simply easy call .fromMap() from your M7Table
  // this convert the data from database represented way to M7Table way
  // not restricted to M7Table fromMap() constructor you can do what you wants
  @override
  M7Table fromDB(Map<String, dynamic> map) => map as M7Table;

// available methods from M7Dao
}





typedef  M7Query<T extends M7Table> = Future<List<Map<String,dynamic>>> Function();
typedef  M7QueryRes<T extends M7Table> = Future<List<T>> Function();

abstract class M7Dao<T extends M7Table>{

  /// [_stream] is the default stream of M7Dao to return the whole table
  StreamController<List<T>> _stream;

  /// holds all the streams used by calling the and the default one [watch]
  Map<StreamController,M7QueryRes> _streamsMap = {};

  /// database instance to make transaction above it
  final Database database;

  /// the table name to do transaction of it
  final String tableName;


  /// constructor
  M7Dao(this.database,this.tableName);

  /// to close all the streams hold by [_streamsMap]
  void dispose(){
    _stream.close();
    _streamsMap.keys.forEach((stream)=>stream.close());
  }

  /// to return the whole table and the stream saved in [_stream]
  Stream<List<T>>  watchAll() {
    if(_stream == null){
      _stream = StreamController();
      _streamsMap[_stream] = ()async=>(await database.query(tableName)).map(fromDB).toList();
      notifyListener();
    }
    return _stream.stream;
  }

  /// to add a new listener to [_streamsMap] to notified when changes happened to the table
  void watch(StreamController streamController,M7Query query) {
    _streamsMap[streamController] =() async => (await query()).map(fromDB).toList();
    notifyListener();
  }


  /// get the wanted object by id from database
  Future<T> getById(id)async{
    return fromDB((await database.query(tableName,where: 'id = ?' ,whereArgs: [id])).first);
  }


  /// insert all objects to the database
  Future insertAll(List<T> objects)async{
    var batch = database.batch();
    objects.forEach((element)=> batch.insert(tableName,element.toMap()));
    await batch.commit(noResult: true,continueOnError: true);
    await notifyListener();
  }

  /// insert an object to the database
  Future insert(T object)async{
    await database.insert(tableName,object.toMap() ,conflictAlgorithm: ConflictAlgorithm.replace);
    await notifyListener();
  }

  /// update an object to the database
  Future update(T object)async{
    await database.update(tableName, object.toMap(),where: 'id = ?',whereArgs: [object.primaryKey] ,conflictAlgorithm: ConflictAlgorithm.replace);
    await notifyListener();
  }

  /// delete an object from the database
  Future  delete(T object)async{
    await database.delete(tableName,where: 'id = ?',whereArgs: [object.primaryKey]);
    await notifyListener();
  }

  /// return the whole table
  Future getAll()async => await database.query(tableName);

  Future deleteAll()async => await database.delete(tableName);

  /// used by methods want to return values from database in known way
  T fromDB (Map<String,dynamic> map);

  /// update all streams with the new values
  Future notifyListener()async{
    _streamsMap.forEach((key, value) async=> key.add(await value()));
  }


}


