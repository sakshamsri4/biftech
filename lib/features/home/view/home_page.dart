import 'package:biftech/features/auth/model/user_model.dart';
import 'package:biftech/features/auth/service/auth_service.dart';
import 'package:biftech/features/donation/view/donation_page.dart';
import 'package:biftech/features/flowchart/flowchart.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/video_feed/service/video_feed_service.dart';
import 'package:biftech/features/video_feed/video_feed.dart';
import 'package:biftech/shared/animations/animations.dart';
import 'package:biftech/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (currentUser != null && mounted) {
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

  final BoxDecoration _backgroundDecoration = const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  final Duration _staggerDelay = const Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _backgroundDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: EntranceAnimation(
            delay: _staggerDelay * 0,
            child: const Text(
              'BifTech',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            EntranceAnimation(
              delay: _staggerDelay * 1,
              child: PressableScale(
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Logout',
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: EntranceAnimation(
          delay: _staggerDelay * 6,
          offset: const Offset(0, 50),
          child: BottomNavigationBar(
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
            backgroundColor: const Color(0xFF16213E).withOpacity(0.8),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return IndexedStack(
      index: _selectedIndex,
      children: [
        _buildHomeTab(),
        _buildVideosTab(),
        _buildFlowchartTab(),
        _buildDonateTab(),
      ],
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EntranceAnimation(
            delay: _staggerDelay * 2,
            child: _buildWelcomeSection(),
          ),
          const SizedBox(height: 32),
          EntranceAnimation(
            delay: _staggerDelay * 3,
            child: _buildFeaturedSection(),
          ),
          const SizedBox(height: 32),
          EntranceAnimation(
            delay: _staggerDelay * 4,
            child: _buildRecentActivitySection(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final userName = _currentUser?.name ?? 'User';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
        ),
        Text(
          userName,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),
        Text(
          'Your progress this week:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        GradientProgressIndicator(
          value: 0.7,
          gradient: const LinearGradient(
            colors: [Color(0xFFE94560), Color(0xFF0F3460)],
          ),
          backgroundColor: Colors.white.withOpacity(0.1),
          height: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Text(
          '70% complete',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
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
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: 5,
            itemBuilder: (context, index) {
              return EntranceAnimation(
                delay: _staggerDelay * (index * 0.5),
                offset: const Offset(20, 0),
                child: PressableScale(
                  child: _buildPremiumCard(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard(int index) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(
            'https://picsum.photos/seed/${index + 1}/560/440',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0),
              Colors.black.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.5, 1.0],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Featured Item ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
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
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (context, index) => Divider(
            color: Colors.white.withOpacity(0.1),
            height: 1,
          ),
          itemBuilder: (context, index) {
            return EntranceAnimation(
              delay: _staggerDelay * (index * 0.5),
              child: PressableScale(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: Icon(
                      _getActivityIcon(index),
                      color: Colors.white70,
                    ),
                  ),
                  title: Text(
                    'Activity ${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Description for activity ${index + 1}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  trailing: Text(
                    '${index + 1}h ago',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  onTap: HapticFeedback.lightImpact,
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
    return Container(
      decoration: _backgroundDecoration,
      child: const VideoFeedPage(),
    );
  }

  Widget _buildFlowchartTab() {
    return Container(
      decoration: _backgroundDecoration,
      child: FutureBuilder<List<VideoModel>>(
        future: VideoFeedService.instance.getVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final videos = snapshot.data ?? [];

          if (videos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Watch videos to participate in discussions',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return EntranceAnimation(
                delay: _staggerDelay * index,
                child: PressableScale(
                  child: _buildFlowchartCard(video),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFlowchartCard(VideoModel video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: const Color(0xFF16213E).withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black.withOpacity(0.5),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
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
                                    color: Colors.white,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${video.creator}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
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
                  _buildMetaInfo(
                    icon: Icons.account_tree,
                    future: _hasFlowchart(video.id),
                    trueText: 'Discussion Active',
                    falseText: 'Start Discussion',
                  ),
                  _buildMetaInfo(
                    icon: Icons.remove_red_eye,
                    text: '${video.views} views',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaInfo({
    required IconData icon,
    String? text,
    Future<bool>? future,
    String? trueText,
    String? falseText,
  }) {
    Widget textWidget;
    if (text != null) {
      textWidget = Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.white70),
      );
    } else if (future != null && trueText != null && falseText != null) {
      textWidget = FutureBuilder<bool>(
        future: future,
        builder: (context, snapshot) {
          final result = snapshot.data ?? false;
          return Text(
            result ? trueText : falseText,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white70),
          );
        },
      );
    } else {
      textWidget = const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 4),
        textWidget,
      ],
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

  Widget _buildThumbnail(String thumbnailUrl) {
    return Image.asset(
      thumbnailUrl,
      width: 100,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading thumbnail: $thumbnailUrl - $error');
        return const PlaceholderThumbnail();
      },
    );
  }

  Widget _buildDonateTab() {
    return Container(
      decoration: _backgroundDecoration,
      child: const DonationPage(),
    );
  }
}

class PlaceholderThumbnail extends StatelessWidget {
  const PlaceholderThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 60,
      color: Colors.grey.shade800,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
