//------------ Monadi ------------

/// The Either class represents a value of one of two possible types
/// (a disjoint union). Instances of Either are either an instance of left or
/// right. All other Monads in this library derive from this type.
///
/// Use [EitherBase] to derive new Monads from this
abstract class Either<L, R> {
  L? get _left;
  R? get _right;

  bool get isLeft => _left != null;
  bool get isRight => _right != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Either<L, R> &&
          ((isLeft && other.isLeft && _left == other._left) ||
              (isRight && other.isRight && _right == other._right)));

  @override
  int get hashCode => isLeft ? _left.hashCode : _right.hashCode;

  @override
  String toString() => '$runtimeType ${isLeft ? '($_left)' : '($_right)'}';
}

/// An abstract base class for Either that initializes left and right values.
/// Use this base class to derive new Monads
abstract class EitherBase<L, R> extends Either<L, R> {
  EitherBase.left(L left)
      : _left = left,
        _right = null;

  EitherBase.right(R right)
      : _left = null,
        _right = right;

  @override
  final L? _left;

  @override
  final R? _right;
}

/// None represents the absence of a value in [Option].
class None {
  const None();

  @override
  String toString() => 'None';
}

/// Option type is used to represent optional values that could either be
/// 'Some' or 'None'.
class Option<T> extends Either<None, T> {
  Option(this._value) : _none = null;
  Option.none()
      : _value = null,
        _none = const None();

  final T? _value;
  final None? _none;

  @override
  T? get _right => _value;

  @override
  None? get _left => _none;

  /// Returns true if the option is Some, false otherwise.
  bool get isSome => _value != null;

  /// Returns true if the option is None, false otherwise.
  bool get isNone => !isSome;
}

/// Encapsulates either a result (value of generic type T) or an error
/// (value of generic type E).
class Result<T, E> extends Either<E, T> {
  Result(this._result) : _error = null;
  Result.error(this._error) : _result = null;

  final T? _result;
  final E? _error;

  @override
  T? get _right => _result;

  @override
  E? get _left => _error;
}

/// Specialized version of [Result] for list results.
class ListResult<T, E> extends Result<List<T>, E> {
  ListResult(super._result);
  ListResult.error(E super.error) : super.error();
}

/// Specialized version of ListResultOrError to be used for HTTP responses,
/// with int as the error type to represent the HTTP status code.
class HttpListResultOrStatusCode<T> extends ListResult<T, int> {
  HttpListResultOrStatusCode(super.result);
  HttpListResultOrStatusCode.error(super.error) : super.error();
}

/// Encapsulates a state value that can be observed by external observers.
class ObservableState<S> {
  ObservableState(S initialState) : _state = Option<S>(initialState);
  ObservableState.none() : _state = Option<S>.none();

  /// The current state wrapped in an Option.
  Option<S> _state;
  Option<S> get state => _state;
  final List<WeakReference<void Function(Option<S>)>> _observers = [];
}
//------------ Estensioni ------------

extension EitherExtensions<L, R> on Either<L, R> {
  U match<U>({
    required U Function(L) onLeft,
    required U Function(R) onRight,
  }) =>
      isLeft ? onLeft(_left as L) : onRight(_right as R);

  R rightOr(R Function() orElse) => _right ?? orElse();
  L leftOr(L Function() orElse) => _left ?? orElse();

  R operator |(
    R value,
  ) =>
      isRight ? _right as R : value;

  M bind<M extends Either<L, R>>(M Function(R) transform) =>
      isRight ? transform(_right as R) : this as M;

  M map<U, M extends Either<L, U>>(
    U Function(R) transform, {
    M Function(U)? onRight,
  }) =>
      isRight
          ? onRight != null
              ? onRight(transform(_right as R))
              : Result<U, L>(transform(_right as R)) as M
          : this as M;

  M merge<J, M extends Either<L, (R, J)>>(
    Either<L, J> other,
    M Function(R first, J second) onJoin,
    M Function(Option<L> first, Option<L> second) onLeft,
  ) =>
      (isRight && other.isRight)
          ? onJoin(_right as R, other._right as J)
          : onLeft(
              Option<L>(isLeft ? _left as L : null),
              Option<L>(other.isLeft ? other._left as L : null),
            );
}

extension OptionExtensions<T> on Option<T> {
  T someOr(T Function() orElse) => _right ?? orElse();

  Option<T> operator >>(
    Option<T> Function(T) transform,
  ) =>
      bind(transform);
}

extension ResultOrErrorExtensions<T, E> on Result<T, E> {
  /// Returns true if this instance represents a success result.
  bool get isSuccess => _result != null;

  /// Returns true if this instance represents an error.
  bool get isError => !isSuccess;
  T resultOr(T Function() orElse) => _right ?? orElse();

  Result<(T, T), E> operator &(
    (
      Either<E, T> other,
      Result<(T, T), E> Function(T first, T second) onJoin,
      Result<(T, T), E> Function(
        Option<E> first,
        Option<E> second,
      ) onLeft,
    ) transformation,
  ) =>
      (isRight && transformation.$1.isRight)
          ? transformation.$2(_right as T, transformation.$1._right as T)
          : transformation.$3(
              Option<E>(isLeft ? _left as E : null),
              Option<E>(
                transformation.$1.isLeft ? transformation.$1._left as E : null,
              ),
            );

  Result<T, E> operator >>(
    Result<T, E> Function(T) transform,
  ) =>
      bind(transform);
}

extension ListResultOrErrorExtensions<T, E> on ListResult<T, E> {
  bool get isNotEmpty => !isEmpty;
  bool get isEmpty => !isSuccess || _result!.isEmpty;

  Iterable<T> iterableOr(Iterable<T> Function() orElse) => _result ?? orElse();

  int lengthOr(int Function() length) => isSuccess ? _result!.length : length();

  M sorted<M extends ListResult<T, E>>(
    int Function(T a, T b) compare, {
    required M Function(List<T>) onSuccess,
    required M Function(E) onError,
  }) =>
      isSuccess
          ? onSuccess(List<T>.from(_result!)..sort(compare))
          : onError(_error as E);

  Iterable<T> where(
    bool Function(T) predicate, {
    required Iterable<T> Function(E) onError,
  }) =>
      match(
        onRight: (list) => list.where(predicate),
        onLeft: onError,
      );
}

extension HttpListResultOrStatusCodeExtensions<T>
    on HttpListResultOrStatusCode<T> {
  HttpListResultOrStatusCode<T> sorted(int Function(T a, T b) compare) =>
      // ignore: unnecessary_cast
      (this as ListResult<T, int>).sorted(
        compare,
        onSuccess: HttpListResultOrStatusCode<T>.new,
        onError: HttpListResultOrStatusCode<T>.error,
      );

  HttpListResultOrStatusCode<U> transformList<U>(
    List<U> Function(List<T>) transform,
  ) =>
      isRight
          ? HttpListResultOrStatusCode<U>(transform(_result!))
          : HttpListResultOrStatusCode<U>.error(_error!);
}

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
    _state = Option(transform(_state));
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
