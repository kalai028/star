import 'package:git_star/Models/repository_model.dart';

class ApiModel {
  const ApiModel({required this.success, required this.data});

  final bool success;
  final List<RepositoryModel> data;
}
