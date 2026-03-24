import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../screens/cheat_sheet_screen.dart';

class CheatSheetRepository {
  static Future<List<CheatSheetEntry>> loadAll() async {
    final entries = <CheatSheetEntry>[];
    for (final asset in ['assets/cheat_sheets.json', 'assets/netkit_cheat_sheets.json']) {
      try {
        final data = await rootBundle.loadString(asset);
        final list = json.decode(data) as List<dynamic>;
        entries.addAll(list.map((m) => CheatSheetEntry.fromMap(m as Map<String, dynamic>)));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error loading cheat sheets from $asset: $e');
        }
      }
    }
    return entries;
  }
}
