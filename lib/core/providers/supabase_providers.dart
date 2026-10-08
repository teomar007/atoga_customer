import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/supabase_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/cart/data/cart_cloud_store.dart';
import '../../features/favorites/data/favorites_repository.dart';
import '../../features/home/data/catalog_repository.dart';
import '../../features/coupons/data/coupons_repository.dart';
import '../../features/checkout/data/delivery_zone_repository.dart';
import '../../features/social/data/social_links_repository.dart';

/// عميل Supabase المُهيّأ في `main.dart`.
final supabaseClientProvider = Provider<SupabaseClient>((Ref ref) => throw UnimplementedError('supabaseClientProvider must be overridden in ProviderScope'));

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) => SupabaseAuthRepository(ref.watch(supabaseClientProvider)));

final catalogRepositoryProvider = Provider<CatalogRepository>((Ref ref) => CatalogRepository(ref.watch(supabaseClientProvider)));

final couponsRepositoryProvider = Provider<CouponsRepository>((Ref ref) => CouponsRepository(ref.watch(supabaseClientProvider)));

final cartCloudStoreProvider = Provider<CartCloudStore>((Ref ref) => CartCloudStore(ref.watch(supabaseClientProvider)));

final favoritesRepositoryProvider = Provider<FavoritesRepository>((Ref ref) => FavoritesRepository(ref.watch(supabaseClientProvider)));

final socialLinksRepositoryProvider = Provider<SocialLinksRepository>((Ref ref) => SocialLinksRepository(ref.watch(supabaseClientProvider)));

final deliveryZoneRepositoryProvider = Provider<DeliveryZoneRepository>((Ref ref) => DeliveryZoneRepository(ref.watch(supabaseClientProvider)));
