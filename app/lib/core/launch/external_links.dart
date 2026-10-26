import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/generated/app_localizations.dart';

/// Google Maps walking directions to a pickup point (CLAUDE.md §2:
/// directions open Google Maps).
Future<void> openDirections(BuildContext context, {required double lat, required double lng}) =>
    _open(context, Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$lat,$lng',
      'travelmode': 'walking',
    }));

/// Opens the phone's dialer with [phone] ("+968 9123 4567").
Future<void> callPhone(BuildContext context, String phone) =>
    _open(context, Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

/// Opens [uri] in another app, or says so when the phone can't.
Future<void> _open(BuildContext context, Uri uri) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok) messenger?.showSnackBar(SnackBar(content: Text(l10n.errorCantOpen)));
}

/// Opens a map pin in Google Maps (admin: check a restaurant's pickup point).
Future<void> openMapAt(BuildContext context, {required double lat, required double lng}) =>
    _open(context, Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '$lat,$lng'}));
