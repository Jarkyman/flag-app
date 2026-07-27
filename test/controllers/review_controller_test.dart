import 'package:flag_app/controllers/review_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewController milestone', () {
    test('waits until the player has meaningful engagement', () {
      expect(
        ReviewController.hasReachedReviewMilestone(
          trainingScore: 9,
          completedLevels: 9,
        ),
        isFalse,
      );
    });

    test('is reached by a training score of ten', () {
      expect(
        ReviewController.hasReachedReviewMilestone(
          trainingScore: 10,
          completedLevels: 0,
        ),
        isTrue,
      );
    });

    test('is reached by ten completed levels', () {
      expect(
        ReviewController.hasReachedReviewMilestone(
          trainingScore: 0,
          completedLevels: 10,
        ),
        isTrue,
      );
    });
  });
}
