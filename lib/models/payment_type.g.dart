// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentTypeAdapter extends TypeAdapter<PaymentType> {
  @override
  final int typeId = 1;

  @override
  PaymentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentType.cash;
      case 1:
        return PaymentType.upi;
      default:
        return PaymentType.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentType obj) {
    switch (obj) {
      case PaymentType.cash:
        writer.writeByte(0);
        break;
      case PaymentType.upi:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
