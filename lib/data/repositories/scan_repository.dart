import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../local/app_database.dart';
import '../models/models.dart';

class ScanRepository {
  ScanRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<CropScan>> getRecentScans({int limit = 20}) async {
    final db = await _database.database;
    final rows = await db.query(
      'crop_scans',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  Future<CropScan?> getLatestAlert() async {
    final db = await _database.database;
    final rows = await db.query(
      'crop_scans',
      where: "risk IN (?, ?)",
      whereArgs: ['high', 'medium'],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<CropScan> saveScan({
    required CropScan scan,
    required List<int> imageBytes,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final scansDir = Directory(p.join(dir.path, 'scans'));
    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }

    final createdAt = scan.createdAt ?? DateTime.now();
    final fileName =
        'scan_${createdAt.millisecondsSinceEpoch}.jpg';
    final imagePath = p.join(scansDir.path, fileName);
    await File(imagePath).writeAsBytes(imageBytes, flush: true);

    final db = await _database.database;
    final id = await db.insert('crop_scans', {
      'crop': scan.crop,
      'diagnosis': scan.diagnosis,
      'risk': scan.risk.name,
      'emoji': scan.emoji,
      'image_path': imagePath,
      'scientific_name': scan.scientificName,
      'severity': scan.severity,
      'match_percent': scan.matchPercent,
      'spread': scan.spread,
      'description': scan.description,
      'treatments_json': jsonEncode(
        scan.treatments
            .map(
              (t) => {
                'number': t.number,
                'description': t.description,
                'color': t.color.toARGB32(),
              },
            )
            .toList(),
      ),
      'created_at': createdAt.toIso8601String(),
    });

    return CropScan(
      id: id,
      crop: scan.crop,
      diagnosis: scan.diagnosis,
      timeAgo: _timeAgo(createdAt),
      risk: scan.risk,
      emoji: scan.emoji,
      imagePath: imagePath,
      scientificName: scan.scientificName,
      severity: scan.severity,
      matchPercent: scan.matchPercent,
      spread: scan.spread,
      description: scan.description,
      treatments: scan.treatments,
      createdAt: createdAt,
    );
  }

  CropScan _fromRow(Map<String, Object?> row) {
    final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '') ??
        DateTime.now();
    final treatmentsJson = row['treatments_json'] as String? ?? '[]';
    final treatmentsRaw = jsonDecode(treatmentsJson) as List<dynamic>;
    final treatments = treatmentsRaw.map((e) {
      final m = e as Map<String, dynamic>;
      return TreatmentStep(
        number: m['number'] as int? ?? 0,
        description: m['description'] as String? ?? '',
        color: Color(m['color'] as int? ?? 0xFF2E7D32),
      );
    }).toList();

    final riskName = row['risk'] as String? ?? 'medium';
    final risk = ScanRisk.values.firstWhere(
      (r) => r.name == riskName,
      orElse: () => ScanRisk.medium,
    );

    return CropScan(
      id: row['id'] as int?,
      crop: row['crop'] as String? ?? 'Crop',
      diagnosis: row['diagnosis'] as String? ?? 'Unknown',
      timeAgo: _timeAgo(createdAt),
      risk: risk,
      emoji: row['emoji'] as String? ?? '🌿',
      imagePath: row['image_path'] as String?,
      scientificName: row['scientific_name'] as String? ?? '',
      severity: row['severity'] as String? ?? '',
      matchPercent: row['match_percent'] as int? ?? 0,
      spread: row['spread'] as String? ?? '',
      description: row['description'] as String? ?? '',
      treatments: treatments,
      createdAt: createdAt,
    );
  }

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
