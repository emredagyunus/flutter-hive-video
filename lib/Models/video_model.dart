import 'package:hive/hive.dart';

part 'video_model.g.dart';

@HiveType(typeId: 0)
class VideoModel extends HiveObject {
  @HiveField(0)
  final String path;

  @HiveField(1)
  bool isUpload;

  VideoModel({required this.path, this.isUpload = false});
}
