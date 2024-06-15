import 'package:nadz/nadz.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableState', () {
    test('some', () {
      final observableState = ObservableState<String>('test');
      expect(observableState.state.isSome, isTrue);
      expect(observableState.state.someOr(() => ''), equals('test'));
    });

    test('none', () {
      final observableState = ObservableState<String>.none();
      expect(observableState.state.isNone, isTrue);
      expect(observableState.state.someOr(() => ''), equals(''));
    });

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

    test('state updates correctly when `updateState` is called', () {
      final observableState = ObservableState<int>(0);
      Option<int> observedState = const None<int>();

      observableState
        ..addObserver((state) {
          observedState = state;
        })
        ..updateState((state) => state.someOr(() => 0) + 1);

      expect(observedState.someOr(() => -1), equals(1));
    });
  });
}
