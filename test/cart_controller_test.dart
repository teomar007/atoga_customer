import 'package:atoga_customer/core/services/cart_storage.dart';
import 'package:atoga_customer/features/cart/domain/cart_item.dart';
import 'package:atoga_customer/features/cart/domain/coupon.dart';
import 'package:atoga_customer/features/cart/presentation/cart_controller.dart';
import 'package:atoga_customer/features/home/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// مزوّد تخزين وهمي: يتجاهل الكتابة (Hive غير متاح في اختبارات الوحدة).
class _MemoryCartStore implements CartStore {
  List<CartItem> _items = <CartItem>[];

  @override
  List<CartItem> readAll() => List<CartItem>.of(_items);

  @override
  Future<void> writeAll(List<CartItem> items) async => _items = List<CartItem>.of(items);

  @override
  Future<void> clear() async => _items = <CartItem>[];
}

ProviderContainer _container() {
  final ProviderContainer container = ProviderContainer(overrides: <Override>[cartStorageProvider.overrideWithValue(_MemoryCartStore())]);
  return container;
}

const Product p1 = Product(id: 'p1', name: 'طماطم مصبرة', price: 120);
const Product p2 = Product(id: 'p2', name: 'تون معلب', price: 280);

void main() {
  group('CartState arithmetic', () {
    test('المجموع الفرعي يحسب مجموع الأسطر', () {
      final CartState cart = const CartState(items: <CartItem>[CartItem(productId: 'p1', name: 'a', price: 120, quantity: 2), CartItem(productId: 'p2', name: 'b', price: 280, quantity: 3)]);
      expect(cart.subtotal, 1080);
      expect(cart.totalQuantity, 5);
    });

    test('التوصيل مجاني فوق 3000 د.ج', () {
      const CartState cheap = CartState(items: <CartItem>[CartItem(productId: 'p1', name: 'a', price: 100, quantity: 1)]);
      expect(cheap.deliveryFee, 200);

      const CartState rich = CartState(items: <CartItem>[CartItem(productId: 'p1', name: 'a', price: 1000, quantity: 3)]);
      expect(rich.subtotal, 3000);
      expect(rich.deliveryFee, 0);
    });

    test('الكوبون بالنسبة المئوية', () {
      const CartState cart = CartState(items: <CartItem>[CartItem(productId: 'p1', name: 'a', price: 1000, quantity: 1)]);
      final Coupon tenPercent = Coupon(code: 'X', type: 'percent', value: 10);
      expect(tenPercent.discountFor(cart.subtotal), 100);
    });

    test('الكوبون الثابت لا يتجاوز قيمة الطلبية', () {
      const CartState cart = CartState(items: <CartItem>[CartItem(productId: 'p1', name: 'a', price: 100, quantity: 1)]);
      final Coupon fixed = Coupon(code: 'X', type: 'fixed', value: 500);
      expect(fixed.discountFor(cart.subtotal), 100);
    });

    test('الكوبون يُرفض تحت الحد الأدنى', () {
      final Coupon minOrder = const Coupon(code: 'BIG', type: 'fixed', value: 500, minSubtotal: 3000);
      expect(minOrder.discountFor(1000), 0);
      expect(minOrder.discountFor(3000), 500);
    });
  });

  group('CartController', () {
    test('addProduct يزيد الكمية إن كان المنتج موجوداً', () async {
      final ProviderContainer c = _container();
      final CartController cart = c.read(cartControllerProvider.notifier);
      await cart.addProduct(p1);
      await cart.addProduct(p1);
      expect(c.read(cartControllerProvider).quantityOf('p1'), 2);
      expect(c.read(cartControllerProvider).items.length, 1);
    });

    test('decrement يحذف العنصر عند الوصول للصفر', () async {
      final ProviderContainer c = _container();
      final CartController cart = c.read(cartControllerProvider.notifier);
      await cart.addProduct(p1);
      await cart.decrement('p1');
      expect(c.read(cartControllerProvider).items, isEmpty);
    });

    test('increment على منتج غير موجود يعيد false', () async {
      final ProviderContainer c = _container();
      expect(await c.read(cartControllerProvider.notifier).increment('missing'), isFalse);
    });

    test('remove يحذف العنصر المحدد فقط', () async {
      final ProviderContainer c = _container();
      final CartController cart = c.read(cartControllerProvider.notifier);
      await cart.addProduct(p1);
      await cart.addProduct(p2);
      await cart.remove('p1');
      expect(c.read(cartControllerProvider).items.length, 1);
      expect(c.read(cartControllerProvider).items.first.productId, 'p2');
    });

    test('applyLocalCoupon يرفض الكود غير الموجود ويقبل الصحيح', () async {
      final ProviderContainer c = _container();
      final CartController cart = c.read(cartControllerProvider.notifier);
      await cart.addProduct(p1);
      expect(await cart.applyLocalCoupon('NOPE'), isFalse);
      expect(c.read(cartControllerProvider).couponError, isTrue);
      expect(await cart.applyLocalCoupon('welcome10'), isTrue);
      expect(c.read(cartControllerProvider).coupon?.code, 'WELCOME10');
      expect(c.read(cartControllerProvider).discount, 12);
    });
  });

  group('CartItem serialization', () {
    test('يحفظ ويقرأ عبر JSON دون فقد', () {
      final CartItem item = CartItem.fromProduct(p1, quantity: 3);
      final CartItem? restored = CartItem.tryDecode(item.toJson());
      expect(restored, isNotNull);
      expect(restored!.name, 'طماطم مصبرة');
      expect(restored.quantity, 3);
      expect(restored.price, 120);
    });

    test('يتجاهل السجل التالف', () {
      expect(CartItem.tryDecode('garbage'), isNull);
      expect(CartItem.tryDecode(null), isNull);
      expect(CartItem.tryDecode(<String, dynamic>{'name': 'x'}), isNull);
    });

    test('يحفظ النسخة الفرنسية من الاسم ويعرضها حسب اللغة', () {
      const Product product = Product(id: 'p9', name: 'زبدة', nameFr: 'Beurre', price: 450);
      final CartItem? restored = CartItem.tryDecode(CartItem.fromProduct(product, quantity: 1).toJson());
      expect(restored, isNotNull);
      expect(restored!.nameFor('ar'), 'زبدة');
      expect(restored.nameFor('fr'), 'Beurre');
    });

    test('سجلات السلة القديمة (بلا nameFr) تعود للاسم الأساسي', () {
      final CartItem? legacy = CartItem.tryDecode('{"productId":"p1","name":"طماطم","price":120,"quantity":1}');
      expect(legacy, isNotNull);
      expect(legacy!.nameFor('fr'), 'طماطم');
    });
  });
}
