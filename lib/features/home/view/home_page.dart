import 'package:biftech/features/auth/model/user_model.dart';
import 'package:biftech/features/auth/service/auth_service.dart';
import 'package:biftech/features/flowchart/flowchart.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/video_feed/service/video_feed_service.dart';
import 'package:biftech/features/video_feed/video_feed.dart';
import 'package:flutter/material.dart';

/// {@template home_page}
/// The main home page of the application.
/// {@endtemplate}
class HomePage extends StatefulWidget {
  /// {@macro home_page}
  const HomePage({super.key});

  /// The route name for this page.
  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _currentUser;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authRepository = AuthService.getAuthRepository();
    final currentUser = authRepository.getCurrentUser();

    if (currentUser != null) {
      setState(() {
        _currentUser = currentUser;
      });
    }
  }

  Future<void> _logout() async {
    final authRepository = AuthService.getAuthRepository();
    await authRepository.logoutUser();

    if (mounted) {
      await Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BifTech'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: 'Flowchart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donate',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildBody() {
    if (_currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildVideosTab();
      case 2:
        return _buildFlowchartTab();
      case 3:
        return _buildDonateTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildFeaturedSection(),
          const SizedBox(height: 24),
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    // Ensure _currentUser is not null
    if (_currentUser == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Safe to use _currentUser now
    final userName = _currentUser?.name ?? 'User';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        userName,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your progress this week:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              '70% complete',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Content',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://picsum.photos/seed/${index + 1}/280/200',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          color: Colors.black.withAlpha(179),
                        ),
                        child: Text(
                          'Featured Item ${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  _getActivityIcon(index),
                  color: Colors.blue,
                ),
              ),
              title: Text('Activity ${index + 1}'),
              subtitle: Text('Description for activity ${index + 1}'),
              trailing: Text(
                '${index + 1}h ago',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getActivityIcon(int index) {
    final icons = [
      Icons.video_library,
      Icons.article,
      Icons.volunteer_activism,
      Icons.account_tree,
      Icons.emoji_events,
    ];
    return icons[index % icons.length];
  }

  Widget _buildVideosTab() {
    // Directly embed the VideoFeedPage content
    return const VideoFeedPage();
  }

  Widget _buildFlowchartTab() {
    return FutureBuilder<List<VideoModel>>(
      future: VideoFeedService.instance.getVideos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading flowcharts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final videos = snapshot.data ?? [];

        if (videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_tree,
                  size: 80,
                  color: Colors.blue.shade200,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Flowcharts Available',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Watch videos to participate in discussions',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return _buildFlowchartCard(video);
          },
        );
      },
    );
  }

  Widget _buildFlowchartCard(VideoModel video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/flowchart/${video.id}',
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildThumbnail(video.thumbnailUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${video.creator}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_tree, size: 16),
                      const SizedBox(width: 4),
                      FutureBuilder<bool>(
                        future: _hasFlowchart(video.id),
                        builder: (context, snapshot) {
                          final hasFlowchart = snapshot.data ?? false;
                          return Text(
                            hasFlowchart
                                ? 'Discussion Active'
                                : 'Start Discussion',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.remove_red_eye, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${video.views} views',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _hasFlowchart(String videoId) async {
    try {
      final flowchart =
          await FlowchartRepository.instance.getFlowchartForVideo(videoId);
      return flowchart != null;
    } catch (e) {
      return false;
    }
  }

  /// Builds a thumbnail image with fallback to default
  Widget _buildThumbnail(String thumbnailUrl) {
    // Log the error but don't show it to the user
    return Image.asset(
      thumbnailUrl,
      width: 100,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Log the error
        debugPrint('Error loading thumbnail: $thumbnailUrl - $error');

        // Always show a placeholder without trying to load a default
        // that might also fail
        return const PlaceholderThumbnail();
      },
    );
  }

  Widget _buildDonateTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.volunteer_activism,
            size: 100,
            color: Colors.blue.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            'Donation',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
