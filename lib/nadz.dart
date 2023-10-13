//------------ Monadi ------------

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

class None {
  const None();

  @override
  String toString() => 'None';
}

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

  bool get isSome => _value != null;
  bool get isNone => !isSome;
}

class ResultOrError<T, E> extends Either<E, T> {
  ResultOrError(this._result) : _error = null;
  ResultOrError.error(this._error) : _result = null;

  final T? _result;
  final E? _error;

  @override
  T? get _right => _result;

  @override
  E? get _left => _error;
}

class ListResultOrError<T, E> extends ResultOrError<List<T>, E> {
  ListResultOrError(super._result);
  ListResultOrError.error(E super.error) : super.error();
}

class HttpListResultOrStatusCode<T> extends ListResultOrError<T, int> {
  HttpListResultOrStatusCode(super.result);
  HttpListResultOrStatusCode.error(super.error) : super.error();
}

//------------ Estensioni ------------

extension EitherExtensions<L, R> on Either<L, R> {
  U match<U>({
    required U Function(L) onLeft,
    required U Function(R) onRight,
  }) =>
      isLeft ? onLeft(_left as L) : onRight(_right as R);

  R rightOr(R Function() or) => _right ?? or();
  L leftOr(L Function() or) => _left ?? or();

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
              : ResultOrError<U, L>(transform(_right as R)) as M
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
  T someOr(T Function() or) => _right ?? or();

  Option<T> operator >>(
    Option<T> Function(T) transform,
  ) =>
      bind(transform);
}

extension ResultOrErrorExtensions<T, E> on ResultOrError<T, E> {
  bool get isSuccess => _result != null;
  bool get isError => !isSuccess;
  T resultOr(T Function() or) => _right ?? or();

  ResultOrError<(T, T), E> operator &(
    (
      Either<E, T> other,
      ResultOrError<(T, T), E> Function(T first, T second) onJoin,
      ResultOrError<(T, T), E> Function(
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

  ResultOrError<T, E> operator >>(
    ResultOrError<T, E> Function(T) transform,
  ) =>
      bind(transform);
}

extension ListResultOrErrorExtensions<T, E> on ListResultOrError<T, E> {
  bool get isNotEmpty => !isEmpty;
  bool get isEmpty => !isSuccess || _result!.isEmpty;

  Iterable<T> iterableOr(Iterable<T> Function() or) => _result ?? or();

  int lengthOr(int Function() length) => isSuccess ? _result!.length : length();

  M sorted<M extends ListResultOrError<T, E>>(
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
      (this as ListResultOrError<T, int>).sorted(
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
