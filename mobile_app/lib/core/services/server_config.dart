import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared runtime API endpoint resolver for Blue Hour HQ (Cloud Railway/HTTPS + Local Studio fallback).
class BhServerConfig {
  BhServerConfig._();
  static final BhServerConfig instance = BhServerConfig._();

  static const String _kPrefServerUrl = 'bh_live_server_url';
  static const List<String> _kLocalFallbackBases = <String>[
    'http://127.0.0.1:8090',
    'http://192.168.29.26:8090',
    'http://192.168.1.133:8090',
  ];

  String? _liveBaseUrl;

  String? get liveBaseUrl => _liveBaseUrl;

  static String normalizeBaseUrl(String raw) {
    var trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    trimmed = trimmed.replaceAll(RegExp(r'/index\.php/?$'), '');
    trimmed = trimmed.replaceAll(RegExp(r'/+$'), '');
    return trimmed;
  }

  Future<void> loadFromPrefs(SharedPreferences prefs) async {
    final saved = prefs.getString(_kPrefServerUrl);
    if (saved != null && saved.trim().isNotEmpty) {
      _liveBaseUrl = normalizeBaseUrl(saved);
    }
  }

  Future<void> setLiveBaseUrl(String url) async {
    final normalized = normalizeBaseUrl(url);
    _liveBaseUrl = normalized.isEmpty ? null : normalized;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_liveBaseUrl == null) {
        await prefs.remove(_kPrefServerUrl);
      } else {
        await prefs.setString(_kPrefServerUrl, _liveBaseUrl!);
      }
    } catch (_) {
      // Ignore in headless tests
    }
  }

  List<String> get baseUrls => <String>[
        if (_liveBaseUrl != null && _liveBaseUrl!.isNotEmpty) _liveBaseUrl!,
        ..._kLocalFallbackBases,
      ];

  List<String> actionUrls(String action) =>
      baseUrls.map((b) => '$b/index.php?action=$action').toList();

  Future<({bool ok, String message})> testHealth(String candidateUrl) async {
    final base = normalizeBaseUrl(candidateUrl);
    if (base.isEmpty) {
      return (ok: false, message: 'Enter a valid server URL first.');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 6);
    try {
      final req = await client.getUrl(Uri.parse('$base/index.php?action=health'));
      final resp = await req.close();
      final body = await resp.transform(utf8.decoder).join();
      if (resp.statusCode != 200) {
        return (ok: false, message: 'HTTP ${resp.statusCode} from $base');
      }
      final parsed = jsonDecode(body);
      if (parsed is Map && parsed['ok'] == true) {
        final fcmReady = parsed['fcm_configured'] == true;
        final engine = parsed['engine']?.toString() ?? 'MySQL';
        return (
          ok: true,
          message:
              'Connected to $engine • FCM ${fcmReady ? 'Ready' : 'Not configured'}',
        );
      }
      return (ok: false, message: 'Unexpected health response from $base');
    } catch (e) {
      return (ok: false, message: 'Could not reach $base ($e)');
    } finally {
      client.close(force: true);
    }
  }
}

