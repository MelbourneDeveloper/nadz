// ignore_for_file: avoid_print

import 'package:nadz/nadz.dart';

void main() {
  // Creating an Option instance with some value
  final someOption = Some<int>(5);
  print(someOption); // Should print something like Option (5)

  // Creating an Option instance with no value
  final noneOption = None<int>();
  print(noneOption); // Should print something like Option (None)

  // Creating a ResultOrError instance with a result
  final successResult = Success<String, String>('Success');
  print(successResult); // Should print something like ResultOrError (Success)

  // Creating a ResultOrError instance with an error
  final errorResult = Error<String, String>('Error');
  print(errorResult);

  // Should print something like ResultOrError (Error)

  // Using the match method to handle both success and error cases
  final matchedResult = successResult.match(
    onSuccess: (result) => 'Got result: $result',
    onError: (error) => 'Got error: $error',
  );
  print(matchedResult);

  // Should print "Got result: Success"

  // Using the map method to transform the result
  final mappedResult = successResult.map(
    (result) => result.toUpperCase(),
  );
  print(mappedResult);

  // Should print something like ResultOrError (SUCCESS)

  // Creating a HttpListResultOrStatusCode instance with a result
  final httpListResult = Success([1, 2, 3]);
  print(
    httpListResult,
  );

  // Should print something like HttpListResultOrStatusCode ([1, 2, 3])

  // Using the transformList method to transform the list
  final transformedHttpListResult = httpListResult.map(
    (list) => list.map((item) => 'Item: $item').toList(),
  );

  // Should print something like HttpListResultOrStatusCode
  //(["Item: 1", "Item: 2", "Item: 3"])
  print(
    transformedHttpListResult,
  );
}
