// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncidentAdapter extends TypeAdapter<Incident> {
  @override
  final int typeId = 1;

  @override
  Incident read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Incident(
      id: fields[0] as int,
      category: fields[1] as String,
      description: fields[2] as String,
      severity: fields[3] as int,
      lat: fields[4] as double,
      lng: fields[5] as double,
      photoPaths: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as int,
      isSynced: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Incident obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.severity)
      ..writeByte(4)
      ..write(obj.lat)
      ..writeByte(5)
      ..write(obj.lng)
      ..writeByte(6)
      ..write(obj.photoPaths)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
