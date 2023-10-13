import 'package:nadz/nadz.dart';

extension ListResultOrErrorNullExtensions<T, E> on ListResultOrError<T, E> {
  T? get firstOrNull => match(
        onRight: (list) => list.isNotEmpty ? list.first : null,
        onLeft: (e) => null,
      );

  T? firstWhereOrNull(bool Function(T) predicate) {
    final iterable = whereOrNull(predicate);

    if (iterable != null && iterable.isNotEmpty) {
      return iterable.first;
    }

    return null;
  }

  int? get lengthOrNull => match(onLeft: (l) => null, onRight: (r) => r.length);

  Iterable<T>? takeOrNull(int i) =>
      match(onLeft: (l) => null, onRight: (r) => r.take(i));

  Iterable<T>? whereOrNull(bool Function(T) predicate) => match(
        onRight: (list) => list.where(predicate),
        onLeft: (e) => null,
      );
}

extension EitherExtensions<L, R> on Either<L, R> {
  R? get rightOrNull => match(onLeft: (l) => null, onRight: (r) => r);
  L? get leftOrNull => match(onLeft: (l) => l, onRight: (r) => null);

  U? mapRightOrNull<U>(U Function(R) transform) =>
      match(onRight: transform, onLeft: (e) => null);
}

extension ResultOrErrorNullExtensions<T, E> on ResultOrError<T, E> {
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
