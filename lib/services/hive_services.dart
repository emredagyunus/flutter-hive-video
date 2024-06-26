import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<void> uploadVideo(int index) async {
    final video = videoBox.getAt(index);
    if (video != null && !video.isUpload) {
      try {
        File videoFile = File(video.path);
        String fileName = 'videos/${videoFile.uri.pathSegments.last}';
        TaskSnapshot uploadTask =
            await FirebaseStorage.instance.ref(fileName).putFile(videoFile);

        if (uploadTask.state == TaskState.success) {
          video.isUpload = true;
          await updateVideo(index, video);
          await deleteVideo(index);
          print("firebase e kaydedildi");
        }
      } catch (e) {
        Future.delayed(Duration(seconds: 10), () => uploadVideo(index));
      }
    }
  }

  void retryFailedUploads() {
    for (int i = 0; i < videoBox.length; i++) {
      uploadVideo(i);
    }
  }
}
