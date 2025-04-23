// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NodeModelAdapter extends TypeAdapter<NodeModel> {
  @override
  final int typeId = 3;

  @override
  NodeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NodeModel(
      id: fields[0] as String,
      text: fields[1] as String,
      donation: fields[2] as double,
      comments: (fields[3] as List).cast<String>(),
      challenges: (fields[4] as List).cast<NodeModel>(),
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, NodeModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.donation)
      ..writeByte(3)
      ..write(obj.comments)
      ..writeByte(4)
      ..write(obj.challenges)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
