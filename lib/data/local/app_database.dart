import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'krishikhamar.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE crop_scans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            crop TEXT NOT NULL,
            diagnosis TEXT NOT NULL,
            risk TEXT NOT NULL,
            emoji TEXT NOT NULL,
            image_path TEXT,
            scientific_name TEXT,
            severity TEXT,
            match_percent INTEGER,
            spread TEXT,
            description TEXT,
            treatments_json TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
