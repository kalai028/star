class RepositoryModel {
  final int id;
  final String name;
  final String description;
  final int starCount;
  final String ownerName;
  final String ownerAvatarLink;

  RepositoryModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.starCount,
      required this.ownerName,
      required this.ownerAvatarLink});

  factory RepositoryModel.fromJson(Map<String, dynamic> json) {
    return RepositoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      starCount: json['stargazers_count'] ?? 0,
      ownerName: json['owner']?['login'] ?? '',
      ownerAvatarLink: json['owner']?['avatar_url'] ?? '',
    );
  }
}
