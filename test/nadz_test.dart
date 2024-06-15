import 'package:nadz/nadz.dart';
import 'package:nadz/nully_nadz.dart';
import 'package:test/test.dart';

void main() {
  group('>>', () {
    test('Should transform successful HttpListResultOrStatusCode', () {
      final transformed = const Success<List<int>, int>([1, 2, 3]) >>
          (list) => Success(list.map((item) => item * 2).toList());

      expect(transformed.isSuccess, true);
      expect(transformed.resultOrNull, [2, 4, 6]);
    });

    test('Should maintain error state when using >> operator', () {
      const initial = Error<List<int>, int>(404);

      final transformed = initial >>
          ((list) => Success(
                list.map((number) => number * 2).toList(),
              ));

      expect(transformed.isError, true);
      expect(transformed.errorOrNull, 404);
    });

    test('Should transform HttpListResultOrStatusCode with complex data type',
        () async {
      const initial = Success(
        [
          [1, 2, 3],
          [4, 5, 6],
        ],
      );

      final transformed = initial >>
          ((list) => Success(
                list.map((item) => item.map((i) => i * 2).toList()).toList(),
              ));

      expect(transformed.isSuccess, true);
      expect(transformed.resultOrNull, [
        [2, 4, 6],
        [8, 10, 12],
      ]);
    });

    test('Should filter out even numbers using >> operator', () {
      const initial = Success([1, 2, 3, 4, 5, 6]);

      final transformed = initial >>
          ((list) => Success(
                list.where((item) => item.isOdd).toList(),
              ));

      expect(transformed.isSuccess, true);
      expect(transformed.resultOrNull, [1, 3, 5]);
    });
  });

  group('Option', () {
    test('isSome returns true when Option has a value', () {
      const option = Some(5);
      expect(option.isSome, isTrue);
    });

    test('isNone returns true when Option has no value', () {
      const option = None();
      expect(option.isNone, isTrue);
    });

    test('bind transforms the value inside Option', () {
      final transformed = const Some(5) >> ((value) => Some(value * 2));
      expect(transformed.toNullable(), equals(10));
    });

    test('bind does not transform None', () {
      const option = None<int>();
      final transformed = option >> ((value) => Some(value * 2));
      expect(transformed.isNone, isTrue);
    });

    test('Option with value should return Right', () {
      const option = Some(5);
      expect(option.toString(), equals('Option<int> (5)'));
    });

    test('Option with None should return Left(None)', () {
      const option = None();
      expect(option.toString(), equals('Option<int> (None)'));
    });
  });

  group('Nested Monads in Option', () {
    test('Option with HttpListResultOrStatusCode', () {
      const option = Some<ListResult<int, int>>(Success([1, 2, 3]));

      expect(option.isSome, isTrue);
      expect(
        option.someOr(() => const Error(404)).isSuccess,
        isTrue,
      );
    });

    test('Option with None should not contain HttpListResultOrStatusCode', () {
      const option = None();

      expect(option.isNone, isTrue);
      expect(
        () => option.someOr(() => throw Exception('No value')),
        throwsException,
      );
    });

    test('Option with ResultOrError', () {
      const Option<Result<int, String>> option = Some(Success<int, String>(5));

      expect(option.isSome, isTrue);
      expect(
        option.someOr(() => const Error<int, String>('Error')).isSuccess,
        isTrue,
      );
    });

    test('Option with None should not contain ResultOrError', () {
      const option = None();

      expect(option.isNone, isTrue);
      expect(
        () => option.someOr(() => throw Exception('No value')),
        throwsException,
      );
    });

    test('Nested Option inside Option', () {
      const innerOption = Some(5);
      const Option<Option<int>> outerOption = Some(innerOption);

      expect(outerOption.isSome, isTrue);
      expect(outerOption.someOr(() => const None<int>()).isSome, isTrue);
    });

    group('Map function tests', () {
      test('successOrNull', () {
        const httpList = Success([1, 2, 3]);
        final mapped = httpList.map(
          (list) => list.map((e) => e.toString()).toList(),
        );

        expect(mapped.isSuccess, isTrue);
        expect(mapped.resultOrNull, equals(['1', '2', '3']));
      });

      test('ResultOrError map without onRight', () {
        const result = Success<int, String>(5);
        final mapped = result.map(
          (value) => value * 2,
        );

        expect(mapped.isSuccess, isTrue);
        expect(mapped.resultOrNull, equals(10));
      });

      test('HttpListResultOrStatusCode map without onRight with error', () {
        const httpList = Error<List<int>, int>(404);
        final mapped = httpList.map(
          (list) => list.map((e) => e).toList(),
        );

        expect(mapped.isError, isTrue);
        expect(mapped.errorOrNull(), equals(404));
      });
    });
  });

  group('Option and Nullable Conversion Tests', () {
    test('Option to nullable with some value', () {
      const option = Some<int>(5);
      final nullable = option.toNullable();
      expect(nullable, 5);
    });

    test('Option to nullable with none value', () {
      const option = None<int>();
      final nullable = option.toNullable();
      expect(nullable, isNull);
    });

    test('Nullable to option with non-null value', () {
      // ignore: unnecessary_nullable_for_const_variable_declarations, unnecessary_nullable_for_final_variable_declarations
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
      const options = [Some<int>(5), None<int>()];
      final nullables = options.toNullableList();
      expect(nullables, [5, null]);
    });
  });

  group('Either join method tests', () {
    test('Both Eithers are right', () {
      const either1 = Success<int, String>(5);
      const either2 = Success<double, String>(10.5);

      final joined = either1.merge(
        either2,
        (first, second) => Success((first, second)),
        (first, second) => Error<(int, double), String>(
          first.someOr(() => '') + second.someOr(() => ''),
        ),
      );

      expect(joined.isSuccess, isTrue);
      expect(joined.resultOrNull, equals((5, 10.5)));
    });

    test('Merge - Both are successful', () {
      const joined = Success<double, String>(15.6) &
          (
            Result(10.5),
            (first, second) => Result((first, second)),
            (first, second) => Result.error(first | (second | 'Error'))
          );

      expect(joined.isSuccess, isTrue);
      expect(joined.resultOrNull, equals((15.6, 10.5)));
    });

    test('Merge - second result is an error', () {
      const joined = Success<double, String>(15.6) &
          (
            Result.error('Ouch!'),
            (first, second) => Result((first, second)),
            (first, second) => Result.error(first | (second | 'Error'))
          );

      expect(joined.isError, isTrue);
      expect(joined.errorOrNull, equals('Ouch!'));
    });

    test('First Either is left, second is right', () {
      const either1 = Error<int, String>('Error1');
      const either2 = Success<double, String>(10.5);

      const joined = either1.merge(
        either2,
        (first, second) => Result((first, second)),
        (first, second) => Result<(int, double), String>.error(
          first.someOr(() => '') + second.someOr(() => ''),
        ),
      );

      expect(joined.isError, isTrue);
      expect(
        joined.errorOrNull,
        equals(
          'Error1',
        ),
      ); // Since the first is left, it returns the first error message
    });

    test('Both Eithers are left', () {
      const either1 = Error<int, String>('Error1');
      const either2 = Result<double, String>.error('Error2');

      const joined = either1.merge(
        either2,
        (first, second) => Result((first, second)),
        (first, second) => Result<(int, double), String>.error(
          first.someOr(() => '') + second.someOr(() => ''),
        ),
      );

      expect(joined.isError, isTrue);
      expect(
        joined.errorOrNull,
        equals('Error1Error2'),
      ); // Combines both error messages
    });

    test('First Either is right, second is left', () {
      const either1 = Success<int, String>(5);
      const either2 = Error<double, String>('Error2');

      const joined = either1.merge(
        either2,
        (first, second) => Result((first, second)),
        (first, second) => Result<(int, double), String>.error(
          first.someOr(() => '') + second.someOr(() => ''),
        ),
      );

      expect(joined.isError, isTrue);
      expect(
        joined.errorOrNull,
        equals(
          'Error2',
        ),
      ); // Since the second is left, it returns the second error message
    });
  });

  group('Either | operator tests', () {
    test('Both Eithers are right with int and double types', () {
      const either1 = Success<int, String>(5);
      const either2 = Success<double, String>(10.5);

      final result1 = either1 | 0; // Should return 5 as either1 is right
      final result2 = either2 | 0.0; // Should return 10.5 as either2 is right

      expect(result1, equals(5));
      expect(result2, equals(10.5));
    });

    test('First Either is left, second is right with int and double types', () {
      const either1 = Error<int, String>('Error');
      const either2 = Success<double, String>(10.5);

      final result1 = either1 | 0; // Should return 0 as either1 is left
      final result2 = either2 | 0.0; // Should return 10.5 as either2 is right

      expect(result1, equals(0));
      expect(result2, equals(10.5));
    });

    test('Both Eithers are left with int and double types', () {
      const either1 = Error<int, String>('Error1');
      final either2 = Result<double, String>.error('Error2');

      final result1 = either1 | 0; // Should return 0 as either1 is left
      final result2 = either2 | 0.0; // Should return 0.0 as either2 is left

      expect(result1, equals(0));
      expect(result2, equals(0.0));
    });

    test('Using | operator with different default values', () {
      const either1 = Error<int, String>('Error');
      const either2 = Success<double, String>(10.5);

      final result1 = either1 | 99; // Should return 99 as either1 is left
      final result2 = either2 | 99.9; // Should return 10.5 as either2 is right

      expect(result1, equals(99));
      expect(result2, equals(10.5));
    });
  });

  group('Combined tests for bind, either, and merge operators with Option<T>',
      () {
    test('Test with bind operator and Option<T>', () async {
      const result = Success<int, String>(5);
      final transformed = result >> (value) => Success<int, String>(value * 2);

      const option = Option(transformed.resultOrNull);
      expect(option.isSome, isTrue);
      expect(option.someOr(() => 0), equals(10));
    });

    test('Test with either operator and Option<T>', () {
      const result = Error<int, String>('Error');
      final value = result | 10;

      final option = Some(value);
      expect(option.isSome, isTrue);
      expect(option.someOr(() => 0), equals(10));
    });
  });

  group('Option Extensions and Special Operators', () {
    test('Option >> operator with a function that returns None', () {
      const option = Some<int>(5);
      final transformed = option >> ((value) => const None<int>());
      expect(transformed.isNone, isTrue);
    });

    test('Option | operator with None', () {
      const option = Option<int>.none();
      const result = option | 10;
      expect(result, equals(10));
    });

    test('Option | operator with Some', () {
      const option = Option<int>(5);
      const result = option | 10;
      expect(result, equals(5));
    });
  });

  group('ResultOrError Special Cases', () {
    test('ResultOrError >> operator with error state', () {
      const result = Error<int, String>('Error');
      final transformed =
          result >> ((value) => Success<int, String>(value * 2));
      expect(transformed.isError, isTrue);
      expect(transformed.errorOrNull, equals('Error'));
    });

    test('ResultOrError & operator with both errors', () {
      const result1 = Error<int, String>('Error1');
      const result2 = Error<int, String>('Error2');

      const merged = result1 &
          (
            result2,
            (first, second) => Success((first, second)),
            (first, second) => Error(first | (second | 'Unknown Error'))
          );

      expect(merged.isError, isTrue);
      expect(merged.errorOrNull, equals('Error1'));
    });
  });

  group('HttpListResultOrStatusCode Special Cases', () {
    test('HttpListResultOrStatusCode >> operator with error state', () async {
      const initial = HttpListResultOrStatusCode<int>.error(404);

      const transformed = initial >>
          ((list) => HttpListResultOrStatusCode(
                list.map((number) => number * 2).toList(),
              ));

      expect(transformed.isError, isTrue);
      expect(transformed.errorOrNull, equals(404));
    });
  });

  group('Complex Nested Monads', () {
    test('Nested ResultOrError inside Option', () {
      const innerResult = Success<int, String>(5);
      const option = Option(innerResult);

      expect(option.isSome, isTrue);
      expect(
        option.someOr(() => Result.error('Error')).isSuccess,
        isTrue,
      );
    });

    test('Nested HttpListResultOrStatusCode inside ResultOrError', () {
      const innerHttp = Success([1, 2, 3]);
      const result = Success(innerHttp);

      expect(result.isSuccess, isTrue);
      expect(
        result.resultOr(() => const Error(404)).isSuccess,
        isTrue,
      );
    });
  });

  group('ConcreteEither', () {
    test('should contain the left value when created with left', () {
      const either = Error<int,String>('Error');
      expect(either.isError, isTrue);
      expect(either.errorOrNull, 'Error');
      expect(either.isSuccess, isFalse);
    });

    test('should contain the right value when created with right', () {
      const either = Success<int, String>(42);
      expect(either.isSuccess, isTrue);
      expect(either.resultOrNull, 42);
      expect(either.isError, isFalse);
    });

    test('should support equality based on the contained value', () {
      const either1 = Error<int, String>('Error');
      const either2 = Error<int, String>('Error');
      const either3 = Success<int, String>(42);

      expect(either1, equals(either2));
      expect(either1, isNot(equals(either3)));
    });
  });

  group('Result match', () {
    test('should return correct match on success', () {
      const result = Success<int, String>(1);
      expect(result.match(onSuccess: (n) => n, onError: (e) => -1), 1);
    });

    test('should return correct match on error', () {
      const result = Error<int, String>('ouch');
      expect(
        result.match(onSuccess: (n) => 'yep', onError: (e) => 'nup $e'),
        'nup ouch',
      );
    });
  });
}
