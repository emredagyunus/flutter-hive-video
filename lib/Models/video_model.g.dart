// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoModelAdapter extends TypeAdapter<VideoModel> {
  @override
  final int typeId = 0;

  @override
  VideoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoModel(
      uid: fields[0] as String,
      path: fields[1] as String,
      isUpload: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VideoModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.isUpload);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
