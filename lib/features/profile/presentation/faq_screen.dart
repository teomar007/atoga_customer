import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// صفحة «الأسئلة الشائعة» داخل التطبيق — بديل الصفحة الخارجية.
///
/// المحتوى ثنائي اللغة (عربي/فرنسي) ويُختار حسب لغة العرض الحالية،
/// ولا يتطلب اتصالاً بالشبكة.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<({String q, String a})> _arabic = <({String q, String a})>[
    (q: 'كيف أسجّل في التطبيق؟', a: 'أدخل رقم هاتفك (مثال: 0555123456) وكلمة مرور، أو سجّل عبر Google. بعد التسجيل أضف اسمك ورقم هاتف صحيحاً من «حسابي» لنتواصل معك عند تأكيد الطلب.'),
    (q: 'كيف أطلب؟', a: 'تصفّح المنتجات، أضف ما تريد إلى السلة، ثم من السلة اضغط «متابعة الشراء»، اختر عنوان التوصيل وطريقة الدفع وأكّد الطلب.'),
    (q: 'هل يوجد حد أدنى للطلب؟ وكم رسوم التوصيل؟', a: 'يمكنك الطلب بأي مبلغ. رسوم التوصيل 200 د.ج، وتصبح مجانية تلقائياً للطلبات فوق 3000 د.ج، كما تُحسب حسب منطقة التوصيل عند اختيار العنوان.'),
    (q: 'ما طرق الدفع المتاحة؟', a: 'الدفع عند الاستلام نقداً، أو الدفع من رصيد محفظتك الإلكترونية مباشرةً داخل التطبيق.'),
    (q: 'كيف أشحن محفظتي؟', a: 'تواصل مع الإدارة من «حسابي ← الدعم الفني» (هاتف أو واتساب) وأرسل رقم الهاتف المرتبط بالحساب، وسيُشحن رصيدك. يمكنك أيضاً استخدام معرّف المستخدم الظاهر في صفحة المحفظة.'),
    (q: 'كيف أتابع طلبي؟', a: 'من قسم «طلباتي» تظهر حالة الطلب لحظة بلحظة: تم الاستلام، قيد التجهيز، في الطريق إليك، وتم التسليم.'),
    (q: 'ماذا يحدث إذا كان المتجر مغلقاً؟', a: 'تظهر حالة الإغلاق أعلى الصفحة الرئيسية ولا يمكن إضافة منتجات أو إرسال طلبات حتى موعد الفتح وفق ساعات العمل المعلنة.'),
    (q: 'كيف أستخدم كوبون الخصم؟', a: 'افتح السلة، وأدخل الكود في خانة «كود الخصم» ثم اضغط «تطبيق». سيظهر الخصم في ملخص الطلب قبل التأكيد.'),
    (q: 'ما سياسة المرتجعات؟', a: 'إن لم يُستلم الطلب أو كان هناك خطأ في محتواه، تُعاد إلى المتجر وتُحدَّث الحالة إلى «مرتجع». تواصل مع الدعم لتوضيح السبب.'),
    (q: 'كيف أحذف حسابي؟', a: 'من «حسابي» اضغط «حذف الحساب» وأكّد؛ سيُحذف حسابك وطلباتك وعناوينك وبياناتك نهائياً دون رجعة.'),
    (q: 'كيف أتواصل مع الدعم الفني؟', a: 'من «حسابي ← الدعم الفني»: اتصال هاتفي مباشر أو محادثة واتساب، أو تابعنا عبر صفحاتنا على فيسبوك وإنستغرام وتيك توك.'),
  ];

  static const List<({String q, String a})> _french = <({String q, String a})>[
    (q: 'Comment créer un compte ?', a: 'Saisissez votre numéro (ex : 0555123456) et un mot de passe, ou connectez-vous avec Google. Ensuite, ajoutez votre nom et un numéro valide depuis « Mon compte ».'), 
    (q: 'Comment passer une commande ?', a: 'Parcourez les produits, ajoutez-les au panier, puis appuyez sur « Passer la commande », choisissez l’adresse et le moyen de paiement et confirmez.'),
    (q: 'Y a-t-il un minimum de commande ? Frais de livraison ?', a: 'Commandez pour tout montant. Livraison à 200 DA, offerte automatiquement dès 3000 DA, et calculée selon la zone choisie.'),
    (q: 'Quels sont les moyens de paiement ?', a: 'Paiement en espèces à la livraison, ou via le solde de votre portefeuille directement dans l’application.'),
    (q: 'Comment recharger mon portefeuille ?', a: 'Contactez l\'administration depuis « Mon compte ← Assistance » (téléphone ou WhatsApp) ; votre solde sera crédité. Vous pouvez aussi transmettre l\'identifiant affiché dans la page portefeuille.'), 
    (q: 'Comment suivre ma commande ?', a: 'Dans « Mes commandes », le statut évolue en temps réel : reçue, en préparation, en route, livrée.'),
    (q: 'Que se passe-t-il si la boutique est fermée ?', a: 'La fermeture est affichée en haut de l’accueil ; aucun ajout ni commande n’est possible jusqu’à la réouverture.'),
    (q: 'Comment utiliser un code promo ?', a: 'Ouvrez le panier, saisissez le code dans « Code promo » puis « Appliquer » ; la remise apparaît dans le récapitulatif.'),
    (q: 'Quelle est la politique de retour ?', a: 'Si la commande n\'est pas reçue ou présente un problème, elle est retournée et le statut passe à « Retournée ». Contactez l\'assistance.'), 
    (q: 'Comment supprimer mon compte ?', a: 'Depuis « Mon compte », appuyez sur « Supprimer mon compte » et confirmez ; vos données sont effacées définitivement.'),
    (q: 'Comment contacter l’assistance ?', a: 'Depuis « Mon compte ← Assistance » : appel direct ou WhatsApp, ou via nos pages Facebook, Instagram et TikTok.'), 
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool arabic = Localizations.localeOf(context).languageCode == 'ar';
    final List<({String q, String a})> items = arabic ? _arabic : _french;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.faq, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.help_center_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    arabic
                        ? 'جمعنا لك أكثر الأسئلة تكراراً. إذا لم تجد إجابتك، تواصل معنا من قسم الدعم الفني.'
                        : "Retrouvez ici les réponses aux questions les plus fréquentes. Si vous ne trouvez pas la réponse, contactez l'assistance.",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final ({String q, String a}) item in items)
            Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                shape: const Border(),
                title: Text(
                  item.q,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.a, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
