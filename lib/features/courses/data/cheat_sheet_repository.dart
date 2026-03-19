import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../screens/cheat_sheet_screen.dart';

class CheatSheetRepository {
  static Future<List<CheatSheetEntry>> loadAll() async {
    try {
      final data = await rootBundle.loadString('assets/cheat_sheets.json');
      final list = json.decode(data) as List<dynamic>;
      return list.map((m) => CheatSheetEntry.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading cheat sheets: $e');
      return [];
    }
  }
}
