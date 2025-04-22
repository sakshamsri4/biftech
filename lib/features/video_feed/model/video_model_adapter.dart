import 'package:biftech/features/video_feed/model/video_model.dart';
import 'package:hive/hive.dart';

/// Hive type adapter for [VideoModel]
class VideoModelAdapter extends TypeAdapter<VideoModel> {
  @override
  final int typeId = 2; // Use a unique typeId (1 is used by UserModel)

  @override
  VideoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return VideoModel(
      id: fields[0] as String,
      title: fields[1] as String,
      creator: fields[2] as String,
      views: fields[3] as int,
      thumbnailUrl: fields[4] as String,
      videoUrl: fields[5] as String,
      description: fields[6] as String,
      duration: fields[7] as String,
      publishedAt: fields[8] as String,
      tags: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, VideoModel obj) {
    writer..writeByte(10)
    ..writeByte(0)
    ..write(obj.id)
    ..writeByte(1)
    ..write(obj.title)
    ..writeByte(2)
    ..write(obj.creator)
    ..writeByte(3)
    ..write(obj.views)
    ..writeByte(4)
    ..write(obj.thumbnailUrl)
    ..writeByte(5)
    ..write(obj.videoUrl)
    ..writeByte(6)
    ..write(obj.description)
    ..writeByte(7)
    ..write(obj.duration)
    ..writeByte(8)
    ..write(obj.publishedAt)
    ..writeByte(9)
    ..write(obj.tags);
    // isPlaying is a runtime state and not stored
  }
}
