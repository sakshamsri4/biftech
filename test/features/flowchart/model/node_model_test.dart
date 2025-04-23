import 'package:biftech/features/flowchart/model/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NodeModel', () {
    test('can be instantiated', () {
      final node = NodeModel(
        id: 'test_id',
        text: 'Test Node',
      );

      expect(node.id, equals('test_id'));
      expect(node.text, equals('Test Node'));
      expect(node.donation, equals(0));
      expect(node.comments, isEmpty);
      expect(node.challenges, isEmpty);
      expect(node.createdAt, isNotNull);
    });

    test('supports value equality', () {
      final createdAt = DateTime(2023, 4, 25);
      final node1 = NodeModel(
        id: 'test_id',
        text: 'Test Node',
        donation: 10,
        comments: const ['Comment 1', 'Comment 2'],
        createdAt: createdAt,
      );

      final node2 = NodeModel(
        id: 'test_id',
        text: 'Test Node',
        donation: 10,
        comments: const ['Comment 1', 'Comment 2'],
        createdAt: createdAt,
      );

      expect(node1, equals(node2));
    });

    test('copyWith creates a new instance with updated values', () {
      final createdAt = DateTime(2023, 4, 25);
      final node = NodeModel(
        id: 'test_id',
        text: 'Test Node',
        donation: 10,
        comments: const ['Comment 1'],
        createdAt: createdAt,
      );

      final updatedNode = node.copyWith(
        text: 'Updated Text',
        donation: 20,
      );

      expect(updatedNode.id, equals('test_id'));
      expect(updatedNode.text, equals('Updated Text'));
      expect(updatedNode.donation, equals(20));
      expect(updatedNode.comments, equals(['Comment 1']));
      expect(updatedNode.challenges, isEmpty);
      expect(updatedNode.createdAt, equals(createdAt));
    });

    test('addComment adds a comment to the node', () {
      final node = NodeModel(
        id: 'test_id',
        text: 'Test Node',
      );

      final updatedNode = node.addComment('New Comment');

      expect(updatedNode.comments, equals(['New Comment']));
      expect(updatedNode.id, equals(node.id));
      expect(updatedNode.text, equals(node.text));
    });

    test('addChallenge adds a challenge to the node', () {
      final node = NodeModel(
        id: 'test_id',
        text: 'Test Node',
      );

      final challenge = NodeModel(
        id: 'challenge_id',
        text: 'Challenge Node',
      );

      final updatedNode = node.addChallenge(challenge);

      expect(updatedNode.challenges.length, equals(1));
      expect(updatedNode.challenges.first, equals(challenge));
      expect(updatedNode.id, equals(node.id));
      expect(updatedNode.text, equals(node.text));
    });

    test('score returns donation + number of comments', () {
      final node = NodeModel(
        id: 'test_id',
        text: 'Test Node',
        donation: 10,
        comments: const ['Comment 1', 'Comment 2'],
      );

      expect(node.score, equals(12));
    });

    test('toJson converts node to JSON', () {
      final createdAt = DateTime(2023, 4, 25);
      final node = NodeModel(
        id: 'test_id',
        text: 'Test Node',
        donation: 10,
        comments: const ['Comment 1', 'Comment 2'],
        createdAt: createdAt,
      );

      final json = node.toJson();

      expect(json['id'], equals('test_id'));
      expect(json['text'], equals('Test Node'));
      expect(json['donation'], equals(10));
      expect(json['comments'], equals(['Comment 1', 'Comment 2']));
      expect(json['challenges'], isEmpty);
      expect(json['createdAt'], equals(createdAt.toIso8601String()));
    });

    test('fromJson creates node from JSON', () {
      final createdAt = DateTime(2023, 4, 25);
      final json = {
        'id': 'test_id',
        'text': 'Test Node',
        'donation': 10,
        'comments': ['Comment 1', 'Comment 2'],
        'challenges': <Map<String, dynamic>>[],
        'createdAt': createdAt.toIso8601String(),
      };

      final node = NodeModel.fromJson(json);

      expect(node.id, equals('test_id'));
      expect(node.text, equals('Test Node'));
      expect(node.donation, equals(10));
      expect(node.comments, equals(['Comment 1', 'Comment 2']));
      expect(node.challenges, isEmpty);
      expect(node.createdAt, equals(createdAt));
    });

    test('fromJson handles nested challenges', () {
      final createdAt = DateTime(2023, 4, 25);
      final challengeCreatedAt = DateTime(2023, 4, 26);
      final json = {
        'id': 'test_id',
        'text': 'Test Node',
        'donation': 10,
        'comments': ['Comment 1'],
        'challenges': [
          {
            'id': 'challenge_id',
            'text': 'Challenge Node',
            'donation': 5,
            'comments': ['Challenge Comment'],
            'challenges': <Map<String, dynamic>>[],
            'createdAt': challengeCreatedAt.toIso8601String(),
          },
        ],
        'createdAt': createdAt.toIso8601String(),
      };

      final node = NodeModel.fromJson(json);

      expect(node.id, equals('test_id'));
      expect(node.text, equals('Test Node'));
      expect(node.donation, equals(10));
      expect(node.comments, equals(['Comment 1']));
      expect(node.challenges.length, equals(1));

      final challenge = node.challenges.first;
      expect(challenge.id, equals('challenge_id'));
      expect(challenge.text, equals('Challenge Node'));
      expect(challenge.donation, equals(5));
      expect(challenge.comments, equals(['Challenge Comment']));
      expect(challenge.challenges, isEmpty);
      expect(challenge.createdAt, equals(challengeCreatedAt));
    });
  });
}
