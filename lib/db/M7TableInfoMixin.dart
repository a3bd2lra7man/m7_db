part of m7db;

mixin M7TableInfoMixin{
  String get tableName;
  String createTableHelper(String fields) => "CREATE TABLE $tableName  ($fields)";
  String get createStatement ;
}