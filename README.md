# nadz

Carefully crafted monads, such as `Result` and `Option` for exhaustive pattern matching in Dart.

## Introduction
This library has a modern collection of monads and operators for Dart. It is inspired by the elegance of languages like F# and Haskell. The library is simple, expressive, and easy to use. It leverages the recent addition of the [`sealed` class modifier](https://dart.dev/language/class-modifiers#sealed) in Dart to provide exhaustive [pattern matching](https://dart.dev/language/patterns). This makes traversing results far easier and less error prone, particularly with [Dart's Switch Expression](https://www.christianfindlay.com/blog/dart-switch-expressions).

Example: 
```dart
void main() {
  final Result<int,int> result = Success(42);
  final message = result.match(
    onSuccess: (value) => 'The answer is $value',
    onError: (error) => 'Error: $error',
  );
  print(message); // The answer is 42
}
```

Or, the equivalent with a switch expression:

```dart
void main() {
  final Result<int,int> result = Success(42);
  final message = switch (result) {
    //This is pattern matching
    Success(:final value) => 'The answer is $value',
    Error(:final error) => 'Error: $error',
  };
  print(message); // The answer is 42
}
```

## What is a Monad?

A monad is a pattern that helps you deal with sequences of computations while handling side effects cleanly. You can think of it as a type of wrapper around a value that also defines how to apply operations to this value. This approach lets you chain operations together in a controlled way. It manages aspects like input/output, state management, or error handling without the risk of exceptions breaking control flow. 

The class not only holds data but also strictly controls how that data is accessed, processed and transferred within your application. It ensures operations are executed in a predictable and safe manner.

Have you ever made a HTTP call, but didn't quite know how to deal with the result? The call may return one JSON structure, or an error structure, or you might just get an exception. This is where the `Result` monad comes in and helps you to handle all these cases in a clean and predictable way with pattern matching.

