// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'ATOGA MARKET';

  @override
  String get homeTab => 'Accueil';

  @override
  String get tagline => 'Courses vite et simplement';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get confirm => 'Confirmer';

  @override
  String get proceed => 'Continuer';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get done => 'Terminé';

  @override
  String get apply => 'Appliquer';

  @override
  String get add => 'Ajouter';

  @override
  String get clear => 'Effacer';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get loading => 'Chargement...';

  @override
  String get optional => 'facultatif';

  @override
  String get required => 'requis';

  @override
  String get search => 'Rechercher';

  @override
  String get quantity => 'Quantité';

  @override
  String get price => 'Prix';

  @override
  String get total => 'Total';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'produits',
      two: '2 produits',
      one: '1 produit',
      zero: 'Aucun produit',
    );
    return '$_temp0';
  }

  @override
  String cartBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'articles',
      two: '2 articles',
      one: '1 article',
      zero: 'Rien',
    );
    return '$_temp0';
  }

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitleEmail =>
      'Saisissez votre e-mail et votre mot de passe';

  @override
  String get loginSubtitlePhone =>
      'Saisissez votre numéro de téléphone et votre mot de passe';

  @override
  String get phoneAuthHint =>
      'Ex : 0555123456 — votre compte est créé et vous entrez directement';

  @override
  String get phoneExists =>
      'Ce numéro est déjà enregistré. Connectez-vous ou utilisez Google.';

  @override
  String get phoneConfirmNeeded =>
      'Compte créé. Le numéro doit être confirmé avant la connexion (activez « Confirmation automatique du téléphone » dans Supabase).';

  @override
  String get phoneAuthDisabled =>
      'L\'inscription par téléphone est désactivée. Activez le fournisseur Phone dans Supabase ou connectez-vous via Google.';

  @override
  String get smsNotConfigured =>
      'Le service SMS n\'est pas configuré. Liez un fournisseur SMS dans Supabase ou connectez-vous via Google.';

  @override
  String get autoconfirmRequired =>
      'Compte créé mais aucune session ouverte. Activez la confirmation automatique de l\'e-mail dans Supabase : Authentication > Email > Confirm email = OFF.';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get login => 'Se connecter';

  @override
  String get registerSubtitle => 'Créez un compte pour commander plus vite';

  @override
  String get email => 'Adresse e-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get emailInvalid => 'Adresse e-mail invalide';

  @override
  String get emailExists => 'Cette adresse e-mail est déjà enregistrée';

  @override
  String get invalidCredentials => 'E-mail ou mot de passe incorrect';

  @override
  String get signUpFailed => 'Impossible de créer le compte';

  @override
  String get signUpDisabled =>
      'L\'inscription est désactivée. Activez un fournisseur dans Supabase ou utilisez Google.';

  @override
  String get userBanned => 'Ce compte est suspendu. Contactez le support.';

  @override
  String get sessionExpired => 'Session expirée, veuillez vous reconnecter';

  @override
  String get invalidInput => 'Les données saisies sont invalides';

  @override
  String get rlsDenied =>
      'Permissions insuffisantes : écriture refusée sur votre profil';

  @override
  String get schemaMissing =>
      'Base de données non initialisée. Exécutez supabase/schema.sql dans Supabase.';

  @override
  String errorCodeLabel(String code) {
    return 'Code d\'erreur : $code';
  }

  @override
  String get tooManyAttemptsDetailed =>
      'Limite d\'envoi d\'e-mails atteinte. Patientez ou inscrivez-vous via Google.';

  @override
  String get verifyEmail => 'Vérifiez votre e-mail pour activer le compte';

  @override
  String get accountCreated => 'Votre compte a été créé avec succès';

  @override
  String get resetSent => 'Lien de réinitialisation envoyé à votre e-mail';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get haveAccount => 'Déjà un compte ? Se connecter';

  @override
  String get noAccount => 'Pas de compte ? Créer un compte';

  @override
  String get emailFirst => 'Saisissez d\'abord votre e-mail';

  @override
  String get phoneNumberOptional => 'Numéro de téléphone (facultatif)';

  @override
  String get phoneOptionalHint =>
      'Il devient obligatoire à la première commande';

  @override
  String get phoneSaved => 'Numéro de téléphone enregistré';

  @override
  String get notSet => 'Non défini';

  @override
  String get phoneRequired =>
      'Le numéro de téléphone est requis pour commander';

  @override
  String get phoneRequiredTitle => 'Ajoutez votre numéro';

  @override
  String get phoneRequiredBody =>
      'Le numéro sert à vous contacter et à livrer la commande. Il ne vous sera redemandé que si vous le modifiez.';

  @override
  String get phonePrivacyNote =>
      'Utilisé uniquement pour la livraison, jamais partagé avec des tiers.';

  @override
  String get phoneSaveFailed => 'Enregistrement impossible, veuillez réessayer';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get phoneHint => '5X XX XX XX';

  @override
  String get tooManyAttempts => 'Trop de tentatives. Patientez puis réessayez';

  @override
  String get orContinueWith => 'ou continuer avec';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get browseAsGuest => 'Naviguer en invité';

  @override
  String get browseAsGuestHint =>
      'Vous pouvez parcourir les produits sans compte. La connexion sera demandée à la commande.';

  @override
  String get byContinuing => 'En continuant, vous acceptez nos';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get loginRequiredTitle => 'Connexion requise';

  @override
  String get loginToViewProfile => 'Connectez-vous pour afficher votre compte';

  @override
  String get loginRequiredBody =>
      'Connectez-vous pour finaliser votre commande. Votre panier est conservé.';

  @override
  String get searchHint => 'Rechercher un produit...';

  @override
  String get promosTitle => 'Offres du jour';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String get productsTitle => 'Produits';

  @override
  String get allCategories => 'Tout';

  @override
  String get categoryCanned => 'Conserves';

  @override
  String get categoryDrinks => 'Boissons';

  @override
  String get categoryDairy => 'Fromages & lait';

  @override
  String get categoryGrains => 'Pâtes & céréales';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryCleaning => 'Produits ménagers';

  @override
  String get noProducts => 'Aucun produit';

  @override
  String get noProductsHint =>
      'Essayez une autre catégorie ou un autre mot-clé';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get addedToCart => 'Ajouté au panier';

  @override
  String get removeFromCart => 'Retirer du panier';

  @override
  String get favoriteAdd => 'Ajouter aux favoris';

  @override
  String get favoriteRemove => 'Retirer des favoris';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesEmpty => 'Aucun produit favori';

  @override
  String get favoritesEmptyHint =>
      'Touchez le cœur d\'un produit pour l\'afficher ici';

  @override
  String get decreaseQuantity => 'Diminuer la quantité';

  @override
  String get increaseQuantity => 'Augmenter la quantité';

  @override
  String get unitCan => 'Boîte';

  @override
  String get unitBottle => 'Bouteille';

  @override
  String get unitPack => 'Pack';

  @override
  String get unitJar => 'Pot';

  @override
  String get unitFlask => 'Flacon';

  @override
  String get unitBag => 'Sac';

  @override
  String get unitPiece => 'Pièce';

  @override
  String get searchNoResult => 'Aucun résultat';

  @override
  String get searchNoResultHint =>
      'Vérifiez l\'orthographe ou essayez une autre catégorie';

  @override
  String get cartTitle => 'Panier';

  @override
  String get cartEmpty => 'Votre panier est vide';

  @override
  String get cartEmptyHint =>
      'Commencez vos achats et ajoutez vos produits préférés';

  @override
  String get startShopping => 'Commencer mes achats';

  @override
  String cartItemsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'produits',
      two: '2 produits',
      one: '1 produit',
      zero: 'Aucun produit',
    );
    return '$_temp0';
  }

  @override
  String get subtotal => 'Sous-total';

  @override
  String get deliveryFee => 'Frais de livraison';

  @override
  String get discount => 'Remise';

  @override
  String get coupon => 'Code promo';

  @override
  String get couponHint => 'Saisissez le code promo';

  @override
  String get couponApply => 'Appliquer';

  @override
  String get couponApplied => 'Code promo appliqué';

  @override
  String get couponInvalid => 'Code promo invalide';

  @override
  String get couponRemove => 'Retirer le code';

  @override
  String couponDiscountValue(String value) {
    return 'Remise $value';
  }

  @override
  String get couponsTitle => 'Coupons';

  @override
  String get couponsEmpty => 'Aucun coupon disponible';

  @override
  String get couponsEmptyHint =>
      'Revenez plus tard, de nouvelles offres peuvent arriver';

  @override
  String get couponCopied => 'Code promo copié';

  @override
  String get copy => 'Copier';

  @override
  String get proceedToCheckout => 'Passer la commande';

  @override
  String itemRemoved(String name) {
    return '$name supprimé';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get swipeToDeleteHint => 'Glissez pour supprimer';

  @override
  String minimumOrder(String value) {
    return 'Commande minimum $value';
  }

  @override
  String get freeDelivery => 'Livraison gratuite';

  @override
  String get checkoutTitle => 'Commander';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get addNewAddress => 'Ajouter une adresse';

  @override
  String get editAddress => 'Modifier l\'adresse';

  @override
  String get street => 'Rue';

  @override
  String get streetHint => 'Nom de la rue';

  @override
  String get building => 'Immeuble / Bâtiment';

  @override
  String get buildingHint => 'Numéro d\'immeuble';

  @override
  String get apartment => 'Étage / Appartement';

  @override
  String get apartmentHint => 'Ex : 3e étage, app. 12';

  @override
  String get notesForCourier => 'Instructions pour le livreur';

  @override
  String get notesForCourierHint => 'Ex : appeler avant d\'arriver';

  @override
  String get contactPhone => 'Téléphone de contact';

  @override
  String get pinLocation => 'Épinglez votre position';

  @override
  String get pinLocationHint =>
      'Appuyez sur la carte pour définir le point de livraison';

  @override
  String get useCurrentLocation => 'Utiliser ma position';

  @override
  String get locating => 'Localisation en cours...';

  @override
  String get locationPermissionTitle => 'Accès à la localisation';

  @override
  String get locationPermissionBody =>
      'Nous avons besoin de votre position pour livrer votre commande précisément à votre porte';

  @override
  String get locationPermissionDenied =>
      'Autorisation refusée. Vous pouvez l\'activer dans les paramètres du téléphone.';

  @override
  String get locationPermissionDeniedForever =>
      'Autorisation refusée définitivement. Activez-la dans les paramètres de l\'application.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get locationUnavailable =>
      'Position indisponible, déposez le repère manuellement sur la carte';

  @override
  String get savedAddresses => 'Adresses enregistrées';

  @override
  String get noSavedAddresses => 'Aucune adresse enregistrée';

  @override
  String get deleteAddress => 'Supprimer l\'adresse';

  @override
  String get deleteAddressConfirm => 'Supprimer cette adresse ?';

  @override
  String get addressLabelHome => 'Domicile';

  @override
  String get addressLabelWork => 'Bureau';

  @override
  String get addressLabelOther => 'Autre';

  @override
  String get addressLabel => 'Libellé de l\'adresse';

  @override
  String get selectAddress => 'Choisir l\'adresse de livraison';

  @override
  String get addressSaved => 'Adresse enregistrée';

  @override
  String get fieldRequired => 'Ce champ est requis';

  @override
  String get phoneInvalidShort => 'Saisissez un numéro valide';

  @override
  String get locationRequired => 'Épinglez le point de livraison sur la carte';

  @override
  String get chooseAddressFirst => 'Choisissez d\'abord une adresse';

  @override
  String get paymentMethod => 'Mode de paiement';

  @override
  String get cashOnDelivery => 'Paiement à la livraison';

  @override
  String get cashOnDeliveryDesc => 'Payez en espèces au livreur à l\'arrivée';

  @override
  String get paymentMethodFixed =>
      'Le paiement à la livraison est actuellement le seul mode disponible';

  @override
  String get orderSummary => 'Récapitulatif';

  @override
  String get confirmOrder => 'Confirmer la commande';

  @override
  String get sendingOrder => 'Envoi de la commande...';

  @override
  String get orderPlaced => 'Commande reçue !';

  @override
  String get orderPlacedBody =>
      'Notre équipe vous contactera pour confirmer. Vous pouvez suivre l\'avancement à tout moment.';

  @override
  String get orderNumber => 'N° de commande';

  @override
  String get trackOrder => 'Suivre la commande';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get orderFailed => 'Envoi impossible';

  @override
  String get orderFailedBody => 'Vérifiez votre connexion et réessayez';

  @override
  String insufficientStock(String name) {
    return 'Stock insuffisant pour $name';
  }

  @override
  String get ordersTitle => 'Commandes';

  @override
  String get activeOrders => 'Commandes en cours';

  @override
  String get pastOrders => 'Commandes passées';

  @override
  String get noOrders => 'Aucune commande';

  @override
  String get noOrdersHint => 'Vos futures commandes apparaîtront ici';

  @override
  String get trackingTitle => 'Suivi de commande';

  @override
  String get statusReceived => 'Reçue';

  @override
  String get statusPreparing => 'En préparation';

  @override
  String get statusOnTheWay => 'En route';

  @override
  String get statusDelivered => 'Livrée';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String get statusReceivedDesc => 'Votre commande a bien été reçue';

  @override
  String get statusPreparingDesc => 'Notre équipe prépare votre commande';

  @override
  String get statusOnTheWayDesc => 'Le livreur est en chemin';

  @override
  String get statusDeliveredDesc => 'Commande livrée. Bon appétit !';

  @override
  String get statusCancelledDesc => 'Cette commande a été annulée';

  @override
  String get courierInfo => 'Livreur';

  @override
  String get callCourier => 'Appeler';

  @override
  String get orderDate => 'Date de commande';

  @override
  String get orderTotal => 'Total';

  @override
  String get reorder => 'Commander à nouveau';

  @override
  String get reordered => 'Les produits ont été ajoutés au panier';

  @override
  String get invoice => 'Facture';

  @override
  String get cancelOrder => 'Annuler la commande';

  @override
  String get cancelOrderConfirm => 'Annuler cette commande ?';

  @override
  String get orderCancelledToast => 'Commande annulée';

  @override
  String get cancelOrderTooLate =>
      'Désolé, il n\'est plus possible d\'annuler la commande : la préparation a déjà commencé.';

  @override
  String deliveredAt(String date) {
    return 'Livrée le $date';
  }

  @override
  String estimatedDelivery(String time) {
    return 'Livraison estimée : $time';
  }

  @override
  String get profileTitle => 'Compte';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get name => 'Nom complet';

  @override
  String get nameHint => 'Saisissez votre nom';

  @override
  String get profileUpdated => 'Informations mises à jour';

  @override
  String get guestUser => 'Invité';

  @override
  String get loginToEditProfile =>
      'Connectez-vous pour modifier vos informations';

  @override
  String get addresses => 'Adresses de livraison';

  @override
  String get language => 'Langue';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get languageFrench => 'Français';

  @override
  String get support => 'Assistance';

  @override
  String get settings => 'Paramètres';

  @override
  String get contactUs => 'Appelez-nous';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get faq => 'Questions fréquentes';

  @override
  String get socialLinks => 'Réseaux sociaux';

  @override
  String get facebook => 'Facebook';

  @override
  String get instagram => 'Instagram';

  @override
  String get tiktok => 'TikTok';

  @override
  String get linkNotSet => 'Lien indisponible pour le moment';

  @override
  String get contactNotSet => 'Numéro de contact indisponible';

  @override
  String get deliveryZone => 'Zone de livraison';

  @override
  String get deliveryZonesEmpty => 'Aucune zone de livraison disponible';

  @override
  String get aboutApp => 'À propos';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutConfirm => 'Voulez-vous vous déconnecter ?';

  @override
  String get deleteAccount => 'Supprimer définitivement mon compte';

  @override
  String get deleteAccountWarning =>
      'Toutes vos données seront définitivement supprimées. Cette action est irréversible.';

  @override
  String get deleteAccountConfirmTitle => 'Confirmer la suppression';

  @override
  String get deleteAccountConfirmBody =>
      'Votre compte, vos commandes, vos adresses et toutes vos données seront définitivement supprimés. Cette action est irréversible.';

  @override
  String get deleteAccountConfirmAction => 'Oui, supprimer mon compte';

  @override
  String get accountDeleted => 'Votre compte a été supprimé';

  @override
  String get deleteAccountFailed =>
      'Suppression impossible, veuillez réessayer';

  @override
  String get supportUnavailable =>
      'Impossible d\'ouvrir le lien, réessayez plus tard';

  @override
  String get noInternet => 'Aucune connexion Internet';

  @override
  String get noInternetBody => 'Vérifiez votre connexion puis réessayez';

  @override
  String get somethingWentWrong => 'Une erreur est survenue';

  @override
  String get dataLoadFailed => 'Chargement des données impossible';

  @override
  String get productsLoadFailed => 'Chargement des produits impossible';

  @override
  String get ordersLoadFailed => 'Chargement des commandes impossible';

  @override
  String get guestCartNotice =>
      'Vous naviguez en invité. Connectez-vous au moment de commander.';

  @override
  String get legalLastUpdated => 'Dernière mise à jour : octobre 2026';

  @override
  String get privacyIntro =>
      'La présente politique s\'applique à l\'application ATOGA MARKET, dédiée à la commande et à la livraison de produits d\'écosupermarché en Algérie. Elle décrit les données que nous collectons, leur utilisation, les mesures de sécurité appliquées ainsi que vos droits. En créant un compte ou en passant une commande dans l\'application, vous déclarez avoir lu et accepter la présente politique, et toute modification est publiée dans l\'application.';

  @override
  String get privacySecDataTitle => 'Les données que nous collectons';

  @override
  String get privacySecDataBody =>
      'Nous collectons uniquement les données indispensables au traitement de votre commande :\n• Votre numéro de téléphone : moyen de contact principal pour confirmer la commande et vous joindre si nécessaire.\n• Votre nom et les informations de votre compte.\n• L\'adresse de livraison saisie : rue, immeuble, étage et indications d\'accès.\n• Vos coordonnées GPS (latitude et longitude) : uniquement lorsque vous choisissez d\'utiliser votre position actuelle pour placer votre adresse sur la carte, et vous pouvez la saisir manuellement sans accorder cette autorisation.\n• L\'historique de vos commandes : articles, quantités, prix, frais de livraison, date et statut de la commande.\nNous ne collectons ni ne stockons aucune donnée de carte bancaire, le paiement étant exclusivement à la livraison.';

  @override
  String get privacySecUsageTitle => 'Comment nous utilisons vos données';

  @override
  String get privacySecUsageBody =>
      'Nous utilisons vos données exclusivement pour : traiter, préparer et remettre votre commande au livreur chargé de la livraison ; vous contacter par téléphone pour confirmer la commande ou en cas de question ou de rupture de stock ; calculer les frais de livraison de manière dynamique selon la zone ou le quartier choisi ; afficher l\'historique de vos commandes dans l\'application ; et améliorer nos services et les performances de la boutique.\nNous n\'utilisons pas vos données à des fins publicitaires et n\'envoyons aucun message commercial sans votre accord.';

  @override
  String get privacySecSecurityTitle => 'Sécurité et hébergement des données';

  @override
  String get privacySecSecurityBody =>
      'Vos données sont stockées dans la base de données Supabase protégée, soumise à des règles de sécurité au niveau des lignes (RLS) qui garantissent qu\'aucun utilisateur ne peut consulter les données d\'un autre, et transitent via une connexion chiffrée (HTTPS).\nNous ne vendons pas vos données personnelles et ne les partageons avec aucun tiers en dehors de l\'opération de livraison : le livreur et le service de livraison ne reçoivent que les informations nécessaires (adresse, téléphone, détails de la commande) pour effectuer la remise. Une divulgation n\'est possible que si la législation algérienne en vigueur l\'impose.';

  @override
  String get privacySecRightsTitle => 'Vos droits';

  @override
  String get privacySecRightsBody =>
      'Vous pouvez à tout moment : modifier votre nom et votre numéro depuis la page Mon compte ; ajouter, modifier ou supprimer vos adresses de livraison depuis l\'écran Adresses ; demander la suppression définitive de votre compte et de vos données personnelles depuis le bouton « Supprimer définitivement mon compte », votre compte, vos commandes et vos adresses étant effacés de la base de données et du système d\'authentification sans retour possible ; et retirer l\'autorisation de localisation depuis les réglages de votre téléphone.';

  @override
  String get privacySecContactTitle => 'Nous contacter';

  @override
  String get privacySecContactBody =>
      'Pour toute question relative à la confidentialité de vos données ou pour exercer l\'un des droits ci-dessus, contactez-nous depuis la section « Assistance » de l\'application (téléphone ou WhatsApp). Votre demande sera traitée dans les meilleurs délais.';

  @override
  String get termsIntro =>
      'Les présentes conditions régissent votre relation avec ATOGA MARKET lors de l\'utilisation de l\'application de commande et de livraison. En créant un compte ou en passant une commande, vous déclarez les accepter intégralement. Si vous n\'acceptez pas l\'une de ses dispositions, veuillez ne pas utiliser l\'application.';

  @override
  String get termsSecAccountTitle => 'Création du compte et responsabilité';

  @override
  String get termsSecAccountBody =>
      'Pour créer un compte, vous devez fournir des informations exactes et un numéro de téléphone joignable, susceptible de recevoir les appels, car le contact téléphonique est indispensable à la confirmation et à la remise de la commande. Vous êtes responsable de la confidentialité de vos identifiants et de toute commande passée via votre compte. La boutique se réserve le droit de suspendre ou de désactiver un compte en cas d\'utilisation abusive ou d\'informations inexactes ou en double.';

  @override
  String get termsSecPricingTitle => 'Prix et frais de livraison';

  @override
  String get termsSecPricingBody =>
      'Les prix sont affichés en dinar algérien (DA), peuvent évoluer sans préavis, et le prix applicable est celui en vigueur au moment de la confirmation de la commande. Les frais de livraison sont calculés de manière dynamique selon la zone ou le quartier choisi et s\'ajoutent au total de la commande avant paiement ; ils peuvent être annulés lorsque le total atteint le seuil de livraison gratuite affiché dans l\'application. Les codes promo valides peuvent également être appliqués au total.';

  @override
  String get termsSecPaymentTitle => 'Mode de paiement';

  @override
  String get termsSecPaymentBody =>
      'Le mode de paiement actuellement disponible est le paiement à la livraison (Cash on Delivery), en dinar algérien. Le client s\'engage à remettre au livreur, lors de la remise de la commande, le montant exact indiqué sur la facture. L\'application ne demande aucune donnée de carte bancaire ni aucun paiement électronique anticipé, et aucun montant n\'est exigé avant la remise effective de la commande.';

  @override
  String get termsSecCancellationTitle =>
      'Annulation et modification de la commande';

  @override
  String get termsSecCancellationBody =>
      'Vous pouvez modifier ou annuler gratuitement votre commande tant qu\'elle n\'est pas partie en livraison, en contactant l\'assistance. La boutique se réserve le droit d\'annuler la commande dans les cas suivants : impossibilité de vous joindre par téléphone avant la confirmation ou pendant la préparation ; adresse ou numéro de téléphone saisis de manière incorrecte ou incomplète ; indisponibilité de certains articles et refus des remplacements ; erreur substantielle sur les prix ou sur la commande. La raison de l\'annulation vous sera communiquée dans tous les cas.';

  @override
  String get termsSecChangesTitle => 'Modification des conditions';

  @override
  String get termsSecChangesBody =>
      'ATOGA MARKET peut mettre à jour les présentes conditions en cas d\'évolution des services ou de la réglementation. La version mise à jour prend effet dès sa publication dans l\'application, et toute utilisation ultérieure de l\'application vaut acceptation des conditions modifiées.';

  @override
  String get termsSecLawTitle => 'Droit applicable';

  @override
  String get termsSecLawBody =>
      'Les présentes conditions sont régies par la législation de la République Algérienne Démocratique et Populaire, notamment en matière de commerce électronique et de protection du consommateur. Tout litige est d\'abord recherché à l\'amiable auprès de l\'assistance de l\'application, sans préjudice de votre droit de saisir les autorités compétentes.';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletBalance => 'Solde disponible';

  @override
  String get walletTopUpHint =>
      'Pour recharger votre solde, rendez-vous dans notre magasin et déposez le montant en espèces ; il sera ajouté à votre compte.';

  @override
  String get walletHistoryTitle => 'Historique des opérations';

  @override
  String get walletNoTransactions => 'Aucune opération pour le moment';

  @override
  String get walletDepositTitle => 'Dépôt de solde (boutique)';

  @override
  String walletPaymentTitle(String orderId) {
    return 'Paiement pour la commande n° #$orderId';
  }

  @override
  String get walletInsufficient =>
      'Désolé, le solde de votre portefeuille est insuffisant. Le mode de paiement a été basculé sur le paiement à la livraison.';

  @override
  String get payWithWallet => 'Payer avec le portefeuille';

  @override
  String get rememberPassword => 'Mémoriser le mot de passe';

  @override
  String get rememberPasswordHint =>
      'Stocké chiffré sur votre appareil uniquement. Vous n\'aurez pas à le ressaisir.';

  @override
  String get appDeveloperTitle => 'Développeur de l\'application';

  @override
  String get appDeveloperMarketing =>
      'Cette application a été développée par DIRAYA LAB. Pour votre propre application, contactez-nous à l\'adresse suivante :';

  @override
  String get appDeveloperEmailCopied => 'Adresse e-mail copiée avec succès';

  @override
  String get storeOpenStatus => 'Le magasin est ouvert — commandez';

  @override
  String get storeClosedStatus => 'Le magasin est fermé';

  @override
  String get onesignalPromptTitle => 'Activer les notifications';

  @override
  String get onesignalPromptBody =>
      'Nous souhaitons vous envoyer des notifications pour confirmer vos commandes et suivre la livraison.';

  @override
  String get onesignalPromptAllow => 'Autoriser';

  @override
  String get walletUserId => 'ID utilisateur (pour recharger en boutique)';

  @override
  String get walletUserIdCopied => 'ID utilisateur copié avec succès';

  @override
  String get storeClosedAddToCart =>
      'Le magasin est fermé — ajout au panier indisponible';
}
