import 'package:flutter/material.dart';
import 'package:nadz/nadz.dart';

class OptionalAsyncSnapshotNad<T> extends Option<AsyncSnapshotNad<T>> {
  OptionalAsyncSnapshotNad(AsyncSnapshotNad<T> a) : super(a);
  OptionalAsyncSnapshotNad.none() : super.none();

  factory OptionalAsyncSnapshotNad.fromAsyncSnapshot(
      AsyncSnapshot<T> snapshot) {
    return switch (snapshot) {
      (AsyncSnapshot<T> snapshot) when snapshot.hasData =>
        OptionalAsyncSnapshotNad<T>(AsyncSnapshotNad<T>(snapshot.data as T)),
      (AsyncSnapshot<T> snapshot) when snapshot.hasError =>
        OptionalAsyncSnapshotNad<T>(AsyncSnapshotNad<T>.error(snapshot.error!)),
      _ => OptionalAsyncSnapshotNad<T>.none(),
    };
  }
}

class AsyncSnapshotNad<T> extends ResultOrError<T, Object> {
  AsyncSnapshotNad(T value) : super(value);
  AsyncSnapshotNad.error(Object error) : super.error(error);
}

extension Asdasd<T> on AsyncSnapshot<T> {
  OptionalAsyncSnapshotNad<T> toOptionalAsyncSnapshotNad() =>
      OptionalAsyncSnapshotNad<T>.fromAsyncSnapshot(this);
}
