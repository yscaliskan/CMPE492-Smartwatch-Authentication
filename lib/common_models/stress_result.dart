import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class StressResult extends HiveObject {
  @HiveField(0)
  DateTime dateTime;

  @HiveField(1)
  double val;

  StressResult({this.dateTime, this.val});

  @override
  String toString() {
    return '$val / $dateTime';
  }
}

class StressResultAdapter extends TypeAdapter<StressResult> {
  @override
  final int typeId = 1;

  @override
  StressResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StressResult(
      dateTime: fields[0] as DateTime,
      val: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, StressResult obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.dateTime)
      ..writeByte(1)
      ..write(obj.val);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StressResultAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}