import 'package:hive/hive.dart';

part 'video_model.g.dart';

@HiveType(typeId: 0)
class VideoModel extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String path;

  @HiveField(2)
  bool isUpload;

  VideoModel({required this.uid, required this.path, this.isUpload = false});
}
