import 'package:nadz/nadz.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableState', () {
    test('observers can subscribe to state changes', () {
      final observableState = ObservableState<int>(0);
      var isNotified = false;

      observableState
        ..addObserver((state) {
          isNotified = true;
        })
        ..updateState((state) => 1);

      expect(isNotified, isTrue);
    });

    test('observers receive notifications when state changes', () {
      final observableState = ObservableState<int>(0);
      var notifiedState = -1;

      observableState
        ..addObserver((state) {
          notifiedState = state.someOr(() => -1);
        })
        ..updateState((state) => 42);

      expect(notifiedState, equals(42));
    });

    test('observers stop receiving notifications after being removed', () {
      final observableState = ObservableState<int>(0);
      var isNotified = false;

      void observer(Option<int> state) {
        isNotified = true;
      }

      observableState
        ..addObserver(observer)
        ..removeObserver(observer)
        ..updateState((state) => 1);

      expect(isNotified, isFalse);
    });

    test(
        'weak referenced observers should be unregistered if garbage collected',
        () {
      final observableState = ObservableState<int>(0);
      var notifiedCount = 0;

      // Simulate a weak referenced observer by creating it inside a scope
      // and not keeping a long-lived reference to it.
      {
        void observer(Option<int> state) {
          notifiedCount++;
        }

        observableState.addObserver(observer);
      }

      // Trigger garbage collection indirectly by allocating memory
      List.generate(100000, (index) => 'data');

      observableState
        ..updateState((state) => 1)
        ..updateState((state) => 2);

      // Expect a low number of notifications due to garbage collection
      expect(notifiedCount, anyOf(equals(0), equals(1)));
    });

    test('state updates correctly when `updateState` is called', () {
      final observableState = ObservableState<int>(0);
      var observedState = Option<int>.none();

      observableState
        ..addObserver((state) {
          observedState = state;
        })
        ..updateState((state) => state.someOr(() => 0) + 1);

      expect(observedState.someOr(() => -1), equals(1));
    });

    // Add more tests as needed...
  });
}
