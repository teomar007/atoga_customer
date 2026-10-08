import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/main_shell.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/button_label.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/domain/customer_user.dart';
import '../../cart/presentation/cart_controller.dart';
import '../domain/address.dart';
import '../domain/delivery_zone.dart';
import 'address_form_screen.dart';
import 'checkout_controller.dart';
import 'delivery_zones_provider.dart';
import 'login_required_view.dart';
import 'order_placed_screen.dart';
import 'widgets/phone_required_sheet.dart';
import '../../wallet/presentation/wallet_provider.dart';

/// إتمام الطلب: عنوان + دفع عند الاستلام + تأكيد.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAddresses());
  }

  Future<void> _loadAddresses() async {
    final AddressesController controller = ref.read(addressesControllerProvider.notifier);
    await controller.load();
    if (!mounted) {
      return;
    }
    final List<Address> items = ref.read(addressesControllerProvider).items;
    // الاختيار يعيش في المزوّد لا في حالة الويدجت — مصدراً واحداً للحقيقة
    // يقرأ منه الملخص والزر والإرسال معاً.
    ref.read(checkoutControllerProvider.notifier).selectAddress(items.isEmpty ? null : items.first);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CheckoutState checkout = ref.watch(checkoutControllerProvider);

    // وضع الزائر: تسجيل الدخول مطلوب عند "متابعة الشراء" فقط.
    if (!ref.watch(isSignedInProvider)) {
      return Scaffold(appBar: AppBar(title: Text(l10n.checkoutTitle, maxLines: 1, overflow: TextOverflow.ellipsis)), body: LoginRequiredView(onLogin: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (BuildContext context) => const MainShell()))));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _AddressSection(selected: checkout.address, onSelect: (Address a) => ref.read(checkoutControllerProvider.notifier).selectAddress(a), onAdd: _addAddress),
          const SizedBox(height: 18),
          _PaymentSection(),
          const SizedBox(height: 18),
          _SummarySection(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final CheckoutState state = ref.watch(checkoutControllerProvider);
          final CartState cart = ref.watch(cartControllerProvider);
          final bool disabled = state.address == null || state.submitting || cart.isEmpty;
          final double total = cart.subtotal - cart.discount + state.deliveryFee;
          return SizedBox(width: double.infinity, child: FilledButton(onPressed: disabled ? null : () => _confirm(cart), child: ButtonLabel(state.submitting ? l10n.sendingOrder : '${l10n.confirmOrder} • ${Formatters.price(total, Localizations.localeOf(context).languageCode)}')));
        }),
      ),
    );
  }

  Future<void> _addAddress() async {
    final Address? created = await Navigator.of(context).push<Address>(MaterialPageRoute<Address>(builder: (BuildContext context) => const AddressFormScreen()));
    if (created != null && mounted) {
      ref.read(checkoutControllerProvider.notifier).selectAddress(created);
    }
  }

  Future<void> _confirm(CartState cart) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Address? address = ref.read(checkoutControllerProvider).address;
    if (address == null) {
      return;
    }
    // **بوابة إلزامية**: لا طلب بلا رقم هاتف للتوصيل.
    if (!await _ensureDeliveryPhone(address.phone)) {
      return;
    }
    final String? id = await _submitOrder(cart);
    if (!mounted) {
      return;
    }
    if (id == null) {
      // نعرض السبب الحقيقي القادم من قاعدة البيانات أثناء التطوير بدل
      // رسالة عامة تحجب علّة الفشل (RLS / حقل ناقص / …).
      final String? detail = ref.read(checkoutControllerProvider).errorDetail;
      // التفاصيل الخام في وضع التطوير فقط؛ في الإنتاج رسالة مفهومة واحدة
      // بدل تسريب أسماء أعمدة أو سياسات قاعدة البيانات للمستخدم.
      final bool showDetail = kDebugMode && detail != null && detail.isNotEmpty;
      final String message = !showDetail
          ? '${l10n.orderFailed} - ${l10n.orderFailedBody}'
          : '${l10n.orderFailed}: $detail';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (BuildContext context) => OrderPlacedScreen(orderId: id)));
  }

  /// يتحقق من الملف الشخصي قبل الطلب.
  /// - الهاتف موجود ← `true` ويُكمل الطلب.
  /// - الهاتف فارغ ← يعرض الـ BottomSheet؛ عند الحفظ الناجح يعود `true`
  ///   فيُرسَل الطلب تلقائياً دون ضغطة ثانية.
  Future<bool> _ensureDeliveryPhone(String? addressPhone) async {
    final CustomerUser? user = ref.read(currentUserProvider);
    if (user != null && user.hasPhone) {
      return true;
    }
    final PhoneRequest? result = await PhoneRequiredSheet.show(context, initialPhone: (user?.phone ?? '').isEmpty ? addressPhone : user?.phone);
    return result is PhoneRequestSaved;
  }

  Future<String?> _submitOrder(CartState cart) async {
    final CheckoutState checkout = ref.read(checkoutControllerProvider);
    final Address? address = checkout.address;
    if (address == null) {
      return null;
    }
    final CustomerUser? user = ref.read(currentUserProvider);
    // نرسل رقم الهاتف من الملف الشخصي (مصدر الحقيقة) لا من العنوان.
    final Address resolved = address.copyWith(phone: user?.phone ?? address.phone);
    // نفس الرقم المعروض في الملخص والزر: الإجمالي = صافي + رسوم المنطقة.
    final double fee = checkout.deliveryFee;
    return ref.read(checkoutControllerProvider.notifier).submit(
      address: resolved,
      items: cart.items,
      totals: OrderTotals(
        subtotal: cart.subtotal,
        discount: cart.discount,
        delivery: fee,
        total: cart.subtotal - cart.discount + fee,
      ),
      couponCode: cart.coupon?.code,
      paymentMethod: checkout.paymentMethod,
    );
  }
}

class _AddressSection extends ConsumerWidget {
  const _AddressSection({required this.selected, required this.onSelect, required this.onAdd});

  final Address? selected;
  final ValueChanged<Address> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AddressesState state = ref.watch(addressesControllerProvider);
    final List<DeliveryZone> zones = ref.watch(deliveryZonesProvider).valueOrNull ?? const <DeliveryZone>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.deliveryAddress, style: Theme.of(context).textTheme.titleMedium)),
            TextButton.icon(icon: const Icon(Icons.add_location_alt_outlined, size: 18), label: Text(l10n.addNewAddress, style: const TextStyle(fontSize: 13)), onPressed: onAdd),
          ],
        ),
        const SizedBox(height: 8),
        if (state.loading)
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator()))
        else if (state.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
            child: Row(
              children: [const Icon(Icons.location_off_outlined, color: AppColors.textSecondary), const SizedBox(width: 10), Expanded(child: Text(l10n.noSavedAddresses)), TextButton(onPressed: onAdd, child: Text(l10n.add))],
            ),
          )
        else
          RadioGroup<String>(
            groupValue: selected?.id ?? selected?.street ?? '',
            onChanged: (String? value) {
              for (final Address a in state.items) {
                if ((a.id ?? a.street) == value) {
                  onSelect(a);
                  return;
                }
              }
            },
            child: Column(
              children: state.items.map((Address a) {
                final String title = a.titleFor(zones);
                return RadioListTile<String>(
                  value: a.id ?? a.street,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(title.isEmpty ? l10n.notSet : title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(a.phone, style: Theme.of(context).textTheme.bodySmall),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _PaymentSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PaymentMethod selected = ref.watch(checkoutControllerProvider.select((CheckoutState s) => s.paymentMethod));
    final String lang = Localizations.localeOf(context).languageCode;
    final String balanceText = ref.watch(walletBalanceProvider).when<String>(
      loading: () => '…',
      error: (Object error, StackTrace stack) => '—',
      data: (double value) => Formatters.price(value, lang),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.paymentMethod, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        RadioGroup<PaymentMethod>(
          groupValue: selected,
          onChanged: (PaymentMethod? value) {
            if (value == null || value == selected) {
              return;
            }
            _select(context, ref, l10n, value);
          },
          child: Column(
            children: [
              _PaymentOption(
                value: PaymentMethod.cod,
                icon: Icons.payments_rounded,
                title: l10n.cashOnDelivery,
                subtitle: l10n.cashOnDeliveryDesc,
              ),
              const SizedBox(height: 8),
              _PaymentOption(
                value: PaymentMethod.wallet,
                icon: Icons.account_balance_wallet_rounded,
                title: l10n.payWithWallet,
                subtitle: '${l10n.walletBalance}: $balanceText',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// اختيار المحفظة مع تحقق فوري: إن كان الرصيد أقل من الإجمالي تُرجع
  /// الواجهة تلقائياً إلى الدفع عند الاستلام وتعرض رسالة توضيحية.
  Future<void> _select(BuildContext context, WidgetRef ref, AppLocalizations l10n, PaymentMethod value) async {
    final bool ok = await ref.read(checkoutControllerProvider.notifier).selectPaymentMethod(value);
    if (ok || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.walletInsufficient)));
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({required this.value, required this.icon, required this.title, required this.subtitle});

  final PaymentMethod value;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      child: RadioListTile<PaymentMethod>(
        value: value,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        dense: true,
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}

class _SummarySection extends ConsumerWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String lang = Localizations.localeOf(context).languageCode;
    final CartState cart = ref.watch(cartControllerProvider);
    final CheckoutState checkout = ref.watch(checkoutControllerProvider);
    // نفس الرقم الذي يُرسل للخادم: الإجمالي = صافي + رسوم المنطقة الديناميكية.
    final double total = cart.subtotal - cart.discount + checkout.deliveryFee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.orderSummary, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Row(children: [Expanded(child: Text(l10n.cartItemsLabel(cart.totalQuantity))), Text(Formatters.price(cart.subtotal, lang))]),
              if (cart.discount > 0) Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [Expanded(child: Text(l10n.discount)), Text('-${Formatters.price(cart.discount, lang)}', style: const TextStyle(color: AppColors.success))])),
              Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [Expanded(child: Text(l10n.deliveryFee)), Text(checkout.deliveryFee == 0 ? l10n.freeDelivery : Formatters.price(checkout.deliveryFee, lang))])),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
              Row(children: [Expanded(child: Text(l10n.total, style: Theme.of(context).textTheme.titleMedium)), Text(Formatters.price(total, lang), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary))]),
            ],
          ),
        ),
      ],
    );
  }
}
