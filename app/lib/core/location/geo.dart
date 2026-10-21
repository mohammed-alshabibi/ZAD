/// User locations are stored rounded to 3 decimals, about 100 m (CLAUDE.md §13).
double roundCoord(double value) => (value * 1000).round() / 1000;
