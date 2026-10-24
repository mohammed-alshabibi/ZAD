import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Now", refreshed every 30 seconds so countdowns ("28 min left") and
/// pickup-window bars move on their own. Tests override it with a fixed time.
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});

extension ClockRef on Ref {
  DateTime get now => watch(clockProvider).value ?? DateTime.now();
}

extension ClockWidgetRef on WidgetRef {
  DateTime get now => watch(clockProvider).value ?? DateTime.now();
}
