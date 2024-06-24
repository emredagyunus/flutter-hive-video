import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_video/Models/video_model.dart';


class HiveService with ChangeNotifier {
  Box<VideoModel>? _videoBox;

  Future<void> init() async {
    if (_videoBox == null || !_videoBox!.isOpen) {
      _videoBox = await Hive.openBox<VideoModel>('videos');
    }
  }

  Box<VideoModel> get videoBox {
    if (_videoBox == null || !_videoBox!.isOpen) {
      throw HiveError('The box "videos" is not open.');
    }
    return _videoBox!;
  }

  Future<void> addVideo(VideoModel video) async {
    await _videoBox!.add(video);
    notifyListeners();
  }

  Future<void> updateVideo(int index, VideoModel video) async {
    await _videoBox!.putAt(index, video);
    notifyListeners();
  }

  Future<void> deleteVideo(int index) async {
    await _videoBox!.deleteAt(index);
    notifyListeners();
  }
}
