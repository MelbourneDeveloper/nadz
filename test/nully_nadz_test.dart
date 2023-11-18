import 'package:nadz/nadz.dart';
import 'package:nadz/nully_nadz.dart';
import 'package:test/test.dart';

void main() {
  group('ListResultOrErrorNullExtensions Tests', () {
    test('firstOrNull should return the first element or null', () {
      final result = ListResult<int, String>([1, 2, 3]);
      expect(result.firstOrNull, equals(1));

      final error = ListResult<int, String>.error('Error');
      expect(error.firstOrNull, isNull);
    });

    test('firstWhereOrNull should return the first matching element or null',
        () {
      final result = ListResult<int, String>([1, 2, 3]);
      expect(result.firstWhereOrNull((i) => i.isEven), equals(2));
      expect(result.firstWhereOrNull((i) => i > 3), isNull);

      final error = ListResult<int, String>.error('Error');
      expect(error.firstWhereOrNull((i) => i.isEven), isNull);
    });

    test('lengthOrNull should return the length or null', () {
      final result = ListResult<int, String>([1, 2, 3]);
      expect(result.lengthOrNull, equals(3));

      final error = ListResult<int, String>.error('Error');
      expect(error.lengthOrNull, isNull);
    });

    test('takeOrNull should return the first n elements or null', () {
      final result = ListResult<int, String>([1, 2, 3]);
      expect(result.takeOrNull(2), equals([1, 2]));

      final error = ListResult<int, String>.error('Error');
      expect(error.takeOrNull(2), isNull);
    });

    test('whereOrNull should return filtered elements or null', () {
      final result = ListResult<int, String>([1, 2, 3]);
      expect(result.whereOrNull((i) => i.isEven), equals([2]));

      final error = ListResult<int, String>.error('Error');
      expect(error.whereOrNull((i) => i.isEven), isNull);
    });
  });

  group('EitherExtensions Tests', () {
    test('rightOrNull should return right value or null', () {
      final either = Result<int, String>(5);
      expect(either.rightOrNull, equals(5));

      final error = Result<int, String>.error('Error');
      expect(error.rightOrNull, isNull);
    });

    test('leftOrNull should return left value or null', () {
      final either = Result<int, String>.error('Error');
      expect(either.leftOrNull, equals('Error'));

      final result = Result<int, String>(5);
      expect(result.leftOrNull, isNull);
    });

    test('mapRightOrNull should transform right value or return null', () {
      final either = Result<int, String>(5);
      expect(either.mapRightOrNull((i) => i * 2), equals(10));

      final error = Result<int, String>.error('Error');
      expect(error.mapRightOrNull((i) => i * 2), isNull);
    });
  });

  group('OptionToNullable and NullableToOption Tests', () {
    test('toNullable should convert Option to nullable', () {
      final option = Option<int>(5);
      expect(option.toNullable(), equals(5));

      final none = Option<int>.none();
      expect(none.toNullable(), isNull);
    });

    test('toOption should convert nullable to Option', () {
      const nullable = 5;
      expect(nullable.toOption().isSome, isTrue);
      expect(nullable.toOption() | 0, equals(5));

      const int? nullValue = null;
      expect(nullValue.toOption().isNone, isTrue);
    });

    test('toNullableList should convert List<Option> to List<nullable>', () {
      final options = [Option<int>(5), Option<int>.none()];
      expect(options.toNullableList(), equals([5, null]));
    });
  });
}
