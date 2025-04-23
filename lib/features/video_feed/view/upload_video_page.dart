import 'dart:io';

import 'package:biftech/core/services/error_logging_service.dart';
import 'package:biftech/features/video_feed/cubit/cubit.dart';
import 'package:biftech/features/video_feed/model/models.dart';
import 'package:biftech/features/video_feed/repository/video_feed_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Check if the VideoFeedCubit is available in the context
    try {
      // This is just to verify the cubit is available
      context.read<VideoFeedCubit>();
      return const UploadVideoView();
    } catch (e) {
      // If the cubit is not available, create a new one
      return BlocProvider(
        create: (_) => VideoFeedCubit()..loadVideos(),
        child: const UploadVideoView(),
      );
    }
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

  // Use dynamic type to handle both File and XFile (for web)
  dynamic _thumbnailFile;
  dynamic _videoFile;
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
      // Show a dialog to choose between camera and gallery
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          // Handle platform differences
          if (kIsWeb) {
            // On web, we keep the XFile directly
            _thumbnailFile = pickedFile;
          } else {
            // On mobile, convert to File
            _thumbnailFile = File(pickedFile.path);
          }
          _thumbnailError = null;
        });
      }
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'UploadVideoPage._pickThumbnail',
      );

      setState(() {
        _thumbnailError = 'Failed to select image';
      });
      // Show a more user-friendly error message
      _showPermissionErrorDialog('image', errorMessage: e.toString());
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    // On simulators, camera might not be available, but we'll show the option
    // and handle errors when they try to use it
    // This is better UX than hiding the option completely

    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'SELECT SOURCE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF6C63FF)),
              title: const Text(
                'GALLERY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
              title: const Text(
                'CAMERA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    try {
      // Show a dialog to choose between camera and gallery
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 10),
      );

      if (pickedFile != null) {
        setState(() {
          // Handle platform differences
          if (kIsWeb) {
            // On web, we keep the XFile directly
            _videoFile = pickedFile;
          } else {
            // On mobile, convert to File
            _videoFile = File(pickedFile.path);
          }
          _videoError = null;
        });
      }
    } catch (e, stackTrace) {
      // Log the error
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'UploadVideoPage._pickVideo',
      );

      setState(() {
        _videoError = 'Failed to select video';
      });
      // Show a more user-friendly error message
      _showPermissionErrorDialog('video', errorMessage: e.toString());
    }
  }

  void _showPermissionErrorDialog(String mediaType, {String? errorMessage}) {
    if (!mounted) return;

    // Log the detailed error for debugging
    if (errorMessage != null) {
      ErrorLoggingService.instance.logWarning(
        'Permission or availability issue: $errorMessage',
        context: 'UploadVideoPage._showPermissionErrorDialog',
      );
    }

    final title = errorMessage != null && errorMessage.contains('camera')
        ? 'Camera Not Available'
        : 'Permission Required';

    final message = errorMessage != null && errorMessage.contains('camera')
        ? 'The camera is not available on this device or simulator. '
            'Please try using the gallery option instead, '
            'or test on a physical device.'
        : 'To select a $mediaType, this app needs permission '
            'to access your media. Please go to your device settings '
            'and grant permission for camera and storage.';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          NeoPopButton(
            color: const Color(0xFF6C63FF),
            onTapUp: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
            },
            onTapDown: HapticFeedback.lightImpact,
            parentColor: const Color(0xFF1E1E1E),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Video is required
    if (_videoFile == null) {
      setState(() {
        _videoError = 'Please select a video';
      });
      return;
    }

    // Get the cubit before setting state and starting async operations
    final cubit = context.read<VideoFeedCubit>();

    setState(() {
      _isUploading = true;
    });

    try {
      // In a real app, we would upload the files to a server
      // For now, we'll just simulate a delay and add the video to the feed
      await Future<void>.delayed(const Duration(seconds: 1));

      // Log the operation for debugging
      debugPrint('Creating new video with repository helper methods');

      // Get the repository
      final repository = VideoFeedRepository.instance;

      // Generate a unique ID for the video
      final id = repository.generateVideoId();

      // Get file paths based on platform
      final String thumbnailPath;
      final String videoPath;

      // Use the File path for the selected video
      videoPath = (_videoFile as File).path;

      // For thumbnail
      if (_thumbnailFile == null) {
        thumbnailPath = repository.getDefaultThumbnailUrl();
      } else {
        thumbnailPath = (_thumbnailFile as File).path;
      }

      // Create a new video model
      final newVideo = VideoModel(
        id: id,
        title: _titleController.text,
        creator: _creatorController.text,
        views: 0, // New videos start with 0 views
        thumbnailUrl: thumbnailPath,
        videoUrl: videoPath,
        description: _descriptionController.text,
        duration: _durationController.text,
        publishedAt: DateTime.now().toIso8601String(),
      );

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
    } catch (e, stackTrace) {
      // Log the detailed error for debugging
      ErrorLoggingService.instance.logError(
        e,
        stackTrace: stackTrace,
        context: 'UploadVideoPage._submitForm',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload video. Please try again.'),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'UPLOAD YOUR IDEA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail picker
              const Text(
                'THUMBNAIL (OPTIONAL)',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _pickThumbnail();
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  child: _thumbnailFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              // For web, use network image from XFile
                              ? Image.network(
                                  (_thumbnailFile as XFile).path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              // For mobile, use file image
                              : Image.file(
                                  _thumbnailFile as File,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Color(0xFF6C63FF),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'TAP TO SELECT THUMBNAIL',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
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
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Title input
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'TITLE',
                  labelStyle: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  hintText: 'Enter the title of your idea',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C63FF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                  ),
                  filled: true,
                  fillColor: Color(0xFF1E1E1E),
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
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'CREATOR NAME',
                  labelStyle: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C63FF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                  ),
                  filled: true,
                  fillColor: Color(0xFF1E1E1E),
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
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'DURATION',
                  labelStyle: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  hintText: 'e.g., 2:30',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C63FF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                  ),
                  filled: true,
                  fillColor: Color(0xFF1E1E1E),
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
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'DESCRIPTION',
                  labelStyle: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  hintText: 'Describe your idea',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C63FF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                  ),
                  filled: true,
                  fillColor: Color(0xFF1E1E1E),
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
              const Text(
                'VIDEO',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _pickVideo();
                },
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  child: _videoFile != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 48,
                              color:
                                  Color(0xFF00BFA6), // Teal color for success
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'VIDEO SELECTED',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kIsWeb
                                  ? 'Video selected from web'
                                  : (_videoFile as File).path.split('/').last,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library,
                              size: 48,
                              color: Color(0xFF6C63FF),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'TAP TO SELECT VIDEO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
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
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: NeoPopButton(
                  color: const Color(0xFF6C63FF),
                  onTapUp: _isUploading
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          _submitForm();
                        },
                  onTapDown: _isUploading ? null : HapticFeedback.lightImpact,
                  parentColor: const Color(0xFF0A0A0A),
                  depth: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: _isUploading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'UPLOADING...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'UPLOAD VIDEO',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.5,
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
