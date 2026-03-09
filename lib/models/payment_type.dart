import 'package:hive/hive.dart';
part 'payment_type.g.dart';

@HiveType(typeId: 1)
enum PaymentType {
  @HiveField(0)
  upi,

  @HiveField(1)
  cash,
}
