import 'dart:math';
import 'package:biftech/features/auth/model/user_model.dart';
import 'package:biftech/features/auth/service/auth_service.dart';
import 'package:biftech/features/donation/view/donation_page.dart';
import 'package:biftech/features/flowchart/flowchart.dart';
import 'package:biftech/features/flowchart/repository/flowchart_repository.dart';
import 'package:biftech/features/video_feed/service/video_feed_service.dart';
import 'package:biftech/features/video_feed/video_feed.dart';
import 'package:biftech/shared/animations/animations.dart';
import 'package:biftech/shared/theme/dimens.dart';
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
                  color: Colors.white.withAlpha((0.7 * 255).round()),
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
            backgroundColor:
                const Color(0xFF16213E).withAlpha((0.8 * 255).round()),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withAlpha((0.54 * 255).round()),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceL,
        vertical: AppDimens.spaceM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EntranceAnimation(
            delay: _staggerDelay * 2,
            child: _buildWelcomeSection(),
          ),
          const SizedBox(height: AppDimens.spaceXXL),
          EntranceAnimation(
            delay: _staggerDelay * 3,
            child: _buildFeaturedSection(),
          ),
          const SizedBox(height: AppDimens.spaceXXL),
          EntranceAnimation(
            delay: _staggerDelay * 4,
            child: _buildRecentActivitySection(),
          ),
          const SizedBox(height: AppDimens.spaceL),
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
                color: Colors.white.withAlpha((0.7 * 255).round()),
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
        const SizedBox(height: AppDimens.spaceXL),
        Text(
          'Your progress this week:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withAlpha((0.8 * 255).round()),
          ),
        ),
        const SizedBox(height: AppDimens.spaceS),
        GradientProgressIndicator(
          value: 0.7,
          gradient: const LinearGradient(
            colors: [Color(0xFFE94560), Color(0xFF0F3460)],
          ),
          backgroundColor: Colors.white.withAlpha((0.1 * 255).round()),
          height: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: AppDimens.spaceXS),
        Text(
          '70% complete',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withAlpha((0.6 * 255).round()),
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
        const SizedBox(height: AppDimens.spaceM),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: 5,
            itemBuilder: (context, index) {
              return EntranceAnimation(
                delay: _staggerDelay * (index * 0.5),
                offset: const Offset(AppDimens.spaceL, 0),
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
      margin: const EdgeInsets.only(right: AppDimens.spaceL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusXXL),
        image: DecorationImage(
          image: NetworkImage(
            'https://picsum.photos/seed/${index + 1}/560/440',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.4 * 255).round()),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusXXL),
          gradient: LinearGradient(
            colors: [
              Colors.black.withAlpha(0 * 255),
              Colors.black.withAlpha((0.8 * 255).round()),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.5, 1.0],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.spaceM),
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
        const SizedBox(height: AppDimens.spaceM),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (context, index) => Divider(
            color: Colors.white.withAlpha((0.1 * 255).round()),
            height: 1,
          ),
          itemBuilder: (context, index) {
            return EntranceAnimation(
              delay: _staggerDelay * (index * 0.5),
              child: PressableScale(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: AppDimens.spaceXS),
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.white.withAlpha((0.1 * 255).round()),
                    child: Icon(
                      _getActivityIcon(index),
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  title: Text(
                    'Activity ${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Description for activity ${index + 1}',
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                  trailing: Text(
                    '${index + 1}h ago',
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.5 * 255).round()),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                  ),
                  const SizedBox(height: AppDimens.spaceL),
                  Text(
                    'Loading Flowcharts...',
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red.withAlpha((0.3 * 255).round()),
                    ),
                    const SizedBox(height: AppDimens.spaceM),
                    Text(
                      'Oops! Something went wrong.',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.spaceXS),
                    Text(
                      'Failed to load flowchart data. Please try again later.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha((0.7 * 255).round()),
                          ),
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
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      size: 80,
                      color: Colors.purple.withAlpha((0.2 * 255).round()),
                    ),
                    const SizedBox(height: AppDimens.spaceL),
                    Text(
                      'No Flowcharts Yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Discussions haven't started for any videos. "
                      'Watch a video and be the first!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha((0.7 * 255).round()),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimens.spaceM),
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

  ({Color start, Color end}) _getDynamicCardColors(String videoId) {
    final random = Random(videoId.hashCode);
    final hue = random.nextDouble() * 360;
    final saturation = 0.4 + random.nextDouble() * 0.2;
    final lightness = 0.15 + random.nextDouble() * 0.1;

    final startColor =
        HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
    final endColor = HSLColor.fromAHSL(
      1,
      (hue + 20) % 360,
      saturation,
      lightness + 0.05,
    ).toColor();

    return (start: startColor, end: endColor);
  }

  Widget _buildFlowchartCard(VideoModel video) {
    const cardInnerPadding = EdgeInsets.all(AppDimens.spaceM);
    const cardMargin = EdgeInsets.only(bottom: AppDimens.spaceL);
    final cardBorderRadius = BorderRadius.circular(18);
    final cardShape = RoundedRectangleBorder(borderRadius: cardBorderRadius);

    final cardColors = _getDynamicCardColors(video.id);

    final cardBackgroundGradient = LinearGradient(
      colors: [cardColors.start, cardColors.end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    const statusActiveGradient = LinearGradient(
      colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
    );
    final statusInactiveColor = Colors.white.withAlpha((0.24 * 255).round());

    return Card(
      margin: cardMargin,
      elevation: AppDimens.spaceXS,
      shape: cardShape,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withAlpha((0.5 * 255).round()),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(
            context,
            '/flowchart/${video.id}',
            arguments: video,
          );
        },
        borderRadius: cardBorderRadius,
        child: Container(
          decoration: BoxDecoration(
            gradient: cardBackgroundGradient,
          ),
          child: Padding(
            padding: cardInnerPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildThumbnail(video.thumbnailUrl),
                    ),
                    const SizedBox(width: AppDimens.spaceS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 17,
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  blurRadius: 2,
                                  color: Colors.black
                                      .withAlpha((0.5 * 255).round()),
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'by ${video.creator}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Colors.white.withAlpha((0.85 * 255).round()),
                              shadows: [
                                Shadow(
                                  blurRadius: 1,
                                  color: Colors.black
                                      .withAlpha((0.5 * 255).round()),
                                  offset: const Offset(0.5, 0.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.purpleAccent.withAlpha((0.8 * 255).round()),
                      size: AppDimens.spaceXL,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spaceM),
                Wrap(
                  spacing: AppDimens.spaceS,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildMetaInfo(
                      icon: Icons.account_tree_outlined,
                      future: _hasFlowchart(video.id),
                      trueText: 'Discussion Active',
                      falseText: 'Start Discussion',
                      activeGradient: statusActiveGradient,
                      inactiveColor: statusInactiveColor,
                      isStatusBadge: true,
                    ),
                    _buildMetaInfo(
                      icon: Icons.remove_red_eye_outlined,
                      iconColor: Colors.white.withAlpha((0.7 * 255).round()),
                      text: '${video.views} views',
                      textColor: Colors.white.withAlpha((0.85 * 255).round()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaInfo({
    required IconData icon,
    Color? iconColor,
    String? text,
    Color? textColor,
    Future<bool>? future,
    String? trueText,
    String? falseText,
    Gradient? activeGradient,
    Color? inactiveColor,
    bool isStatusBadge = false,
  }) {
    Widget contentWidget;
    final defaultTextColor = Colors.white.withAlpha((0.85 * 255).round());

    if (isStatusBadge &&
        future != null &&
        trueText != null &&
        falseText != null) {
      contentWidget = FutureBuilder<bool>(
        future: future,
        builder: (context, snapshot) {
          final isActive = snapshot.data ?? false;
          final statusText = isActive ? trueText : falseText;
          final badgeColor = isActive ? null : inactiveColor;
          final badgeGradient = isActive ? activeGradient : null;
          final statusTextColor = isActive
              ? Colors.white
              : Colors.white.withAlpha((0.7 * 255).round());

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor,
              gradient: badgeGradient,
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: statusTextColor.withAlpha((0.8 * 255).round()),
                ),
                const SizedBox(width: 5),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          );
        },
      );
    } else if (text != null) {
      contentWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimens.spaceM,
            color: iconColor ?? Colors.white.withAlpha((0.7 * 255).round()),
          ),
          const SizedBox(width: AppDimens.spaceXXS),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: textColor ?? defaultTextColor),
          ),
        ],
      );
    } else {
      contentWidget = const SizedBox.shrink();
    }

    return contentWidget;
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
