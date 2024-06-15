import 'package:nadz/nadz.dart';
import 'package:nadz/nully_nadz.dart';
import 'package:test/test.dart';

void main() {
  group('ListResultOrErrorNullExtensions Tests', () {
    test('firstOrNull should return the first element or null', () {
      const result = Success([1, 2, 3]);
      expect(result.firstOrNull, equals(1));

      const error = Error<List<int>, String>('Error');
      expect(error.firstOrNull, isNull);
    });

    test('firstWhereOrNull should return the first matching element or null',
        () {
      const result = Success([1, 2, 3]);
      expect(result.firstWhereOrNull((i) => i.isEven), equals(2));
      expect(result.firstWhereOrNull((i) => i > 3), isNull);

      const error = Error<List<int>, String>('Error');
      expect(error.firstWhereOrNull((i) => i.isEven), isNull);
    });

    test('lengthOrNull should return the length or null', () {
      const result = Success([1, 2, 3]);
      expect(result.lengthOrNull, equals(3));

      const error = Error<List<int>, String>('Error');
      expect(error.lengthOrNull, isNull);
    });

    test('takeOrNull should return the first n elements or null', () {
      const result = Success([1, 2, 3]);
      expect(result.takeOrNull(2), equals([1, 2]));

      const error = Error<List<int>, String>('Error');
      expect(error.takeOrNull(2), isNull);
    });

    test('whereOrNull should return filtered elements or null', () {
      const result = Success([1, 2, 3]);
      expect(result.whereOrNull((i) => i.isEven), equals([2]));

      const error = Error<List<int>, String>('Error');
      expect(error.whereOrNull((i) => i.isEven), isNull);
    });
  });

  group('EitherExtensions Tests', () {
    test('rightOrNull should return right value or null', () {
      const either = Success<int, String>(5);
      expect(either.resultOrNull, equals(5));

      const error = Error<int, String>('Error');
      expect(error.resultOrNull, isNull);
    });

    test('leftOrNull should return left value or null', () {
      const either = Error<int, String>('Error');
      expect(either.errorOrNull, equals('Error'));

      const result = Success<int, String>(5);
      expect(result.errorOrNull, isNull);
    });

    test('mapRightOrNull should transform right value or return null', () {
      const either = Success<int, String>(5);
      expect(either.mapOrNull((i) => i * 2), equals(10));

      const error = Error<int, String>('Error');
      expect(error.mapOrNull((i) => i * 2), isNull);
    });
  });

  group('OptionToNullable and NullableToOption Tests', () {
    test('toNullable should convert Option to nullable', () {
      const option = Some<int>(5);
      expect(option.toNullable(), equals(5));

      const none = None<int>();
      expect(none.toNullable(), isNull);
    });

    test('toOption should convert nullable to Option', () {
      const nullable = 5;
      expect(nullable.toOption().isSome, isTrue);

      const int? nullValue = null;
      expect(nullValue.toOption().isNone, isTrue);
    });

    test('toNullableList should convert List<Option> to List<nullable>', () {
      final options = [const Some<int>(5), const None<int>()];
      expect(options.toNullableList(), equals([5, null]));
    });
  });
}
