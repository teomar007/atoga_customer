import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../domain/wallet_transaction.dart';

/// رصيد المحفظة الحالي (`profiles.wallet_balance`) — قراءة فقط عبر RLS،
/// والتعديل عبر دوال آمنة في الخادم حصراً.
final walletBalanceProvider = FutureProvider.autoDispose<double>((Ref ref) async {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  final String? userId = client.auth.currentUser?.id;
  if (userId == null || userId.isEmpty) {
    throw const WalletException('not_authenticated');
  }
  final PostgrestList rows = await client.from('profiles').select('wallet_balance').eq('id', userId).limit(1);
  if (rows.isEmpty) {
    return 0;
  }
  return double.tryParse('${rows.first['wallet_balance'] ?? ''}') ?? 0;
});

/// سجل حركات المحفظة الأحدث أولاً (RLS: صفوف المستخدم فقط).
final walletTransactionsProvider = FutureProvider.autoDispose<List<WalletTransaction>>((Ref ref) async {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  final String? userId = client.auth.currentUser?.id;
  if (userId == null || userId.isEmpty) {
    throw const WalletException('not_authenticated');
  }
  final PostgrestList rows = await client
      .from('wallet_transactions')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(100);
  return rows.map((dynamic row) => WalletTransaction.fromJson(Map<String, dynamic>.from(row as Map))).toList();
});

class WalletException implements Exception {
  const WalletException(this.code);

  final String code;

  @override
  String toString() => 'WalletException($code)';
}
