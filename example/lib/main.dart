import 'dart:async';
import 'package:m7db/m7db.dart';
import 'package:sqflite_common/sqlite_api.dart';

// first step create your database by extends M7DB

class AppDB extends M7DB {
  // override databaseName
  @override
  String get databaseName => 'App.db';

  // create your tables
  @override
  FutureOr<void> onCreate(Database db, int version) async {
    /// create your tables by [createTableStatement] helper function
    await db.execute(createTableStatement(
        tableName: 'User',
        fields:
            'id INTEGER PRIMARY KEY AUTOINCREMENT , name TEXT ,isCompleted INTEGER,date INTEGER'));
    // or use the normal way
    await db.execute(
        'CREATE TABLE Normal_way (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,email TEXT);');
  }

  // database version
  @override
  int get version => 1;
}

// then create your data class

class User extends M7Table {
  int id;
  String name;
  bool isCompleted;
  DateTime date;

  // the primary key of this class represent the primary key of the database this will be used in Dao
  // note M7Table is not smart if u passed a primary key that in the database is not a primary key it's will throw exception in runTime
  @override
  get primaryKey => id;

  // the default Constructor for M7Table class is M7Table.create() to create your own constructor make sure to call super.create()
  User({this.name, this.date, this.isCompleted, this.id}) : super.create();

  // optionally used with M7DAO when override it to tell M7Dao how to convert the data from database represent way to M7Table way u have to add it manually
  User.fromMap(Map map) : super.fromMap(map) {
    id = map['id'];
    name = map['name'];

    /// [intToBoolean]  convert an integer object to boolean when getting data from database
    isCompleted = intToBoolean(map['isCompleted']);

    /// [intToDate]  convert an integer object to DateTime when getting data from database
    date = intToDate(map['date']);
  }

  // Used by M7DAO to insert data to the database
  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,

        /// [booleanToInt]  convert a boolean object to integer when saving data to database
        'isCompleted': booleanToInt(isCompleted),

        /// [dateToInt]  convert a date object to integer when saving data to database
        'date': dateToInt(date),
      };

  // optionally but known as a good practice and this package thinking in that way
  // simple copying existing object to new one
  // helps you when do operation like update for fast copying the existing instance
  @override
  M7Table copyWith({String name, bool isCompleted, DateTime dateTime}) {
    return User(
        id: this.id,
        name: name ?? this.name,
        isCompleted: isCompleted ?? this.isCompleted,
        date: dateTime ?? this.date);
  }
}

// then create your dao

class UserDao extends M7Dao<User> {
  UserDao(Database database, String tableName) : super(database, tableName);

  @override
  User fromDB(Map<String, dynamic> map) => User.fromMap(map);

  // do your queries
  void doMyOwnQuery() async {
    // u can access the database instance
    this.database.query('table');

    // updating all streams M7Dao holds with there queries
    notifyListener();
  }

  // Adding streams

  // create your controller
  StreamController _streamController = StreamController();

  void dealWithStreams() {
    // to tell the database u want to have a stream from certain expression to execute
    // u cam use watch() function to keep watching the real data in time
    this.watch(
        _streamController,
        () =>
            database.query(tableName, where: 'name = ?', whereArgs: ['ahmed']));

    // this to update refreshing state to listeners
    notifyListener();
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }
}

// then use them

main() async {
  AppDB appDB = AppDB();

  UserDao userDao = UserDao(await appDB.database, 'User');

  User user = User(id: 1);

  // getting by id
  User user1 = await userDao.getById('id');

  // getting All columns in the table <T>
  List<User> users = await userDao.getAll();

  // insertAll<T>
  await userDao.insertAll(users);

  // insert one entity <T>
  await userDao.insert(user1);

  // updating one entity <T>
  await userDao.update(user.copyWith(name: "Ali"));

  // deleting entity <T>
  await userDao.delete(user);

  // delete all the entities
  await userDao.deleteAll();

  ///  [watchAll] return a stream keep watching the whole table
  /// when any of the inherited CRUD operation called (the above ones) it's will automatically update it the stream to the newest value's
  userDao.watchAll().listen((event) {});

  // close all streams that the class holds
  userDao.dispose();

  // u can access the database and do what ever you need with it
  userDao.database;
}
