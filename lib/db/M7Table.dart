part of m7db;


abstract class  M7Table{


  // trick for let the user of this class can make another constructor with no parameter for super class
  M7Table.create();

  /// to help [M7Dao] to return data from database
  M7Table.fromMap(Map map);

  // helper function
  // convert int to boolean when retuning data from database
  bool intToBoolean(int i) => i == 0 ? false : true;

  // convert boolean to int when saving data to database
  int booleanToInt(bool i) => i ? 1 : 0;

  // convert int to Date when retuning data from database
  DateTime intToDate(int i) => DateTime.fromMillisecondsSinceEpoch(i);

  // convert boolean to date when saving data to database
  int dateToInt(DateTime dateTime) => dateTime.millisecondsSinceEpoch;

  /// [primaryKey] used with Dao and must represent the actual primary key of the table
  dynamic get primaryKey;

  /// [toMap] used by [M7Dao] when saving data to database
  Map<String,dynamic> toMap();

  /// fast copying of existing instances
  M7Table copyWith();


  // helping for equality operations
  @override
  int get hashCode => primaryKey.hashCode;

  // helping for equality operations
  @override
  bool operator ==( other) {
    return this.primaryKey == other.primaryKey;
  }

}
