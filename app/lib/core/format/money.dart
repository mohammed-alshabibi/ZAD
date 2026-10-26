/// Money is stored as integer baisa (1 OMR = 1000 baisa) and shown with three
/// decimals: 800 → "0.800 OMR", 1500 → "1.500 OMR" (CLAUDE.md §1.1, §13).
String formatOmr(int baisa) => '${formatOmrAmount(baisa)} OMR';

/// The number alone, for a crossed-out "was" price: 2400 → "2.400".
String formatOmrAmount(int baisa) {
  final omr = baisa ~/ 1000;
  final rest = (baisa % 1000).toString().padLeft(3, '0');
  return '$omr.$rest';
}

/// What the owner types as a price, in OMR, to baisa: "0.8" → 800,
/// "1.250" → 1250, "2" → 2000. Null for anything else (more than 3 decimals,
/// letters, negative).
int? parseOmr(String input) {
  final text = input.trim().replaceAll(',', '.');
  final match = RegExp(r'^(\d{1,4})(?:\.(\d{0,3}))?$').firstMatch(text);
  if (match == null) return null;
  final omr = int.parse(match.group(1)!);
  final baisa = (match.group(2) ?? '').padRight(3, '0');
  return omr * 1000 + int.parse(baisa);
}
