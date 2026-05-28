import 'cafe.dart';

class CafeCatalogSyncReport {
  const CafeCatalogSyncReport({
    required this.cafes,
    required this.source,
    required this.usedFallback,
    this.message,
    this.syncedAt,
  });

  final List<Cafe> cafes;
  final CafeSource source;
  final bool usedFallback;
  final String? message;
  final DateTime? syncedAt;

  bool get hasRemoteCatalog => source == CafeSource.supabaseCatalog;
}
