import 'package:flutter_test/flutter_test.dart';
import 'package:git_star/Models/repository_model.dart';
import 'package:git_star/Provider/repository_provider.dart';
import 'package:git_star/Services/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('initialize', () {
    RepositoryNotifier repositoryNotifier = RepositoryNotifier();

    test('fetch data from server if user has network connection', () async {
      final client = MyMockClient();
      String date = '2023-09-28';
      int count = 10;
      int pageNo = 1;
      when(client.get(Uri.parse(
              'https://api.github.com/search/repositories?q=created:%3E$date&sort=stars&order=desc&per_page=$count&page=$pageNo')))
          .thenAnswer(
              (_) async => http.Response('{"id": 1, "name": "testing"}', 200));

      final repositoryCall = await ApiServices.fetchRepositories(client,
          date: date, count: count, pageNo: pageNo);

      expect(repositoryCall, isA<List<RepositoryModel>>());
    });

    test('fetch data from local database if user has no network connection',
        () async {
      await repositoryNotifier.fetchDataFromDevice();

      expect(repositoryNotifier.state, isA<List<RepositoryModel>>());
    });
  });
}
