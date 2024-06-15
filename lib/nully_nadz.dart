import 'package:nadz/nadz.dart';

extension ResultExtensions<T, E> on Result<T, E> {
  T? get resultOrNull => switch (this) {
        Success(value: final v) => v,
        _ => null,
      };

  U? mapOrNull<U>(U Function(T) transform) => switch (this) {
        Success(value: final v) => transform(v),
        _ => null,
      };

  U match<U>({
    required U Function(T) onSuccess,
    required U Function(E) onError,
  }) =>
      switch (this) {
        Success(value: final v) => onSuccess(v),
        Error(error: final e) => onError(e),
      };
}

///Extensions for [ListResult]
extension ListResultExtensions<T, E> on ListResult<T, E> {
  ///Returns the list if it is success null otherwise
  T? get firstOrNull => match(
        onSuccess: (list) => list.isNotEmpty ? list.first : null,
        onError: (e) => null,
      );

  ///Returns the first value in the list if it is success null otherwise
  T? firstWhereOrNull(bool Function(T) predicate) {
    final iterable = whereOrNull(predicate);

    if (iterable != null && iterable.isNotEmpty) {
      return iterable.first;
    }

    return null;
  }

  int? get lengthOrNull =>
      match(onError: (l) => null, onSuccess: (r) => r.length);

  Iterable<T>? takeOrNull(int i) =>
      match(onError: (l) => null, onSuccess: (r) => r.take(i));

  Iterable<T>? whereOrNull(bool Function(T) predicate) => match(
        onSuccess: (list) => list.where(predicate),
        onError: (e) => null,
      );
}

extension EitherExtensions<L, R> on Either<L, R> {
  R? get rightOrNull => match(onLeft: (l) => null, onRight: (r) => r);
  L? get leftOrNull => match(onLeft: (l) => l, onRight: (r) => null);

  U? mapRightOrNull<U>(U Function(R) transform) =>
      match(onRight: transform, onLeft: (e) => null);
}

extension ResultOrErrorNullExtensions<T, E> on Result<T, E> {
  T? get resultOrNull => rightOrNull;
  E? get errorOrNull => leftOrNull;
}

extension OptionToNullable<T> on Option<T> {
  T? toNullable() => rightOrNull;
}

extension NullableToOption<T> on T? {
  Option<T> toOption() => this != null ? Option(this as T) : Option.none();
}

extension IterableOption<T> on Iterable<Option<T>> {
  List<T?> toNullableList() => map((option) => option.toNullable()).toList();
}
