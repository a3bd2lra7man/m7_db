part of m7db;


typedef  M7Query<T extends M7Table> = Future<List<Map<String,dynamic>>> Function();
typedef  M7QueryRes<T extends M7Table> = Future<List<T>> Function();

abstract class M7Dao<T extends M7Table>{

  Map<StreamController,M7QueryRes> _streamsMap = {};
  // ignore: close_sinks
  StreamController<List<T>> _stream;
  final Database database;
  final String tableName;

  M7Dao(this.database,this.tableName);

  void dispose(){
    _streamsMap.keys.forEach((stream)=>stream.close());
  }
  Stream<List<T>>  watchAll() {
    if(_stream == null){
      _stream = StreamController();
      _streamsMap[_stream] = ()async=>(await database.query(tableName)).map(fromDB).toList();
      notifyListener();
    }
    return _stream.stream;
  }

  Stream watch(M7Query query) {
    // ignore: close_sinks
    StreamController streamController = StreamController();
    _streamsMap[streamController] =() async => (await query()).map(fromDB).toList();
    notifyListener();
    return streamController.stream;
  }
  Future<T> getById(id)async{
    return fromDB((await database.query(tableName,where: 'id = ?' ,whereArgs: [id])).first);
  }

  Future insertAll(List<T> objects)async{
    var batch = database.batch();
    objects.forEach((element)=> batch.insert(tableName,element.toMap()));
    await batch.commit(noResult: true,continueOnError: true);
    await notifyListener();
  }

  Future insert(T object)async{
    await database.insert(tableName,object.toMap() ,conflictAlgorithm: ConflictAlgorithm.replace);
    await notifyListener();
  }

  Future update(T object)async{
    await database.update(tableName, object.toMap(),where: 'id = ?',whereArgs: [object.primaryKey] ,conflictAlgorithm: ConflictAlgorithm.replace);
    await notifyListener();
  }

  Future  delete(T object)async{
    await database.delete(tableName,where: 'id = ?',whereArgs: [object.primaryKey]);
    await notifyListener();
  }



  Future getAll()async => await database.query(tableName);

  T fromDB (Map<String,dynamic> map);

  Future notifyListener()async{
    _streamsMap.forEach((key, value) async=> key.add(await value()));
  }


}
