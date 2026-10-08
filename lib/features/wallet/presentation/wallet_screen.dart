import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../../checkout/presentation/login_required_view.dart';
import '../domain/wallet_transaction.dart';
import 'wallet_provider.dart';

/// المحفظة الإلكترونية: بطاقة الرصيد + سجل الحركات (شحن/دفع).
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String lang = Localizations.localeOf(context).languageCode;

    if (!ref.watch(isSignedInProvider)) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.walletTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
        body: LoginRequiredView(onLogin: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) => const LoginScreen()))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletBalanceProvider);
          ref.invalidate(walletTransactionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _BalanceCard(lang: lang, l10n: l10n),
            const SizedBox(height: 22),
            Text(l10n.walletHistoryTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _TransactionsSection(lang: lang, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({required this.lang, required this.l10n});

  final String lang;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<double> balance = ref.watch(walletBalanceProvider);
    // معرّف المستخدم يظهر في البطاقة ليستخدمه الأدمن في شحن الرصيد.
    final String? userId = ref.watch(currentUserProvider)?.id;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: <Color>[AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[BoxShadow(color: AppColors.primary.withValues(alpha: 0.30), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 26),
              const SizedBox(width: 10),
              Text(l10n.walletBalance, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          balance.when(
            loading: () => const SizedBox(width: 150, height: 34, child: Center(child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))),
            error: (Object error, StackTrace stack) => Text('--', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            data: (double value) => Text(Formatters.price(value, lang), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.1)),
          ),
          const SizedBox(height: 10),
          Text(l10n.walletTopUpHint, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5, height: 1.5)),
          if (userId != null && userId.isNotEmpty) ...[
            const SizedBox(height: 14),
            // شريط المعرّف: نقرة كاملة تنسخه للحافظة ليشحنه الأدمن.
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _copyUserId(context, l10n, userId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 15, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.walletUserId, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10.5)),
                          const SizedBox(height: 2),
                          Text(userId, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 0.3)),
                        ],
                      ),
                    ),
                    const Icon(Icons.copy_rounded, size: 15, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _copyUserId(BuildContext context, AppLocalizations l10n, String userId) async {
    await Clipboard.setData(ClipboardData(text: userId));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.walletUserIdCopied)));
  }
}

class _TransactionsSection extends ConsumerWidget {
  const _TransactionsSection({required this.lang, required this.l10n});

  final String lang;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<WalletTransaction>> async = ref.watch(walletTransactionsProvider);
    return async.when(
      loading: () => Column(
        children: List<Widget>.generate(3, (int _) => const Padding(padding: EdgeInsets.only(bottom: 10), child: _TxSkeleton())),
      ),
      error: (Object error, StackTrace stack) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.dataLoadFailed)),
            TextButton(onPressed: () => ref.invalidate(walletTransactionsProvider), child: Text(l10n.retry)),
          ],
        ),
      ),
      data: (List<WalletTransaction> items) {
        if (items.isEmpty) {
          return EmptyStateView(icon: Icons.receipt_long_outlined, title: l10n.walletNoTransactions, compact: true);
        }
        return Column(
          children: <Widget>[
            for (final WalletTransaction tx in items) _TransactionTile(transaction: tx, lang: lang, l10n: l10n),
          ],
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.lang, required this.l10n});

  final WalletTransaction transaction;
  final String lang;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool deposit = transaction.isDeposit;
    final Color signColor = deposit ? AppColors.success : AppColors.danger;
    final String amount = '${deposit ? '+' : '-'}${Formatters.price(transaction.amount.abs(), lang)}';
    final String title = deposit
        ? l10n.walletDepositTitle
        : l10n.walletPaymentTitle(transaction.orderId ?? '');
    final String date = Formatters.dateTime(transaction.createdAt, lang);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: signColor.withValues(alpha: 0.12), child: Icon(deposit ? Icons.add_rounded : Icons.remove_rounded, color: signColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(date, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(amount, style: theme.textTheme.titleSmall?.copyWith(color: signColor, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _TxSkeleton extends StatelessWidget {
  const _TxSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14)),
    );
  }
}
