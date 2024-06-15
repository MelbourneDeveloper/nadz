import 'package:nadz/nadz.dart';

/// Extensions for [Result]
extension NullResultExtensions<T, E> on Result<T, E> {
  /// Returns the result a the specified value
  T? get resultOrNull => switch (this) {
        Success(value: final v) => v,
        _ => null,
      };

  /// Returns a transformed value or null
  U? mapOrNull<U>(U Function(T) transform) => switch (this) {
        Success(value: final v) => transform(v),
        _ => null,
      };

  /// Returns the error if it exists, otherwise null
  E? get errorOrNull => switch (this) {
        Error(error: final v) => v,
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

  /// Returns the length of the list if it is success null otherwise
  int? get lengthOrNull =>
      match(onError: (l) => null, onSuccess: (r) => r.length);

  /// Returns the first n elements of the list if it is success or null
  Iterable<T>? takeOrNull(int i) =>
      match(onError: (l) => null, onSuccess: (r) => r.take(i));

  /// Returns the filtered elements of the list if it is success or null
  Iterable<T>? whereOrNull(bool Function(T) predicate) => match(
        onSuccess: (list) => list.where(predicate),
        onError: (e) => null,
      );
}

/// Extensions for [Option]
extension OptionToNullable<T> on Option<T> {
  /// Returns the value if it exists, otherwise null
  T? toNullable() => switch (this) {
        Some(:final value) => value,
        _ => null,
      };
}

/// Create [Option] from nullable value
extension NullableToOption<T> on T? {
  /// Returns [Some] if the value is not null, otherwise [None]
  Option<T> toOption() => this != null ? Some<T>(this as T) : None<T>();
}

/// Extensions for [Iterable<Option<T>>]
extension IterableOption<T> on Iterable<Option<T>> {
  /// Returns a list of nullable values
  List<T?> toNullableList() => map((option) => option.toNullable()).toList();
}
