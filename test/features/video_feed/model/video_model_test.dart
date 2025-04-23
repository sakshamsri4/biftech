import 'package:biftech/features/video_feed/model/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoModel', () {
    test('supports value equality', () {
      expect(
        const VideoModel(
          id: 'test-id',
          title: 'Test Video',
          creator: 'Test Creator',
          views: 1000,
          thumbnailUrl: 'https://example.com/thumbnail.jpg',
        ),
        equals(
          const VideoModel(
            id: 'test-id',
            title: 'Test Video',
            creator: 'Test Creator',
            views: 1000,
            thumbnailUrl: 'https://example.com/thumbnail.jpg',
          ),
        ),
      );
    });

    test('fromJson creates correct model', () {
      final json = {
        'id': 'test-id',
        'title': 'Test Video',
        'creator': 'Test Creator',
        'views': 1000,
        'thumbnailUrl': 'https://example.com/thumbnail.jpg',
        'description': 'Test description',
        'duration': '10:30',
        'publishedAt': '2023-05-15T14:30:00Z',
        'tags': ['tag1', 'tag2'],
      };

      final model = VideoModel.fromJson(json);

      expect(model.id, equals('test-id'));
      expect(model.title, equals('Test Video'));
      expect(model.creator, equals('Test Creator'));
      expect(model.views, equals(1000));
      expect(model.thumbnailUrl, equals('https://example.com/thumbnail.jpg'));
      expect(model.description, equals('Test description'));
      expect(model.duration, equals('10:30'));
      expect(model.publishedAt, equals('2023-05-15T14:30:00Z'));
      expect(model.tags, equals(['tag1', 'tag2']));
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'test-id',
        'title': 'Test Video',
        'creator': 'Test Creator',
        'views': 1000,
        'thumbnailUrl': 'https://example.com/thumbnail.jpg',
      };

      final model = VideoModel.fromJson(json);

      expect(model.id, equals('test-id'));
      expect(model.title, equals('Test Video'));
      expect(model.creator, equals('Test Creator'));
      expect(model.views, equals(1000));
      expect(model.thumbnailUrl, equals('https://example.com/thumbnail.jpg'));
      expect(model.description, equals(''));
      expect(model.duration, equals(''));
      expect(model.publishedAt, equals(''));
      expect(model.tags, equals([]));
    });

    test('toJson creates correct map', () {
      const model = VideoModel(
        id: 'test-id',
        title: 'Test Video',
        creator: 'Test Creator',
        views: 1000,
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        description: 'Test description',
        duration: '10:30',
        publishedAt: '2023-05-15T14:30:00Z',
        tags: ['tag1', 'tag2'],
      );

      final json = model.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['title'], equals('Test Video'));
      expect(json['creator'], equals('Test Creator'));
      expect(json['views'], equals(1000));
      expect(json['thumbnailUrl'], equals('https://example.com/thumbnail.jpg'));
      expect(json['description'], equals('Test description'));
      expect(json['duration'], equals('10:30'));
      expect(json['publishedAt'], equals('2023-05-15T14:30:00Z'));
      expect(json['tags'], equals(['tag1', 'tag2']));
    });

    test('copyWith returns a new instance with updated values', () {
      const original = VideoModel(
        id: 'test-id',
        title: 'Test Video',
        creator: 'Test Creator',
        views: 1000,
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
      );

      final copy = original.copyWith(
        title: 'Updated Title',
        views: 2000,
      );

      expect(copy.id, equals('test-id'));
      expect(copy.title, equals('Updated Title'));
      expect(copy.creator, equals('Test Creator'));
      expect(copy.views, equals(2000));
      expect(copy.thumbnailUrl, equals('https://example.com/thumbnail.jpg'));
    });
  });
}
