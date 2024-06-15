// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart';
import 'package:nadz/nadz.dart';

extension ClientExtensions on Client {
  Future<TResult> getResult<TResult extends Result>(
    String url, {
    required TResult Function(dynamic) onSuccess,
    required TResult Function(int) onError,
  }) async {
    try {
      final response = await this.get(Uri.parse(url));
      if (response.statusCode == 200) {
        //This could throw an exception. To complete this, we also
        //need to wrap this in a try catch so we can return a
        //useful error
        return onSuccess(jsonDecode(response.body));
      }
      return onError(response.statusCode);
    } catch (e) {
      return onError(500);
    }
  }
}

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

void main() async {
  final client = Client();

  final result = await client.getResult<Result<List<Post>, int>>(
    'https://jsonplaceholder.typicode.com/posts',
    onSuccess: (dynamic json) {
      try {
        final List<dynamic> jsonList = json as List<dynamic>;
        final posts =
            jsonList.map((jsonPost) => Post.fromJson(jsonPost)).toList();
        return Success(posts);
      } catch (e) {
        return Error(500);
      }
    },
    onError: (statusCode) => Error(statusCode),
  );

  final display = switch (result) {
    Success(value: final posts) =>
      '''Fetched ${posts.length} posts successfully!
      ${posts.map((p) => 'Title: ${p.title}\nBody: ${p.body}\n---').join('\n')}
      ''',
    Error(error: final statusCode) =>
      'Failed to fetch posts. Status code: $statusCode',
  };

  print(display);

  client.close();
}
