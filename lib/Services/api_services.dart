import 'dart:convert';
import 'package:git_star/Models/repository_model.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  static Future<List<RepositoryModel>> fetchRepositories(http.Client client,
      {required String date, required int count, required int pageNo}) async {
    String url =
        'https://api.github.com/search/repositories?q=created:%3E$date&sort=stars&order=desc&per_page=$count&page=$pageNo';

    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      List repositories = result['items'] ?? [];

      return repositories.map((e) => RepositoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to Load data');
    }
  }
}
