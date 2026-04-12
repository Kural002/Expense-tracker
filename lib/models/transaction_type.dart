import 'package:hive/hive.dart';

part 'transaction_type.g.dart';

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  expense,

  @HiveField(1)
  income,
}
