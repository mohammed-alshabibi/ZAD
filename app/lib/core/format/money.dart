/// Money is stored as integer baisa (1 OMR = 1000 baisa) and shown with three
/// decimals: 800 → "0.800 OMR", 1500 → "1.500 OMR" (CLAUDE.md §1.1, §13).
String formatOmr(int baisa) {
  final omr = baisa ~/ 1000;
  final rest = (baisa % 1000).toString().padLeft(3, '0');
  return '$omr.$rest OMR';
}
