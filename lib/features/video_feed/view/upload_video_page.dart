import 'dart:io';

import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neopop/neopop.dart';

/// {@template upload_video_page}
/// Page for uploading a new video.
/// {@endtemplate}
class UploadVideoPage extends StatelessWidget {
  /// {@macro upload_video_page}
  const UploadVideoPage({super.key});

  /// Route name for this page
  static const routeName = '/upload-video';

  @override
  Widget build(BuildContext context) {
    return const UploadVideoView();
  }
}

/// {@template upload_video_view}
/// Main view for the upload video page.
/// {@endtemplate}
class UploadVideoView extends StatefulWidget {
  /// {@macro upload_video_view}
  const UploadVideoView({super.key});

  @override
  State<UploadVideoView> createState() => _UploadVideoViewState();
}

class _UploadVideoViewState extends State<UploadVideoView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _creatorController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _thumbnailFile;
  File? _videoFile;
  bool _isUploading = false;
  String? _thumbnailError;
  String? _videoError;

  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _thumbnailFile = File(pickedFile.path);
          _thumbnailError = null;
        });
      }
    } catch (e) {
      setState(() {
        _thumbnailError = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );

      if (pickedFile != null) {
        setState(() {
          _videoFile = File(pickedFile.path);
          _videoError = null;
        });
      }
    } catch (e) {
      setState(() {
        _videoError = 'Failed to pick video: $e';
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_videoFile == null) {
      setState(() {
        _videoError = 'Please select a video';
      });
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // In a real app, we would upload the files to a server
      // For now, we'll just simulate a delay and add the video to the feed
      await Future<void>.delayed(const Duration(seconds: 2));

      // Generate a unique ID for the video
      final id = 'v${DateTime.now().millisecondsSinceEpoch}';

      // Create a new video model
      final newVideo = VideoModel(
        id: id,
        title: _titleController.text,
        creator: _creatorController.text,
        views: 0, // New videos start with 0 views
        thumbnailUrl: _thumbnailFile?.path ??
            'https://via.placeholder.com/300x200/9C27B0/FFFFFF?text=New+Video',
        videoUrl: _videoFile!.path,
        description: _descriptionController.text,
        duration: _durationController.text,
        publishedAt: DateTime.now().toIso8601String(),
      );

      // Get the cubit before the async gap
      final cubit = context.read<VideoFeedCubit>();

      // Add the video to the feed
      await cubit.addNewVideo(newVideo);

      if (mounted) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Your Idea'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail picker
              Text(
                'Thumbnail (Optional)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickThumbnail,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _thumbnailFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _thumbnailFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to select thumbnail',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                ),
              ),
              if (_thumbnailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _thumbnailError!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 16),

              // Title input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter the title of your idea',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Creator input
              TextFormField(
                controller: _creatorController,
                decoration: const InputDecoration(
                  labelText: 'Creator Name',
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Duration input
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  hintText: 'e.g., 2:30',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                  // Optional: Add regex validation for duration format
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description input
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your idea',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Video picker
              Text(
                'Video',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _videoFile != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 48,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Video selected',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              _videoFile!.path.split('/').last,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.video_library,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to select video',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                ),
              ),
              if (_videoError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _videoError!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: NeoPopButton(
                  color: theme.colorScheme.primary,
                  onTapUp: _isUploading ? null : _submitForm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: _isUploading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Uploading...',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Upload Video',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
