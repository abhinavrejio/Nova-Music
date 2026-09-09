import 'package:flutter_riverpod/flutter_riverpod.dart';

class QueueIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }

  void next(int queueLength) {
    if (state < queueLength - 1) {
      state++;
    }
  }

  void previous() {
    if (state > 0) {
      state--;
    }
  }

  void reset() {
    state = 0;
  }
}

final queueIndexProvider =
    NotifierProvider<QueueIndexNotifier, int>(
  QueueIndexNotifier.new,
);