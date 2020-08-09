part of m7db;


abstract class  M7Table{


  M7Table.create();
  M7Table.fromMap(Map map);

  // playWithData
  bool intToBoolean(int i) => i == 0 ? false : true;
  int booleanToInt(bool i) => i ? 1 : 0;
  DateTime intToDate(int i) => DateTime.fromMillisecondsSinceEpoch(i);
  int dateToInt(DateTime dateTime) => dateTime.millisecondsSinceEpoch;

  dynamic get primaryKey;
  Map<String,dynamic> toMap();
  M7Table copyWith();

  @override
  int get hashCode => primaryKey.hashCode;

  @override
  bool operator ==( other) {
    return this.primaryKey == other.primaryKey;
  }

}
