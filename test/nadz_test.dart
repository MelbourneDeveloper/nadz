import 'package:nadz/nadz.dart';
import 'package:nadz/nully_nadz.dart';
import 'package:test/test.dart';

class ConcreteEither<L, R> extends EitherBase<L, R> {
  ConcreteEither.left(super.value) : super.left();
  ConcreteEither.right(super.value) : super.right();
}

void main() {
  group('>>', () {
    test('Should transform successful HttpListResultOrStatusCode', () {
      final transformed = HttpListResultOrStatusCode<int>(const [1, 2, 3]) >>
          (list) =>
              HttpListResultOrStatusCode(list.map((item) => item * 2).toList());

      expect(transformed.isSuccess, true);
      expect(transformed.resultOrNull, [2, 4, 6]);
    });

    test('Should maintain error state when using >> operator', () {
      final initial = HttpListResultOrStatusCode<int>.error(404);

      final transformed = initial >>
          ((list) => HttpListResultOrStatusCode(
                list.map((number) => number * 2).toList(),
              ));

      expect(transformed.isError, true);
      expect(transformed.errorOrNull, 404);
    });

    test('Should transform HttpListResultOrStatusCode with complex data type',
        () async {
      final initial = HttpListResultOrStatusCode<List<int>>(
        const [
          [1, 2, 3],
          [4, 5, 6],
        ],
      );

      final transformed = initial >>
          ((list) => HttpListResultOrStatusCode<List<int>>(
                list.map((item) => item.map((i) => i * 2).toList()).toList(),
              ));

      expect(transformed.isSuccess, true);
      expect(transformed.resultOrNull, [
        [2, 4, 6],
        [8, 10, 12],
      ]);
    });

    test('Should filter out even numbers using >> operator', () {
      final initial = HttpListResultOrStatusCode<int>(const [1, 2, 3, 4, 5, 6]);

      final transformed = initial >>
          ((list) => HttpListResultOrStatusCode(
                list.where((item) => item.isOdd).toList(),
              ));

      expect(transformed.isSuccess, true);
      expect(transformed.resultOrNull, [1, 3, 5]);
    });
  });

  group('Option', () {
    test('isSome returns true when Option has a value', () {
      final option = Option(5);
      expect(option.isSome, isTrue);
    });

    test('isNone returns true when Option has no value', () {
      final option = Option<String>.none();
      expect(option.isNone, isTrue);
    });

    test('bind transforms the value inside Option', () {
      final transformed = Option(5) >> ((value) => Option(value * 2));
      expect(transformed | 5, equals(10));
    });

    test('bind does not transform None', () {
      final option = Option<int>.none();
      final transformed = option >> ((value) => Option(value * 2));
      expect(transformed.isNone, isTrue);
    });

    test('Option with value should return Right', () {
      final option = Option(5);
      expect(option.toString(), equals('Option<int> (5)'));
    });

    test('Option with None should return Left(None)', () {
      final option = Option<int>.none();
      expect(option.toString(), equals('Option<int> (None)'));
    });
  });

  group('Nested Monads in Option', () {
    test('Option with HttpListResultOrStatusCode', () {
      final option = Option(HttpListResultOrStatusCode(const [1, 2, 3]));

      expect(option.isSome, isTrue);
      expect(
        option.someOr(() => HttpListResultOrStatusCode.error(404)).isSuccess,
        isTrue,
      );
    });

    test('Option with None should not contain HttpListResultOrStatusCode', () {
      final option = Option<int>.none();

      expect(option.isNone, isTrue);
      expect(
        () => option.someOr(() => throw Exception('No value')),
        throwsException,
      );
    });

    test('Option with ResultOrError', () {
      final option = Option(ResultOrError<int, String>(5));

      expect(option.isSome, isTrue);
      expect(
        option.someOr(() => ResultOrError.error('Error')).isSuccess,
        isTrue,
      );
    });

    test('Option with None should not contain ResultOrError', () {
      final option = Option<DateTime>.none();

      expect(option.isNone, isTrue);
      expect(
        () => option.someOr(() => throw Exception('No value')),
        throwsException,
      );
    });

    test('Nested Option inside Option', () {
      final innerOption = Option(5);
      final outerOption = Option(innerOption);

      expect(outerOption.isSome, isTrue);
      expect(outerOption.someOr(Option.none).isSome, isTrue);
    });

    test('None Option inside Option', () {
      final innerOption = Option<int>.none();
      final outerOption = Option(innerOption);

      expect(outerOption.isSome, isTrue);
      expect(outerOption.someOr(() => Option(5)).isNone, isTrue);
    });

    group('Map function tests', () {
      test('HttpListResultOrStatusCode map without onRight', () {
        final httpList = HttpListResultOrStatusCode<int>(const [1, 2, 3]);
        final mapped = httpList.map(
          (list) => list.map((e) => e.toString()).toList(),
        );

        expect(mapped.isRight, isTrue);
        expect(mapped.rightOrNull, equals(['1', '2', '3']));
      });

      test('Option map without onRight', () {
        final option = Option<int>(5);
        final mapped = option.map(
          (value) => value * 2,
        );

        expect(mapped.isRight, isTrue);
        expect(mapped.rightOrNull, equals(10));
      });

      test('ResultOrError map without onRight', () {
        final result = ResultOrError<int, String>(5);
        final mapped = result.map<int, ResultOrError<int, String>>(
          (value) => value * 2,
        );

        expect(mapped.isRight, isTrue);
        expect(mapped.rightOrNull, equals(10));
      });

      test('HttpListResultOrStatusCode map without onRight with error', () {
        final httpList = HttpListResultOrStatusCode<String>.error(404);
        final mapped = httpList.map(
          (list) => list.map((e) => e).toList(),
        );

        expect(mapped.isLeft, isTrue);
        expect(mapped.leftOrNull, equals(404));
      });
    });
  });

  group('Option and Nullable Conversion Tests', () {
    test('Option to nullable with some value', () {
      final option = Option<int>(5);
      final nullable = option.toNullable();
      expect(nullable, 5);
    });

    test('Option to nullable with none value', () {
      final option = Option<int>.none();
      final nullable = option.toNullable();
      expect(nullable, isNull);
    });

    test('Nullable to option with non-null value', () {
      // ignore: unnecessary_nullable_for_final_variable_declarations
      const int? nullable = 5;
      final option = nullable.toOption();
      expect(option.isSome, isTrue);
      expect(option.toNullable(), 5);
    });

    test('Nullable to option with null value', () {
      int? nullable;
      final option = nullable.toOption();
      expect(option.isNone, isTrue);
      expect(option.toNullable(), isNull);
    });

    test('List of Option to List of nullable', () {
      final options = [Option<int>(5), Option<int>.none()];
      final nullables = options.toNullableList();
      expect(nullables, [5, null]);
    });
  });

  group('Either join method tests', () {
    test('Both Eithers are right', () {
      final either1 = ResultOrError<int, String>(5);
      final either2 = ResultOrError<double, String>(10.5);

      final joined = either1.merge(
        either2,
        (first, second) => ResultOrError((first, second)),
        (first, second) => ResultOrError<(int, double), String>.error(
          first.someOr(() => '') + second.someOr(() => ''),
        ),
      );

      expect(joined.isRight, isTrue);
      expect(joined.rightOrNull, equals((5, 10.5)));
    });

    test('Merge - Both are successful', () {
      final joined = ResultOrError<double, String>(15.6) &
          (
            ResultOrError(10.5),
            (first, second) => ResultOrError((first, second)),
            (first, second) => ResultOrError.error(first | (second | 'Error'))
          );

      expect(joined.isRight, isTrue);
      expect(joined.rightOrNull, equals((15.6, 10.5)));
    });

    test('Merge - second result is an error', () {
      final joined = ResultOrError<double, String>(15.6) &
          (
            ResultOrError.error('Ouch!'),
            (first, second) => ResultOrError((first, second)),
            (first, second) => ResultOrError.error(first | (second | 'Error'))
          );

      expect(joined.isError, isTrue);
      expect(joined.errorOrNull, equals('Ouch!'));
    });

    test('First Either is left, second is right', () {
      final either1 = ResultOrError<int, String>.error('Error1');
      final either2 = ResultOrError<double, String>(10.5);

      final joined = either1.merge(
        either2,
        (first, second) => ResultOrError((first, second)),
        (first, second) => ResultOrError<(int, double), String>.error(
          first.someOr(() => '') + second.someOr(() => ''),
        ),
      );

      expect(joined.isLeft, isTrue);
      expect(
        joined.leftOrNull,
        equals(
          'Error1',
        ),
      ); // Since the first is left, it returns the first error message
    });

    test('Both Eithers are left', () {
      final either1 = ResultOrError<int, String>.error('Error1');
      final either2 = ResultOrError<double, String>.error('Error2');

      final joined = either1.merge(
        either2,
        (first, second) => ResultOrError((first, second)),
        (first, second) => ResultOrError<(int, double), String>.error(
          first.someOr(() => '') + second.someOr(() => ''),
        ),
      );

      expect(joined.isLeft, isTrue);
      expect(
        joined.leftOrNull,
        equals('Error1Error2'),
      ); // Combines both error messages
    });

    test('First Either is right, second is left', () {
      final either1 = ResultOrError<int, String>(5);
      final either2 = ResultOrError<double, String>.error('Error2');

      final joined = either1.merge(
        either2,
        (first, second) => ResultOrError((first, second)),
        (first, second) => ResultOrError<(int, double), String>.error(
          first.someOr(() => '') + second.someOr(() => ''),
        ),
      );

      expect(joined.isLeft, isTrue);
      expect(
        joined.leftOrNull,
        equals(
          'Error2',
        ),
      ); // Since the second is left, it returns the second error message
    });
  });

  group('Either | operator tests', () {
    test('Both Eithers are right with int and double types', () {
      final either1 = ResultOrError<int, String>(5);
      final either2 = ResultOrError<double, String>(10.5);

      final result1 = either1 | 0; // Should return 5 as either1 is right
      final result2 = either2 | 0.0; // Should return 10.5 as either2 is right

      expect(result1, equals(5));
      expect(result2, equals(10.5));
    });

    test('First Either is left, second is right with int and double types', () {
      final either1 = ResultOrError<int, String>.error('Error');
      final either2 = ResultOrError<double, String>(10.5);

      final result1 = either1 | 0; // Should return 0 as either1 is left
      final result2 = either2 | 0.0; // Should return 10.5 as either2 is right

      expect(result1, equals(0));
      expect(result2, equals(10.5));
    });

    test('Both Eithers are left with int and double types', () {
      final either1 = ResultOrError<int, String>.error('Error1');
      final either2 = ResultOrError<double, String>.error('Error2');

      final result1 = either1 | 0; // Should return 0 as either1 is left
      final result2 = either2 | 0.0; // Should return 0.0 as either2 is left

      expect(result1, equals(0));
      expect(result2, equals(0.0));
    });

    test('Using | operator with different default values', () {
      final either1 = ResultOrError<int, String>.error('Error');
      final either2 = ResultOrError<double, String>(10.5);

      final result1 = either1 | 99; // Should return 99 as either1 is left
      final result2 = either2 | 99.9; // Should return 10.5 as either2 is right

      expect(result1, equals(99));
      expect(result2, equals(10.5));
    });
  });

  group('Combined tests for bind, either, and merge operators with Option<T>',
      () {
    test('Test with bind operator and Option<T>', () async {
      final result = ResultOrError<int, String>(5);
      final transformed =
          result >> (value) => ResultOrError<int, String>(value * 2);

      final option = Option(transformed.rightOrNull);
      expect(option.isSome, isTrue);
      expect(option.someOr(() => 0), equals(10));
    });

    test('Test with either operator and Option<T>', () {
      final result = ResultOrError<int, String>.error('Error');
      final value = result | 10;

      final option = Option(value);
      expect(option.isSome, isTrue);
      expect(option.someOr(() => 0), equals(10));
    });
  });

  group('Option Extensions and Special Operators', () {
    test('Option >> operator with a function that returns None', () {
      final option = Option<int>(5);
      final transformed = option >> ((value) => Option<int>.none());
      expect(transformed.isNone, isTrue);
    });

    test('Option | operator with None', () {
      final option = Option<int>.none();
      final result = option | 10;
      expect(result, equals(10));
    });

    test('Option | operator with Some', () {
      final option = Option<int>(5);
      final result = option | 10;
      expect(result, equals(5));
    });
  });

  group('ResultOrError Special Cases', () {
    test('ResultOrError >> operator with error state', () {
      final result = ResultOrError<int, String>.error('Error');
      final transformed =
          result >> ((value) => ResultOrError<int, String>(value * 2));
      expect(transformed.isError, isTrue);
      expect(transformed.errorOrNull, equals('Error'));
    });

    test('ResultOrError & operator with both errors', () {
      final result1 = ResultOrError<int, String>.error('Error1');
      final result2 = ResultOrError<int, String>.error('Error2');

      final merged = result1 &
          (
            result2,
            (first, second) => ResultOrError((first, second)),
            (first, second) =>
                ResultOrError.error(first | (second | 'Unknown Error'))
          );

      expect(merged.isError, isTrue);
      expect(merged.errorOrNull, equals('Error1'));
    });
  });

  group('HttpListResultOrStatusCode Special Cases', () {
    test('HttpListResultOrStatusCode >> operator with error state', () async {
      final initial = HttpListResultOrStatusCode<int>.error(404);

      final transformed = initial >>
          ((list) => HttpListResultOrStatusCode(
                list.map((number) => number * 2).toList(),
              ));

      expect(transformed.isError, isTrue);
      expect(transformed.errorOrNull, equals(404));
    });
  });

  group('Complex Nested Monads', () {
    test('Nested ResultOrError inside Option', () {
      final innerResult = ResultOrError<int, String>(5);
      final option = Option(innerResult);

      expect(option.isSome, isTrue);
      expect(
        option.someOr(() => ResultOrError.error('Error')).isSuccess,
        isTrue,
      );
    });

    test('Nested HttpListResultOrStatusCode inside ResultOrError', () {
      final innerHttp = HttpListResultOrStatusCode<int>(const [1, 2, 3]);
      final result =
          ResultOrError<HttpListResultOrStatusCode<int>, int>(innerHttp);

      expect(result.isSuccess, isTrue);
      expect(
        result
            .resultOr(() => HttpListResultOrStatusCode<int>.error(404))
            .isSuccess,
        isTrue,
      );
    });
  });

  group('ConcreteEither', () {
    test('should contain the left value when created with left', () {
      final either = ConcreteEither<String, int>.left('Error');
      expect(either.isLeft, isTrue);
      expect(either.leftOrNull, 'Error');
      expect(either.isRight, isFalse);
    });

    test('should contain the right value when created with right', () {
      final either = ConcreteEither<String, int>.right(42);
      expect(either.isRight, isTrue);
      expect(either.rightOrNull, 42);
      expect(either.isLeft, isFalse);
    });

    test('should support equality based on the contained value', () {
      final either1 = ConcreteEither<String, int>.left('Error');
      final either2 = ConcreteEither<String, int>.left('Error');
      final either3 = ConcreteEither<String, int>.right(42);

      expect(either1, equals(either2));
      expect(either1, isNot(equals(either3)));
    });
  });
}
