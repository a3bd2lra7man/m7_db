# m7db

A Simple Dart Package that helps to deal with sqflite in simple way 

it's mean purpose to 

    1- gives an abstract DAO class that provides the four CRUD operation plus common other transaction
    
    2- remove redundant code that's we repeated in every project
    
    3- gives helper methods for common situation with the sqflite

## Whats will you get in the end 

```dart

// example

main(){
  
  Database database = AppDB();
  String tableName = 'User';
  // create the Dao
  UserDao userDao = UserDao(database, tableName);
  // this the the (data class) the table
  User user = User();



  // Basic CRUD operations package provides
  
  // get by id
  userDao.getById('id');
  
  // return the whole table
  userDao.getAll();
  
  //insert new one
  userDao.insert(user);
  
  // update the old one
  userDao.update(user);
  
  // delete the passed user
  userDao.delete(user);
  
  // insert a list of User
  userDao.insertAll([user]);
  
  ///  [watchAll] return a stream keep watching the whole table 
  /// when any of the inherited CRUD operation called (the above ones) it's will automatically update it the stream to the newest value's
  userDao.watchAll().listen((event) { });

}
```


## How to use it in the correct way

    1- it have three main classes M7DB M7Table and M7Dao
    
    2- you have to extends the three classes to let them work with each other 
    
    3- the three classes try to remove the redundant code and gives you helper functions

 

## 1- M7DB Class

M7DB will create the database beyond you 

M7DB also provide a helper methods as createTableStatement()

### Example

to use it you should extends M7DB

M7DB force you to override 

1- the databaseName getter

2- onCreate function passed to the initialization of database (perfect place to create your table) 

```dart


class AppDB extends M7DB{
  
  // override databaseName
  @override
  String get databaseName => 'App.db';
  
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

```


## M7Table Class

M7Table is A helper class for helping creation of tables and it's fields

M7Table have several help methods to do common situation happens to developers when working with sqflite 

The situations M7Table helps for is 

    1- is the problem of saving boolean field to database tables, M7Table Provides  
        *booleanToInt(bool)* to help you here 
        and the reverse one *intToBoolean(int)*  
        for helps reading and writing boolean data from and to database
    
    2- work with DateTime in the same convention of converting boolean to integer 
        there is *dateToInt(DateTime)* 
        and *intToDate(int)* helps reading and writing DateTime from and to database   

### Example

first let's look at how the data class will be without extending M7Table

```dart
class User{
  int id;
  String name;
  String email;
  bool isCompleted;
  DateTime date;

}
```

then let's look at how it will be with the extending

```dart

class User  extends M7Table{

  int id;
  String name;
  String email;
  bool isCompleted;
  DateTime date;

  // the default Constructor for M7Table class is M7Table.create() to create your own constructor make sure to call super.create()
  User({this.id,this.name,this.email,this.isCompleted,this.date}):super.create();

  // the primary key of this class represent the primary key of the database this will be used in Dao
  // note M7Table is not smart if u passed a primary key that in the database is not a primary key it's will throw exception in runTime 
  @override
  get primaryKey => id;



  // optionally used with M7DAO when override it to tell M7Dao how to convert the data from database represent way to M7Table way
  User.fromMap(Map map) : super.fromMap(map){
    id = map['id'];
    name = map['name'];
    email = map['email'];

    /// [intToBoolean]  convert an integer object to boolean when getting data from database
    isCompleted = intToBoolean(map['isCompleted']);

    /// [intToDate]  convert an integer object to DateTime when getting data from database
    date = intToDate(map['date']);
  }


  // Used by M7DAO to insert data to the database
  @override
  Map<String,dynamic > toMap() => {
    "id":id,
    "name":name,
    "email":email,

    /// [booleanToInt]  convert a boolean object to integer when saving data to database
    "isCompleted":booleanToInt(this.isCompleted),

    /// [dateToInt]  convert a date object to integer when saving data to database
    "date":dateToInt(date),
  };


  // optionally but known as a good practice and the library thinking in that way
  // simple copying existing object to new one
  // helps you when do operation like update for fast copying the existing instance
  @override
  M7Table copyWith({int id,String name,String email,bool isCompleted}) {
    return User(id: id ?? this.id,name: name ?? this.name,email: email ?? this.email,isCompleted: isCompleted ?? this.isCompleted,date: this.date);
  }

}
```




##  M7Dao<T> Class 

M7Dao implementation is easy to have 

1- extends <T extends M7Table> M7Dao .

2- override the default constructor and fromDB(Map) method 

### Example

```dart

class UserDao extends M7Dao<User>{
  
  // must override
  UserDao(Database database, String tableName) : super(database, tableName);
  
  // must override u can simply easy call .fromMap() from your M7Table
  // this convert the data from database represented way to M7Table way
  // not restricted to M7Table fromMap() constructor you can do what you wants
  @override
  User fromDB(Map<String, dynamic> map) => User.fromMap(map);
  
  // available methods from M7Dao
  
  void operations()async{
    
    User user = User(id: 1,email: "Ali@gmail.com");
    
    // getting by id
    User user1 = await this.getById('id');

    // getting All columns in the table <T>
    List<User> users=  await this.getAll();

    // insertAll<T>
    await this.insertAll([user,user]);
    
    // insert one entity <T> 
    await this.insert(user);

    // updating one entity <T>
    await this.update(user.copyWith(name: "Ali"));

    // deleting entity <T>
    await this.delete(user);
    
    ///  [watchAll] return a stream keep watching the whole table 
    /// when any of the inherited CRUD operation called (the above ones) it's will automatically update it the stream to the newest value's
    userDao.watchAll().listen((event) { });
    

    // close all streams that the class holds
    this.dispose();
    
    // u can access the database and do what ever you need with it
    this.database;

  }


}
```




### M7Dao with streams in mined

M7Dao works with the streams in mined and provides you a way to keep watching the database in stream 

M7Dao gives you that with the query you want 

to do that you have to do three steps 

    1- make your stream in streamController way
    
    2- call watch() function provide by M7Dao with two parameter the first is the streamController the second is your query
    
    3- make sure to override the dispose function and close your controller if u forget M7Dao will close it for you but u have to call M7Dao dispose() function in your logic
 
    
*if you wish to add your custom query please do not forget to call notifyListener() to tell M7Dao that's something happened to the database make sure to updating the hold streams in M7Dao also*
 
 
#### Example to use M7Dao with streams
 
```dart

class UserDao extends M7Dao<User>{
  
  // must override
  UserDao(Database database, String tableName) : super(database, tableName);
  
  // must override u can simply easy call .fromMap() from your Table and not restricted you can do what you wants
  @override
  User fromDB(Map<String, dynamic> map) => User.fromMap(map);


  // create your controller
  StreamController _streamController = StreamController();

  void dealWithStreams(){
    
    // to tell the database u want to have a stream from certain expression to execute
    // u cam use watch() function to keep watching the real data in time
    this.watch(_streamController, () => database.query(tableName,where: 'name = ?',whereArgs: ['ahmed']));

    // this to update refreshing state to listeners
    notifyListener();
  }
  
  // u can make your own query
  void makeMyOwnQuery()async{
    await this.database.execute('Custom Query ');
    
    // don't forget to call to tell M7Dao i make a changed in database please tell the listeners that
    notifyListener();
  }
  
  void listen(){
    // then listen to it and when ever the db changes the stream will be emitted with the new value's depends on your query u passed to watch() function
    _streamController.stream.listen((event) { });
  }
  

  @override
  void dispose() {
    
    // don't forget to close your stream
    _streamController.close();
    super.dispose();
  }
}

``` 

