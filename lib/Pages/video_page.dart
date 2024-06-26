import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_video/Models/video_model.dart';
import 'package:hive_video/services/hive_services.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<HiveService>(context, listen: false).retryFailedUploads();
    });
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      final File videoFile = File(video.path);

      String uid = const Uuid().v4();
      
      final VideoModel videoModel = VideoModel(
        uid: uid,
        path: videoFile.path,
        isUpload: false,
      );

      await Provider.of<HiveService>(context, listen: false).addVideo(videoModel);
      Provider.of<HiveService>(context, listen: false).uploadVideo(uid); // UID'yi kullanarak yükleme işlemi
      setState(() {});
    }
  }

  void _toggleUploadStatus(String uid) {
    Provider.of<HiveService>(context, listen: false).uploadVideo(uid); // UID'yi kullanarak yükleme durumunu değiştirme
  }

  @override
  Widget build(BuildContext context) {
    final hiveService = Provider.of<HiveService>(context, listen: true);
    final videos = hiveService.videoBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return ListTile(
            title: Text('Video ${video.uid}'), // Video UID'sini kullanarak listeleme
            subtitle: Text(video.isUpload ? 'Uploaded' : 'Not Uploaded'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    _showVideoPlayerModal(video.path);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    hiveService.deleteVideo(video.uid); // UID'yi kullanarak video silme
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickVideo,
        child: const Icon(Icons.videocam),
      ),
    );
  }

  void _showVideoPlayerModal(String videoPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: VideoPlayerWidget(videoPath),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}


class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget(this.videoPath, {super.key});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  void _toggleMute() {
    _isMuted = !_isMuted;
    _controller.setVolume(_isMuted ? 0.0 : 1.0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Column(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: _playPause,
                  ),
                  IconButton(
                    icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                    onPressed: _toggleMute,
                  ),
                ],
              ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
