# m7db

A Dart simple Api to helps working with sqflite .

## What acutely this package helps you for

1- try to remove the redundant code that's you always repeat in every project
2- it have three main classes M7DB M7Table and M7Dao


### ex:

You get all these function below by just overriding 3 classes in the right way

```dart
    main()async{

      Database _database;

      UserDao userDao = UserDao(_database, 'User');

      User user = User(id: 1,name: "Abood",email: "a3bd2llah@gmail.com",isOnline: false);

      userDao.insert(user);

      userDao.delete(user);

      userDao.update(user);

      userDao.insertAll([user]);

      userDao.getById(user.id);

      userDao.getAll();

      // return a stream to listen to it represent the whole table in data base
      userDao.watchAll().listen((event) {'your event here';});

      // to close the streams hold by user Dao
      userDao.dispose();
    }
```

### M7DB

M7DB is a simple class to create the database beyond you

to use it

    1- you have to extends it
    2- override the default constructor and pass the database's name you want to it
    3- override onCreate method and create your table there


#### ex:

```dart
class AppDB extends M7DB{

  // here u passed the database Name
  AppDB(String databaseName) : super(databaseName);


  // create your tables
  @override
  FutureOr<void> onCreate(Database db, int version) async{
    // execute tables creation
    await db.execute("CREATE TABLE TABLE1 (id INTEGER AUTOINCREMENT PRIMARY KEY)");
    await db.execute("CREATE TABLE TABLE2 (id INTEGER AUTOINCREMENT PRIMARY KEY)");
  }

}
```

### M7Table

M7Table another simple class to work with data classes that you wish to save it in database
it's mainly helps the M7Dao class to let it do it's job

to use it
a- extends M7Table
b- override copyWith(),primaryKey,toMap() and the super.fromMap(Map map) constructor

*primaryKey* should be override because it's used in the M7Dao class when deleting and updating
*toMap()* should also be override because the map return from here is the actual represent of the data will be saved to database
*fromMap() constructor* this constructor will called when return data from database optionally but prefer
*copyWith()* is not so harmful if you not implement it but it's recommended to override it
    because it allows us to obtain a copy of the existing object but with some specified modifications u passed as parameters

M7Table Have several helper methods that solve common  props face us as developer
1- booleanToInt() to convert a bool to int *because sqlflite does't support boolean type* 0 == false 1 == true
2- intToBoolean() to convert an int to boolean  0 == false 1 == true
3- intToDate()
4- dateToInt()

*M7Table has no default constructor but has M7Table.create() with no parameters*
#### ex:

```dart

class User extends M7Table{

  int id;
  String name;
  String email;
  bool isOnline;


  // this will be used in Dao
  @override
  get primaryKey => id;


  // constructor with out parameters
  User({this.id,this.name,this.email,this.isOnline}):super.create();


  User.fromMap(Map map) : super.fromMap(map){
    id = map['id'];
    name = map['name'];
    email = map['email'];
    /// [intToBoolean] is a helper function to deal with boolean type in data base beyond u
    isOnline = intToBoolean(map['isOnline']);
  }

  // this will be used in Dao
  // real represent of how your data will be saved into DataBase
  @override
  Map<String, dynamic> toMap() {
    return{
      "id":this.id,
      "name":this.name,
      "email":this.email,

       /// [booleanToInt] is a helper function to deal with boolean type in data base beyond u
      "isOnline":booleanToInt(this.isOnline)
    };
  }

  // optional but helps you if u implemented in your app to copy a fast copy of the existing object
  @override
  M7Table copyWith({int newId,String newName,String newEmail,bool newIsOnline}) {
    return User(id:  newId ?? this.id,name: newName ?? this.name,email: newEmail ?? this.email,isOnline: newIsOnline ?? this.isOnline);
  }

}

```

### M7Dao<T extends M7Table>

M7Dao is a the winner of this package because once override it in the right way
you will have a punch of helper methods on it's object

first the basic crud operations

    1- insert(T data)
    2- insertAll(List<T> objects)
    3- update(T data)
    4- delete(T object)
    5- getAll()
    5- getById(id)

second it's also work with stream and have a default one that will return the whole table

    - watchAll()

if u want to make your own stream u can because this library designed with that in mined
by these steps

    1- invoke the watch() function on M7Dao instance with parameter that do query the db
    this will return a new stream
    if u wish to make your own queries please don't forget to call notifyListener()

    #### ex:

    ```dart

      Stream getMyOwnAll(){
        Stream stream = watch(()async =>await database.query('table'));
        return stream;
        notifyListener();
      }

      void doAnyOperation()async{
        await database.query('AnyOperation');
        notifyListener();
      }
    ```

    *notifyListener() just tell the class to emits new values to all streams that the class hold*



u still can access the database from the inherited class and do what ever u want above the default ones

to use it u have to
1- extends it
2- override fromDB() *this called inside the helpers method for Basic Crud* u can make use the override T.fromMap() constructor in M7Table
3- override the default constructor which has 2 parameter the first is the database instance the second is the table name to deal with
4- call dispose() on it's instance to close all the stream M7Dao has
#### ex:

```dart

class UserDao extends M7Dao<User>{

  UserDao(Database database, String tableName) : super(database, tableName);

  @override
  User fromDB(Object map) =>User.fromMap(map);
}

main()async{

  Database _database;

  UserDao userDao = UserDao(_database, 'User');

  User user = User(id: 1,name: "Abood",email: "a3bd2llah@gmail.com",isOnline: false);

  userDao.insert(user);

  userDao.delete(user);

  userDao.update(user);

  userDao.insertAll([user]);

  userDao.getById(1);

  userDao.getAll();

  userDao.watchAll().listen((event) {'your event here';});

  StreamController streamController;

  Stream stream = userDao.watch(streamController, () async=>await userDao.database.query('table'));

  userDao.notifyListener();


  // to close the streams hold by user Dao
  userDao.dispose();
}

```