import 'package:git_star/Models/repository_model.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseServices {
  static Future<sql.Database> getDatabase() async {
    final appDir = await syspath.getApplicationDocumentsDirectory();
    final dbPath = path.join(appDir.path, 'repository.db');
    final appDb = await sql.openDatabase(
      dbPath,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE repositories (id INTEGER PRIMARY KEY, repository_id INTEGER, name TEXT, description TEXT, star_count INTEGER, owner_name TEXT, owner_avatar_link TEXT)');
      },
      version: 1,
    );
    return appDb;
  }

  static Future<List<RepositoryModel>> getRepositoriesList() async {
    final appDb = await getDatabase();
    final table = await appDb.query('repositories');
    final repositoriesList = table
        .map(
          (r) => RepositoryModel(
            id: r['repository_id'] as int,
            name: r['name'] as String,
            description: r['description'] as String,
            starCount: r['star_count'] as int,
            ownerName: r['owner_name'] as String,
            ownerAvatarLink: r['owner_avatar_link'] as String,
          ),
        )
        .toList();
    return repositoriesList;
  }

  static Future<void> storeRepositories(
      List<RepositoryModel> repositories) async {
    final appDb = await getDatabase();

    sql.Batch batch = appDb.batch();

    for (var item in repositories) {
      batch.insert('repositories', {
        'repository_id': item.id,
        'name': item.name,
        'description': item.description,
        'star_count': item.starCount,
        'owner_name': item.ownerName,
        'owner_avatar_link': item.ownerAvatarLink
      });
    }

    await batch.commit(noResult: true);
  }

  static Future<void> deleteDb() async {
    final appDir = await syspath.getApplicationDocumentsDirectory();
    final dbPath = path.join(appDir.path, 'repository.db');
    await sql.deleteDatabase(dbPath);
  }
}
