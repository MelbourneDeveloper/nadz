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

extension OptionToNullable<T> on Option<T> {
  T? toNullable() => switch (this) {
        Some(:final value) => value,
        _ => null,
      };
}

extension NullableToOption<T> on T? {
  Option<T> toOption() => this != null ? Some<T>(this as T) : None<T>();
}

extension IterableOption<T> on Iterable<Option<T>> {
  List<T?> toNullableList() => map((option) => option.toNullable()).toList();
}
