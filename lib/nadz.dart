// Types

typedef IterableResult<T, E> = Result<Iterable<T>, E>;
typedef ListResult<T, E> = Result<List<T>, E>;
typedef HttpListResultOrStatusCode<T> = ListResult<T, int>;

/// Success result (right)
class Success<T, E> extends Result<T, E> {
  /// Constructs a success result
  const Success(this.value);

  /// The successful value
  final T value;

  @override
  String toString() => 'Success ($value)';
}

/// Error result (left)
class Error<T, E> extends Result<T, E> {
  /// Constructs an error result
  const Error(this.error);

  /// The error
  final E error;

  @override
  String toString() => 'Error ($error)';
}

/// Encapsulates either a result (value of generic type T) or an error
/// (value of generic type E).
sealed class Result<T, E> {
  const Result();

  /// Whether or not that the result was a success
  bool get isSuccess => this is Success<T, E>;

  /// Whether or the not the result was an error
  bool get isError => this is Error<T, E>;
}

/// None represents the absence of a value in [Option].
class None<T> extends Option<T> {
  /// Constructs nothing
  const None();

  @override
  String toString() => 'None';
}

/// Represents a value in [Option]
class Some<T> extends Option<T> {
  /// Constructs something
  const Some(this.value) : super();

  /// The value
  final T value;

  @override
  String toString() => 'Some ($value)';
}

/// Option type is used to represent optional values that could either be
/// 'Some' or 'None'.
sealed class Option<T> {
  const Option();

  /// Returns true if the option is Some, false otherwise.
  bool get isSome => this is Some;

  /// Returns true if the option is None, false otherwise.
  bool get isNone => !isSome;
}

/// Encapsulates a state value that can be observed by external observers.
class ObservableState<S> {
  /// Creates a new instance of ObservableState with an initial state.
  ObservableState(S initialState) : _state = Some(initialState);

  /// Creates a new instance of ObservableState with no initial state.
  ObservableState.none() : _state = None<S>();

  /// The current state wrapped in an Option.
  Option<S> _state;

  /// Returns the current state.
  Option<S> get state => _state;
  final List<WeakReference<void Function(Option<S>)>> _observers = [];
}

//------------ Extensions ------------

extension ResultExtensions<T, E> on Result<T, E> {
  T resultOr(T or) => switch (this) {
        Success(value: final v) => v,
        _ => or,
      };

  U match<U>({
    required U Function(T) onSuccess,
    required U Function(E) onError,
  }) =>
      switch (this) {
        Success(:final value) => onSuccess(value),
        Error(error: final e) => onError(e),
      };

  /// Returns the success value if it exists, otherwise returns [or]
  T operator |(
    T or,
  ) =>
      switch (this) {
        Success(:final value) => value,
        Error() => or,
      };

  /// Performs a [bind] operation and returns a new instance with a new type.
  /// The 'bind' method allows chaining operations that may fail.
  Result<U, E> bind<U>(Result<U, E> Function(T) f) => match(
        onSuccess: (value) => f(value),
        onError: Error<U, E>.new,
      );

  /// The 'map' method transforms the successful value without changing
  /// the error.
  Result<U, E> map<U>(U Function(T) f) => match(
        onSuccess: (value) => Success<U, E>(f(value)),
        onError: Error<U, E>.new,
      );

  /// Performs a merge operation and returns a new instance of [M].
  Result<M, E> merge<M, J>(Result<J, E> other, M Function(T, J) onJoin) =>
      match(
        onSuccess: (firstValue) => other.match(
          onSuccess: (secondValue) =>
              Success<M, E>(onJoin(firstValue, secondValue)),
          onError: Error<M, E>.new,
        ),
        onError: (firstError) => other.match(
          onSuccess: (_) => Error<M, E>(firstError),
          onError: (_) => Error<M, E>(firstError),
        ),
      );

  /// Performs a [bind] operation and returns a new instance.
  Result<T, E> operator >>(
    Result<T, E> Function(T) transform,
  ) =>
      bind(transform);
}

/// Extends [Option] with additional functionality.
extension OptionExtensions<T> on Option<T> {
  /// Returns the value if it is some, or the result of [orElse] if it is none.
  T someOr(T Function() orElse) => switch (this) {
        Some(:final value) => value,
        _ => orElse(),
      };

  Option<U> bind<U>(Option<U> Function(T) f) => switch (this) {
        Some(:final value) => f(value),
        None() => const None(),
      };

  /// Performs a [bind] operation
  Option<T> operator >>(
    Option<T> Function(T) transform,
  ) =>
      bind(transform);

  /// Returns the value if it exists, otherwise returns [or]
  T operator |(
    T or,
  ) =>
      switch (this) {
        Some(:final value) => value,
        None() => or,
      };
}

Iterable<T> _sort<T>(Iterable<T> iterable, int Function(T, T) compare) =>
    iterable.toList()..sort(compare);

/// Extends [ListResult] with additional functionality.
extension ListResultExtensions<T, E> on IterableResult<T, E> {
  /// Returns true if this instance represents a success result and there are
  /// itemse in the list.
  bool get isNotEmpty =>
      switch (this) { Success(:final value) => value.isNotEmpty, _ => false };

  /// Returns true if the result is not successful or the list is empty.
  bool get isEmpty =>
      switch (this) { Success(:final value) => value.isEmpty, _ => false };

  /// Returns the result if it is a success, or the result of [orElse]
  Iterable<T> iterableOr(Iterable<T> orElse) =>
      switch (this) { Success(:final value) => value, _ => orElse };

  /// Returns the length of the list if it is a success, or [length]
  int lengthOr(int length) =>
      switch (this) { Success(:final value) => value.length, _ => length };

  /// Performs a sort operation and returns a new instance of [M].
  IterableResult<T, E> sorted<M extends IterableResult<T, E>>(
    int Function(T a, T b) compare, {
    required Iterable<T> Function(Iterable<T>) onSuccess,
  }) =>
      switch (this) {
        Success(:final value) => Success<Iterable<T>, E>(_sort(value, compare)),
        final Error<Iterable<T>, E> e => e,
      };

  /// Performs a filter operation and returns a new instance of [T].
  Iterable<T> where(
    bool Function(T) predicate, {
    required Iterable<T> Function(E) onError,
  }) =>
      match(
        onSuccess: (list) => list.where(predicate),
        onError: onError,
      );
}

/// Extends [ObservableState] with additional functionality.
extension ObservableStateObservers<S> on ObservableState<S> {
  /// Adds an observer  with a [WeakReference], which is notified when the
  /// state changes.
  void addObserver(void Function(Option<S>) observer) {
    _observers.add(WeakReference(observer));
  }

  /// Removes an observer so it no longer receives state changes.
  void removeObserver(void Function(Option<S>) observer) {
    _observers.removeWhere((ref) => ref.target == observer);
  }

  /// Updates the state based on a given transform function.
  void updateState(S Function(Option<S>) transform) {
    _state = Some(transform(_state));
    _notifyObservers();
  }

  void _notifyObservers() {
    _observers.removeWhere((ref) => ref.target == null);
    for (final weakRef in _observers) {
      final observer = weakRef.target;
      if (observer != null) {
        observer(_state);
      }
    }
  }
}
