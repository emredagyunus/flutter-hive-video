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
    await _videoBox!.put(video.uid, video);
    notifyListeners();
  }

  Future<void> updateVideo(String uid, VideoModel video) async {
    await _videoBox!.put(uid, video);
    notifyListeners();
  }

  Future<void> deleteVideo(String uid) async {
    await _videoBox!.delete(uid);
    notifyListeners();
  }

  Future<void> uploadVideo(String uid) async {
    final video = videoBox.get(uid);
    if (video != null && !video.isUpload) {
      try {
        File videoFile = File(video.path);
        String fileName = 'videos/${videoFile.uri.pathSegments.last}';
        TaskSnapshot uploadTask =
            await FirebaseStorage.instance.ref(fileName).putFile(videoFile);

        if (uploadTask.state == TaskState.success) {
          video.isUpload = true;
          await updateVideo(uid, video);
          await deleteVideo(uid);
          print("Firebase'e yüklendi");
        }
      } catch (e) {
        Future.delayed(Duration(seconds: 10), () => uploadVideo(uid));
      }
    }
  }

  void retryFailedUploads() {
    for (int i = 0; i < videoBox.length; i++) {
      final video = videoBox.getAt(i);
      if (video != null && !video.isUpload) {
        uploadVideo(video.uid);
      }
    }
  }
}
