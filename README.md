# nadz

Carefully crafted monads, such as `Result` and `Option` for exhaustive pattern matching in Dart.

## Introduction
This library has a modern collection of monads and operators for Dart. It is inspired by the elegance of languages like F# and Haskell. The library is simple, expressive, and easy to use. It leverages the recent addition of the [`sealed` class modifier](https://dart.dev/language/class-modifiers#sealed) in Dart to provide exhaustive [pattern matching](https://dart.dev/language/patterns). This makes traversing results far easier and less error prone, particularly with [Dart's Switch Expression](https://www.christianfindlay.com/blog/dart-switch-expressions).

The types here are algebraic data types for exhaustive pattern matching.

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

## Result Monads

Result monads will help to make your code more robust and maintainable. You can wrap volatile calls in `try/catches` and return a meaningful value that has enough information to display the results to the user. The most straightforward example is HTTP calls. You can squash all the complexity into a very simple call.

### Complete Example

You can run this sample in the example folder.

```dart
import 'dart:convert';
import 'package:http/http.dart';
import 'package:nadz/nadz.dart';

typedef Post = ({
  int userId,
  int id,
  String title,
  String body,
});

extension PostExtensions on Map<String, dynamic> {
  Post toPost() {
    return (
      userId: this['userId'],
      id: this['id'],
      title: this['title'],
      body: this['body'],
    );
  }
}

extension ClientExtensions on Client {
  Future<Result<List<T>, int>> getResult<T>(
    String url, {
    required List<T> Function(Iterable<Map<String, dynamic>>) onSuccess,
  }) async {
    try {
      final response = await this.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List<dynamic>;

        return Success(onSuccess(jsonList.cast<Map<String, dynamic>>()));
      }
      return Error(response.statusCode);
    } catch (e) {
      return Error(500);
    }
  }
}

void main() async {
  //Make the call
  final result = await Client().getResult(
    'https://jsonplaceholder.typicode.com/posts',
    onSuccess: (jsonPosts) =>
        //Map the JSON results to a list of Posts
        jsonPosts.map((p) => p.toPost()).toList(),
  );

  final display = switch (result) {
    //This is the exhaustive pattern matching. We can only get results of these types
    Success(value: final posts) => 'Fetched ${posts.length} posts successfully!'
        '\n${posts.map((p) => 'Title: ${p.title}\nBody: ${p.body}\n---').join('\n')}',
    Error(error: final statusCode) =>
      'Failed to fetch posts. Status code: $statusCode',
  };

  print(display);
}
```

The above code makes the call with the HTTP client. If there is an exception, the function will return an error result. Otherwise, it will attempt to convert the JSON to a list of posts. If successful, it will return a success result with those posts. Otherwise, the result will be an error.

Then, the switch expression will match the result and display the posts if successful, or an error message if not.

## Option Monad

The `Option` monad is a type that represents an optional value. It can be either `Some` or `None`. This is useful when you have a value that may or may not be present. It is an alternative to using `null` values.

Here is an example:

```dart
void main() {
  final Option<int> some = Some(42);
  final Option<int> none = None();

  final message = switch(some) {
    Some(:final value) => 'The answer is $value',
    None() => 'No answer',
  };
}
```