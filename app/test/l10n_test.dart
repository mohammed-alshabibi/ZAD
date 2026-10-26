import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zad/core/l10n/generated/app_localizations.dart';
import 'package:zad/features/restaurant/home/restaurant_home_screen.dart';

void main() {
  test('app_en.arb has no duplicate keys (a later one would silently win)', () {
    final source = File('lib/core/l10n/app_en.arb').readAsStringSync();
    final keys = [for (final m in RegExp(r'^  "([^"]+)":', multiLine: true).allMatches(source)) m.group(1)!];
    final dupes = {for (final k in keys) if (keys.where((x) => x == k).length > 1) k};
    expect(dupes, isEmpty);
  });

  test('restaurant time left reads "28 min" / "1 h 12 min", without "left"', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final now = DateTime.utc(2026, 10, 26, 17);
    expect(timeLeftLabel(l10n, now.add(const Duration(minutes: 28)), now), '28 min');
    expect(timeLeftLabel(l10n, now.add(const Duration(minutes: 72)), now), '1 h 12 min');
  });
}
