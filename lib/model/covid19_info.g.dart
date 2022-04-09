// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'covid19_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Covid19InfoAdapter extends TypeAdapter<Covid19Info> {
  @override
  final int typeId = 1;

  @override
  Covid19Info read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Covid19Info(
      confirmed: fields[0] as int,
      localConfirmed: fields[1] as int,
      nonLocalConfirmed: fields[2] as int,
      death: fields[3] as int,
      totalConfirmed: fields[4] as int,
      totalLocalConfirmed: fields[5] as int,
      totalNonLocalConfirmed: fields[6] as int,
      totalDeath: fields[7] as int,
      lastUpdated: fields[8] as DateTime,
      lastUpdatedString: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Covid19Info obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.confirmed)
      ..writeByte(1)
      ..write(obj.localConfirmed)
      ..writeByte(2)
      ..write(obj.nonLocalConfirmed)
      ..writeByte(3)
      ..write(obj.death)
      ..writeByte(4)
      ..write(obj.totalConfirmed)
      ..writeByte(5)
      ..write(obj.totalLocalConfirmed)
      ..writeByte(6)
      ..write(obj.totalNonLocalConfirmed)
      ..writeByte(7)
      ..write(obj.totalDeath)
      ..writeByte(8)
      ..write(obj.lastUpdated)
      ..writeByte(9)
      ..write(obj.lastUpdatedString);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Covid19InfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
