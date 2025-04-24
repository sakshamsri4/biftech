import 'package:flutter/material.dart';

// This is a simple script to generate placeholder screenshots
// Run it with: flutter run -d chrome create_placeholders.dart
void main() {
  runApp(const PlaceholderApp());
}

class PlaceholderApp extends StatelessWidget {
  const PlaceholderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PlaceholderGenerator(),
    );
  }
}

class PlaceholderGenerator extends StatefulWidget {
  const PlaceholderGenerator({super.key});

  @override
  State<PlaceholderGenerator> createState() => _PlaceholderGeneratorState();
}

class _PlaceholderGeneratorState extends State<PlaceholderGenerator> {
  final List<String> screens = [
    'auth',
    'video_feed',
    'flowchart',
    'comments',
    'donation',
    'winner',
  ];

  final List<String> titles = [
    'Authentication',
    'Video Feed',
    'Flowchart View',
    'Comments',
    'Donation',
    'Winner Screen',
  ];

  final List<IconData> icons = [
    Icons.login,
    Icons.video_library,
    Icons.account_tree,
    Icons.comment,
    Icons.attach_money,
    Icons.emoji_events,
  ];

  final List<Color> colors = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biftech Screenshot Placeholders'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 9 / 16, // Mobile screen aspect ratio
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: screens.length,
        itemBuilder: (context, index) {
          return PlaceholderCard(
            title: titles[index],
            icon: icons[index],
            color: colors[index],
            filename: screens[index],
          );
        },
      ),
    );
  }
}

class PlaceholderCard extends StatelessWidget {
  const PlaceholderCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.filename,
    super.key,
  });
  final String title;
  final IconData icon;
  final Color color;
  final String filename;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: color.withAlpha(128), width: 2), // 0.5 opacity
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: color,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Biftech',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              // In a real app, this would save the screenshot
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Screenshot "$filename.png" saved'),
                  backgroundColor: color,
                ),
              );
            },
            child: const Text('Save Screenshot'),
          ),
        ],
      ),
    );
  }
}
