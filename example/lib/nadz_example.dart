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
    required T Function(Map<String, dynamic>) onMap,
    required Result<List<T>, int> Function(List<T>) onSuccess,
  }) async {
    try {
      final response = await this.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List<dynamic>;
        final resultList = jsonList
            .cast<Map<String, dynamic>>()
            .map((jsonMap) => onMap(jsonMap))
            .toList();
        return onSuccess(resultList);
      }
      return Error(response.statusCode);
    } catch (e) {
      return Error(500);
    }
  }
}

void main() async {
  final result = await Client().getResult(
    'https://jsonplaceholder.typicode.com/posts',
    onMap: (jsonPost) => jsonPost.toPost(),
    onSuccess: (posts) => Success(posts),
  );

  final display = switch (result) {
    Success(value: final posts) => 'Fetched ${posts.length} posts successfully!'
        '\n${posts.map((p) => 'Title: ${p.title}\nBody: ${p.body}\n---').join('\n')}',
    Error(error: final statusCode) =>
      'Failed to fetch posts. Status code: $statusCode',
  };

  print(display);
}
