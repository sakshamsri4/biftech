import 'package:biftech/features/auth/model/user_model.dart';
import 'package:biftech/features/auth/service/auth_service.dart';
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
      Navigator.of(context).pushReplacementNamed('/login');
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
                    _currentUser!.name.substring(0, 1).toUpperCase(),
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
                        _currentUser!.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                          color: Colors.black.withOpacity(0.7),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_collection,
            size: 100,
            color: Colors.blue.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            'Video Feed',
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

  Widget _buildFlowchartTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_tree,
            size: 100,
            color: Colors.blue.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            'Flowchart',
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
