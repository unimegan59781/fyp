////// intialise ////////////////////////////////////////////////////////////////////////////////
import 'package:fyp/Album.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class dbHelper {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'music.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE albums(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, artist TEXT NOT NULL, price REAL)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertAlbums(List<Album> albums) async {
    int insertedCount = 0;
    final Database db = await initializeDB();

    for (var album in albums) {
      bool albumExists = await checkAlbumExists(db, album.id);
      if (!albumExists) {
        await db.insert(
          'albums',
          album
              .toMap(), // Assuming a toMap() method in Album to convert to a map
          conflictAlgorithm: ConflictAlgorithm
              .ignore, // Ignore conflicts if the id already exists
        );
        insertedCount++;
      }
    }

    return insertedCount;
  }

  Future<bool> checkAlbumExists(Database db, int albumId) async {
    List<Map<String, dynamic>> result = await db.query(
      'albums',
      where: 'id = ?',
      whereArgs: [albumId],
      columns: ['id'],
    );

    return result
        .isNotEmpty; // Returns true if the album with the given id exists
  }

  Future<List<Album>> retrieveAlbums() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('albums');
    return queryResult.map((e) => Album.fromMap(e)).toList();
  }

  Future<void> deleteAlbum(int id) async {
    final db = await initializeDB();
    await db.delete(
      'albums',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
