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
    //This is the exhaustive pattern matching. We can only get results of these
    Success(value: final posts) => 'Fetched ${posts.length} posts successfully!'
        '\n${posts.map((p) => 'Title: ${p.title}\nBody: ${p.body}\n---').join('\n')}',
    Error(error: final statusCode) =>
      'Failed to fetch posts. Status code: $statusCode',
  };

  print(display);
}
