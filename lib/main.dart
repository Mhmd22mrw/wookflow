import 'dart:io' show gzip;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

// ======================= الترجمة (عربي / فرنسي / إنجليزي) =======================

class L10n {
  static final ValueNotifier<String> notifier = ValueNotifier<String>('ar');
  static String get lang => notifier.value;
  static set lang(String v) => notifier.value = v;
  static bool get isRtl => lang == 'ar';

  static const List<String> codes = ['ar', 'fr', 'en'];
  static const Map<String, String> names = {
    'ar': 'العربية',
    'fr': 'Français',
    'en': 'English',
  };

  static int _idx(String l) => l == 'fr' ? 1 : (l == 'en' ? 2 : 0);

  static String tr(String key, String l) {
    final v = _s[key];
    if (v == null) return key;
    return v[_idx(l)];
  }

  static String t(String key) => tr(key, lang);

  static const List<List<String>> _days = [
    ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'],
    ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
    ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  ];

  static String day(int i, [String? l]) => _days[_idx(l ?? lang)][i];

  // [عربي, فرنسي, إنجليزي]
  static const Map<String, List<String>> _s = {
    'app_title': [
      'WookFlow - إدارة الورش والعمال',
      'WookFlow - Chantiers & ouvriers',
      'WookFlow - Sites & workers'
    ],
    'manager': [
      'مدير الورشة',
      'Chef de chantier',
      'Site manager'
    ],
    'version': [
      'نظام إدارة المشاريع v1.2.0',
      'Gestion de projets v1.2.0',
      'Project management v1.2.0'
    ],
    'language': ['اللغة', 'Langue', 'Language'],
    'report_lang': ['لغة التقرير', 'Langue du rapport', 'Report language'],
    'm_daily': [
      'التقرير اليومي (حضور اليوم)',
      'Rapport journalier (présence)',
      'Daily report (attendance)'
    ],
    'm_add_worker': ['إضافة عامل جديد', 'Ajouter un ouvrier', 'Add worker'],
    'm_delete_worker': [
      'إدارة وأرشفة العمال',
      'Gérer / archiver ouvriers',
      'Manage / archive workers'
    ],
    'm_sites': ['مواقع العمل (الورش)', 'Chantiers', 'Work sites'],
    'm_delivered': [
      'الورش المسلمة والمنتهية',
      'Chantiers livrés / terminés',
      'Delivered sites'
    ],
    'm_payment': [
      'دفعة جديدة (حسابات الورش)',
      'Nouveau paiement (comptes chantiers)',
      'New payment (site accounts)'
    ],
    'm_workers': [
      'قائمة العمال وتعديلهم',
      'Liste des ouvriers / modifier',
      'Workers list / edit'
    ],
    'm_weekly': [
      'ملخص الأسبوع والتقارير',
      'Résumé hebdo & rapports',
      'Weekly summary & reports'
    ],
    'm_site_analytics': [
      'ملخص وتحليل الورش والأرباح',
      'Analyse & rentabilité chantiers',
      'Site analytics & profit'
    ],
    'm_activity_log': [
      'سجل الحركات والنشاطات',
      'Journal des activités',
      'Activity audit log'
    ],
    'add_workers_first': [
      'أضف عمالًا أولًا من القائمة الجانبية',
      "Ajoutez d'abord des ouvriers depuis le menu",
      'Add workers first from the side menu'
    ],
    'daily_btn': [
      'التقرير اليومي (تسجيل حضور اليوم)',
      'Rapport journalier (pointage du jour)',
      "Daily report (today's attendance)"
    ],
    'card_workers_today': [
      'العمال اليوم',
      "Ouvriers aujourd'hui",
      'Workers today'
    ],
    'card_active_sites': ['الورش النشطة', 'Chantiers actifs', 'Active sites'],
    'card_delivered_sites': [
      'الورش المسلمة',
      'Chantiers livrés',
      'Delivered sites'
    ],
    'card_payments_manage': [
      'إدارة الدفعات',
      'Gestion paiements',
      'Manage payments'
    ],
    'card_hour_rate': ['سعر ساعة الإضافي', 'Taux heure supp.', 'Overtime rate/h'],
    'card_weekly': ['ملخص الأسبوع', 'Résumé de la semaine', 'Weekly summary'],
    'view_reports': ['عرض التقارير', 'Voir les rapports', 'View reports'],
    'daily_title': ['التقرير اليومي', 'Rapport journalier', 'Daily report'],
    'works': ['يعمل؟', 'Présent ?', 'Working?'],
    'site': ['الورشة', 'Chantier', 'Site'],
    'overtime': ['ساعات إضافية', 'Heures supp.', 'Overtime hours'],
    'transport': ['أجور النقل', 'Frais de transport', 'Transport costs'],
    'note': ['ملاحظة', 'Remarque', 'Note'],
    'day_total': ['إجمالي اليوم', 'Total du jour', 'Day total'],
    'save_close': [
      'حفظ وإغلاق التقرير اليومي',
      'Enregistrer et fermer',
      'Save & close'
    ],
    'add_worker_title': ['إضافة عامل جديد', 'Nouvel ouvrier', 'New worker'],
    'worker_name_req': [
      'اسم العامل (إجباري)',
      "Nom de l'ouvrier (obligatoire)",
      'Worker name (required)'
    ],
    'enter_name': [
      'يرجى إدخال اسم العامل',
      'Veuillez saisir le nom',
      'Please enter the name'
    ],
    'rate_req': [
      'الأجر اليومي',
      'Salaire journalier',
      'Daily wage'
    ],
    'enter_rate': [
      'يرجى إدخال اليومية',
      'Veuillez saisir le salaire',
      'Please enter the wage'
    ],
    'phone_opt': [
      'رقم الهاتف (اختياري)',
      'Téléphone (facultatif)',
      'Phone (optional)'
    ],
    'save_worker': [
      'حفظ العامل',
      "Enregistrer l'ouvrier",
      'Save worker'
    ],
    'worker_saved': [
      'تم إضافة العامل وحفظه بنجاح',
      'Ouvrier ajouté et enregistré',
      'Worker added and saved'
    ],
    'save_failed': [
      'فشل الحفظ',
      "Échec de l'enregistrement",
      'Save failed'
    ],
    'manage_workers_title': [
      'أرشفة وحذف العمال',
      'Archivage / suppression ouvriers',
      'Archive / delete workers'
    ],
    'archive_btn': [
      'أرشفة',
      'Archiver',
      'Archive'
    ],
    'restore_btn': [
      'استعادة',
      'Réactiver',
      'Restore'
    ],
    'permanent_delete_btn': [
      'حذف نهائي',
      'Suppression définitive',
      'Permanent delete'
    ],
    'active_tab': ['النشطون', 'Actifs', 'Active'],
    'archived_tab': ['المؤرشفون (السابقون)', 'Archivés', 'Archived'],
    'archive_success': [
      'تم أرشفة العامل بنجاح مع الحفاظ على جميع سجلاته السابقة',
      'Ouvrier archivé (historique conservé)',
      'Worker archived (history preserved)'
    ],
    'restore_success': [
      'تم إعادة تفعيل العامل بنجاح',
      'Ouvrier réactivé avec succès',
      'Worker reactivated'
    ],
    'permanent_delete_success': [
      'تم الحذف النهائي للعامل',
      'Ouvrier supprimé définitivement',
      'Worker permanently deleted'
    ],
    'delete_confirm_title': [
      'تأكيد الحذف النهائي',
      'Confirmation de suppression',
      'Confirm permanent deletion'
    ],
    'delete_confirm_body': [
      'تحذير: الحذف النهائي سيحذف العامل وجميع أيامه وسجلاته القديمة تماماً! للأمان، يفضل استخدام (الأرشفة) للاحتفاظ بالتقارير. هل تريد المتابعة؟',
      'Attention : Cela effacera définitivement l’ouvrier et son historique. Voulez-vous continuer ?',
      'Warning: This permanently deletes the worker and all historical records. Proceed?'
    ],
    'no_active_workers': [
      'لا يوجد عمال نشطون حالياً',
      'Aucun ouvrier actif',
      'No active workers'
    ],
    'no_archived_workers': [
      'لا يوجد عمال مؤرشفون',
      'Aucun ouvrier archivé',
      'No archived workers'
    ],
    'daily_wage': ['اليومية', 'Salaire/jour', 'Daily wage'],
    'phone': ['الهاتف', 'Tél.', 'Phone'],
    'add_site_title': [
      'إضافة موقع عمل جديد',
      'Nouveau chantier',
      'New work site'
    ],
    'edit_site_title': [
      'تعديل بيانات الورشة والحساب',
      'Modifier chantier & montant',
      'Edit site & contract amount'
    ],
    'site_name': ['اسم الموقع', 'Nom du chantier', 'Site name'],
    'site_address': ['العنوان', 'Adresse', 'Address'],
    'site_total': [
      'الأجر الكامل للورشة',
      'Montant total du chantier',
      'Total contract amount'
    ],
    'add_extra_amount': [
      'إضافة مبلغ على العقد (ملحق / أعمال إضافية)',
      'Ajouter un supplément au contrat',
      'Add extra amount to contract'
    ],
    'extra_amount_val': [
      'قيمة المبلغ الإضافي',
      'Montant du supplément',
      'Extra amount'
    ],
    'extra_amount_reason': [
      'سبب الإضافة (ملاحظة)',
      'Motif du supplément',
      'Reason for extra amount'
    ],
    'cancel': ['إلغاء', 'Annuler', 'Cancel'],
    'save': ['حفظ', 'Enregistrer', 'Save'],
    'confirm': ['تأكيد', 'Confirmer', 'Confirm'],
    'sites_title': [
      'مواقع العمل النشطة',
      'Chantiers actifs',
      'Active work sites'
    ],
    'no_active_sites': [
      'لا توجد ورش نشطة حالياً',
      'Aucun chantier actif',
      'No active sites'
    ],
    'total': ['الإجمالي', 'Total', 'Total'],
    'deliver': ['تسليم الورشة', 'Livrer le chantier', 'Deliver site'],
    'delivered_msg': [
      'تم تسليم الورشة ونقلها للأرشيف',
      'Chantier livré et archivé',
      'Site delivered and archived'
    ],
    'delivered_title': [
      'الورش المسلمة والمنتهية',
      'Chantiers livrés / terminés',
      'Delivered sites'
    ],
    'no_delivered': [
      'لا توجد ورش مسلمة حتى الآن',
      'Aucun chantier livré',
      'No delivered sites yet'
    ],
    'contract_total': ['الأجر الإجمالي', 'Montant total', 'Contract total'],
    'received': ['الواصل', 'Reçu', 'Received'],
    'delivered_flag': ['تم التسليم', 'Livré', 'Delivered'],
    'reopen_site': [
      'إعادة فتح الورشة للنشطة',
      'Rouvrir le chantier (actif)',
      'Reopen site (make active)'
    ],
    'reopen_confirm_title': [
      'إعادة فتح الورشة',
      'Rouvrir le chantier',
      'Reopen work site'
    ],
    'reopen_confirm_msg': [
      'هل تريد إعادة فتح هذه الورشة وإعادتها إلى قائمة الورش النشطة؟',
      'Voulez-vous réintégrer ce chantier dans les chantiers actifs ?',
      'Do you want to reopen this site and move it back to active sites?'
    ],
    'site_reopened_msg': [
      'تمت إعادة فتح الورشة ونقلها للنشطة بنجاح',
      'Chantier rouvert avec succès',
      'Site reopened successfully'
    ],
    'confirm_delivery_title': [
      'تأكيد تسليم الورشة',
      'Confirmer la livraison',
      'Confirm delivery'
    ],
    'confirm_delivery_paid_body': [
      'الحساب مقفل بالكامل، هل تريد تأكيد تسليم الورشة ونقلها للأرشيف؟',
      'Le compte est soldé. Confirmer la livraison du chantier ?',
      'Account fully settled. Confirm delivery and move to archive?'
    ],
    'unsettled_delivery_title': [
      'تنبيه: الحساب غير مقفل بعد',
      'Attention : Compte non soldé',
      'Warning: Account not settled'
    ],
    'unsettled_warning_note': [
      'تنبيه: لا يمكن تسليم الورشة مع وجود متبقي غير مسدد، إلا بإغلاق الحساب الآن أو التسليم باستثناء مع توضيح السبب بملاحظة.',
      'Attention : Chantier non soldé. Veuillez solder ou justifier par une remarque.',
      'Warning: Site has unpaid balance. Please settle in full or provide an exception note.'
    ],
    'exception_note_label': [
      'ملاحظة / سبب التسليم الاستثنائي (إجباري)',
      'Motif exceptionnel (obligatoire)',
      'Exception reason / note (required)'
    ],
    'exception_note_hint': [
      'مثال: اتفاق على تأجيل الدفع، خصم متفق عليه...',
      'Ex : report de paiement, remise...',
      'E.g. payment postponed, agreed discount...'
    ],
    'exception_note_required': [
      'يرجى كتابة سبب التسليم الاستثنائي قبل المتابعة',
      'Veuillez saisir le motif exceptionnel',
      'Please enter the exception reason'
    ],
    'pay_all_and_deliver': [
      'تسديد المتبقي وتسليم',
      'Tout solder et livrer',
      'Settle all and deliver'
    ],
    'deliver_with_exception': [
      'تسليم باستثناء مع الملاحظة',
      'Livrer avec dérogation',
      'Deliver with exception'
    ],
    'paid_in_full_on_delivery': [
      'تم سداد كامل المتبقي عند التسليم',
      'Soldé intégralement à la livraison',
      'Settled in full on delivery'
    ],
    'delivery_note_prefix': [
      'ملاحظة التسليم',
      'Note de livraison',
      'Delivery note'
    ],
    'delete_site_title': [
      'حذف الورشة',
      'Supprimer le chantier',
      'Delete site'
    ],
    'delete_site_confirm_msg': [
      'هل أنت متأكد من حذف الورشة نهائياً؟',
      'Êtes-vous sûr de supprimer définitivement ce chantier ?',
      'Are you sure you want to permanently delete this site?'
    ],
    'site_deleted_msg': [
      'تم حذف الورشة بنجاح',
      'Chantier supprimé avec succès',
      'Site deleted successfully'
    ],
    'delete_delivered_site': [
      'حذف من الأرشيف',
      'Supprimer des archives',
      'Delete from archives'
    ],
    'delete_delivered_confirm_msg': [
      'هل أنت متأكد من حذف هذه الورشة المسلمة نهائياً من الأرشيف؟',
      'Êtes-vous sûr de supprimer définitivement ce chantier des archives ?',
      'Are you sure you want to permanently delete this site from archives?'
    ],
    'payments_title': [
      'إدارة الدفعات والواصل',
      'Gestion des paiements',
      'Payments management'
    ],
    'no_sites_payment': [
      'لا توجد ورش نشطة لإضافة دفعات',
      'Aucun chantier actif pour ajouter un paiement',
      'No active sites to add payments'
    ],
    'remaining': ['الباقي', 'Reste', 'Remaining'],
    'add_payment_for': [
      'إضافة دفعة لـ',
      'Ajouter un paiement pour',
      'Add payment for'
    ],
    'payments_sum': [
      'مجموع الدفعات (الواصل)',
      'Total des paiements (reçu)',
      'Total payments (received)'
    ],
    'new_payment': [
      'قيمة الدفعة الجديدة',
      'Nouveau paiement',
      'New payment'
    ],
    'pay_remaining_all': [
      'دفع كامل المتبقي',
      'Payer tout le reste',
      'Pay all remaining'
    ],
    'site_already_fully_paid': [
      'تم سداد كامل قيمة الورشة، لا يوجد متبقي لإضافة دفعات',
      'Le chantier est déjà entièrement payé',
      'Site already fully paid, no remaining balance'
    ],
    'invalid_payment_amount': [
      'يرجى إدخال مبلغ صحيح أكبر من صفر',
      'Veuillez saisir un montant supérieur à zéro',
      'Please enter a valid amount greater than zero'
    ],
    'payment_exceeds_remaining': [
      'خطأ: المبلغ المدخل أكبر من المتبقي',
      'Erreur : Le montant dépasse le solde restant',
      'Error: Amount exceeds remaining balance'
    ],
    'payment_saved_ok': [
      'تم تسجيل الدفعة بنجاح',
      'Paiement enregistré avec succès',
      'Payment recorded successfully'
    ],
    'workers_list_title': [
      'قائمة العمال وتعديل بياناتهم',
      'Liste des ouvriers',
      'Workers list'
    ],
    'no_workers': [
      'لا يوجد عمال مضافون',
      'Aucun ouvrier',
      'No workers'
    ],
    'edit_worker': [
      'تعديل بيانات العامل',
      "Modifier l'ouvrier",
      'Edit worker'
    ],
    'worker_name': ['اسم العامل', "Nom de l'ouvrier", 'Worker name'],
    'phone_number': ['رقم الهاتف', 'Téléphone', 'Phone number'],
    'save_edits': [
      'حفظ التعديلات',
      'Enregistrer les modifications',
      'Save changes'
    ],
    'weekly_title': [
      'ملخص الأسبوع والرواتب',
      'Résumé hebdomadaire et salaires',
      'Weekly summary & wages'
    ],
    'no_data': [
      'لا توجد بيانات لعرض الملخص',
      'Aucune donnée à afficher',
      'No data to display'
    ],
    'week': ['الأسبوع', 'Semaine', 'Week'],
    'joint_report': [
      'التقرير المشترك لجميع العمال',
      'Rapport commun de tous les ouvriers',
      'Combined report for all workers'
    ],
    'joint_sub': [
      'من الأحد إلى السبت',
      'Du dimanche au samedi',
      'Sunday to Saturday'
    ],
    'total_word': ['المجموع', 'Total', 'Total'],
    'per_worker': [
      'تقرير كل عامل على حدة',
      'Rapport par ouvrier',
      'Report per worker'
    ],
    'work_days': ['أيام العمل', 'Jours travaillés', 'Days worked'],
    'worker_col': ['العامل', 'Ouvrier', 'Worker'],
    'grand_total': [
      'المجموع الكلي لجميع العمال',
      'Total général de tous les ouvriers',
      'Grand total of all workers'
    ],
    'worker_report': [
      'تقرير العامل',
      "Rapport de l'ouvrier",
      'Worker report'
    ],
    'all_report': [
      'التقرير الأسبوعي لجميع العمال',
      'Rapport hebdomadaire de tous les ouvriers',
      'Weekly report for all workers'
    ],
    'not_logged': [
      'لم يُسجَّل (اضغط للتعديل)',
      'Non renseigné (appuyer pour modifier)',
      'Not recorded (tap to edit)'
    ],
    'holiday': ['عطلة', 'Repos', 'Day off'],
    'overtime_short': ['إضافي', 'Heures supp.', 'Overtime'],
    'transport_short': ['نقل', 'Transport', 'Transport'],
    'hour_short': ['س', 'h', 'h'],
    'delete_day': ['مسح اليوم', 'Effacer le jour', 'Clear day'],
    'sum_days': [
      'مجموع اليوميات',
      'Total des journées',
      'Total daily wages'
    ],
    'sum_overtime': [
      'مجموع الإضافي',
      'Total heures supp.',
      'Total overtime'
    ],
    'sum_transport': [
      'مجموع المواصلات',
      'Total transport',
      'Total transport'
    ],
    'weekly_total': [
      'المجموع الأسبوعي',
      'Total de la semaine',
      'Weekly total'
    ],
    'amount': ['المبلغ', 'Montant', 'Amount'],
    'day_col': ['اليوم', 'Jour', 'Day'],
    'pdf_tip': [
      'تنزيل ومشاركة PDF',
      'Télécharger / partager PDF',
      'Download / share PDF'
    ],
    'share_tip': [
      'مشاركة كنص (واتساب)',
      'Partager en texte (WhatsApp)',
      'Share as text (WhatsApp)'
    ],
    'currency': ['العملة', 'Devise', 'Currency'],
    'change_currency': ['تغيير العملة', 'Changer la devise', 'Change currency'],
    'custom_currency': ['عملة مخصصة', 'Devise personnalisée', 'Custom currency'],
    'enter_custom_currency': ['أدخل رمز العملة', 'Entrez la devise', 'Enter currency'],
    'edit_overtime_rate': [
      'تعديل سعر ساعة الإضافي',
      'Modifier taux heure supp.',
      'Edit overtime hourly rate'
    ],
    'overtime_rate_hint': [
      'سعر ساعة العمل الإضافي الافتراضي',
      'Taux horaire par défaut',
      'Default overtime hourly rate'
    ],
    'backup_menu': [
      'النسخ الاحتياطي للبيانات',
      'Sauvegarde des données',
      'Data backup & restore'
    ],
    'export_backup': [
      'تصدير نسخة احتياطية (مشاركة/حفظ)',
      'Exporter une sauvegarde',
      'Export backup'
    ],
    'import_backup': [
      'استعادة نسخة احتياطية (لصق كود)',
      'Restaurer une sauvegarde',
      'Import backup'
    ],
    'paste_json': [
      'الصق نص النسخة الاحتياطية هنا:',
      'Collez le code de sauvegarde ici :',
      'Paste backup JSON here:'
    ],
    'restore_done': [
      'تمت استعادة البيانات بنجاح!',
      'Données restaurées avec succès !',
      'Data restored successfully!'
    ],
    'restore_err': [
      'فشلت الاستعادة: البيانات غير صالحة',
      'Échec : données invalides',
      'Restore failed: Invalid data'
    ],
    'pdf_font_err': [
      'تنبيه: تعذّر تحميل الخط العربي عبر الإنترنت. لطباعة PDF بدون إنترنت وبدون مربعات، يُرجى تضمين الخط محلياً في assets وتفعيل إذن الإنترنت.',
      'Police arabe indisponible. Pour fonctionner hors ligne, intégrez la police dans assets.',
      'Arabic font unavailable offline. Please bundle Cairo font in assets.'
    ],
    'select_site_hint': [
      'اختر ورشة لعرض تحليلها الكامل',
      'Sélectionnez un chantier',
      'Select a site to view analysis'
    ],
    'site_kpi_contract': ['قيمة العقد', 'Contrat', 'Contract total'],
    'site_kpi_received': ['المقبوض (الواصل)', 'Encaissé', 'Received'],
    'site_kpi_remaining': ['المتبقي للتحصيل', 'Reste à percevoir', 'Remaining'],
    'site_kpi_cost': ['تكلفة العمال والمصاريف', 'Coût total main-d’œuvre', 'Labor cost'],
    'site_kpi_net_profit': ['صافي الربح المتوقع', 'Bénéfice net prévu', 'Expected net profit'],
    'site_kpi_real_profit': ['صافي الربح الفعلي الحالي', 'Bénéfice réel actuel', 'Current real profit'],
    'site_workers_count': ['العمال في الورشة', 'Ouvriers sur chantier', 'Workers on site'],
    'site_total_days': ['إجمالي أيام العمل', 'Total jours travaillés', 'Total man-days'],
    'site_total_ot': ['ساعات الإضافي', 'Heures supp. totales', 'Total overtime hours'],
    'site_total_transport': ['مصاريف النقل', 'Total transport', 'Total transport'],
    'site_worker_breakdown': ['تفاصيل عمال هذه الورشة', 'Détail par ouvrier', 'Workers breakdown'],
    'worker_site_earnings': ['إجمالي ما تقاضاه', 'Total perçu', 'Total earnings'],
    'clear_logs': ['مسح السجل', 'Effacer l’historique', 'Clear logs'],
    'clear_logs_confirm': ['هل أنت متأكد من مسح سجل الحركات بالكامل؟', 'Voulez-vous effacer tout le journal ?', 'Are you sure you want to clear all logs?'],
    'filter_all': ['الكل', 'Tous', 'All'],
    'filter_payments': ['الدفعات', 'Paiements', 'Payments'],
    'filter_sites': ['الورش', 'Chantiers', 'Sites'],
    'filter_workers': ['العمال', 'Ouvriers', 'Workers'],
    'filter_attendance': ['الحضور', 'Présence', 'Attendance'],
    'filter_pdf': ['تقارير PDF', 'Rapports PDF', 'PDF reports'],
    'filter_backup': ['النسخ الاحتياطي', 'Sauvegardes', 'Backups'],
    'no_logs_found': ['لا توجد نشاطات مسجلة حالياً', 'Aucune activité enregistrée', 'No activities recorded yet'],
  };
}

String t(String key) => L10n.t(key);

// ======================= دوال مساعدة =======================

const String kLrm = '\u200E';
const String kNbsp = '\u00A0';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime weekStartOf(DateTime d) {
  final day = dateOnly(d);
  return DateTime(day.year, day.month, day.day - (day.weekday % 7));
}

String ltr(String s) => '$kLrm$s$kLrm';

String _grouped(double v) {
  final s = v.round().abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(kNbsp);
    buf.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}${buf.toString()}';
}

String numStr(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

String fmtMoney(double v) => ltr(_grouped(v));
String fmtCurrency(double v) => ltr('${_grouped(v)}${kNbsp}${AppDatabase.currency}');
String fmtXof(double v) => fmtCurrency(v);
String fmtNum(double v) => ltr(numStr(v));
String fmtDate(DateTime d) => ltr('${d.day}/${d.month}');
String fmtFullDate(DateTime d) => ltr('${d.day}/${d.month}/${d.year}');

// تنسيق التاريخ والوقت بالثانية للسجل
String fmtFullDateTime(DateTime d) {
  final y = d.year.toString();
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  final ss = d.second.toString().padLeft(2, '0');
  return ltr('$day/$m/$y - $hh:$mm:$ss');
}

String plain(String s) => s.replaceAll(kLrm, '').replaceAll(kNbsp, ' ');

bool hasArabic(String text) {
  return RegExp(
          r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]')
      .hasMatch(text);
}

// ======================= النماذج =======================

// سجل الحركات والنشاطات الدقيق بالثانية
class ActivityLog {
  String id;
  String category; // 'payments', 'sites', 'workers', 'attendance', 'pdf', 'backup'
  String title;
  String details;
  DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.category,
    required this.title,
    required this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'details': details,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
        id: (json['id'] ?? '').toString(),
        category: (json['category'] ?? 'all').toString(),
        title: (json['title'] ?? '').toString(),
        details: (json['details'] ?? '').toString(),
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}

class DayLog {
  bool worked;
  String site;
  double overtimeHours;
  double transport;
  String note;

  DayLog({
    this.worked = true,
    this.site = '',
    this.overtimeHours = 0.0,
    this.transport = 0.0,
    this.note = '',
  });

  double total(double dailyRate) => worked
      ? dailyRate + overtimeHours * AppDatabase.overtimeRate + transport
      : 0.0;

  Map<String, dynamic> toJson() => {
        'worked': worked,
        'site': site,
        'overtimeHours': overtimeHours,
        'transport': transport,
        'note': note,
      };

  factory DayLog.fromJson(Map<String, dynamic> json) => DayLog(
        worked: json['worked'] ?? true,
        site: (json['site'] ?? '').toString(),
        overtimeHours: ((json['overtimeHours'] ?? 0.0) as num).toDouble(),
        transport: ((json['transport'] ?? 0.0) as num).toDouble(),
        note: (json['note'] ?? '').toString(),
      );
}

class Worker {
  String id;
  String name;
  double dailyRate;
  String phone;
  bool isArchived;
  Map<String, DayLog> logs;

  Worker({
    required this.id,
    required this.name,
    required this.dailyRate,
    this.phone = '',
    this.isArchived = false,
    Map<String, DayLog>? logs,
  }) : logs = logs ?? {};

  DayLog? logFor(DateTime d) => logs[dateKey(d)];

  List<DayLog?> weekLogs(DateTime weekStart) =>
      List.generate(7, (i) => logs[dateKey(addDays(weekStart, i))]);

  double weekTotal(DateTime weekStart) => weekLogs(weekStart)
      .fold<double>(0.0, (s, l) => s + (l?.total(dailyRate) ?? 0.0));

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dailyRate': dailyRate,
        'phone': phone,
        'isArchived': isArchived,
        'logs': logs.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory Worker.fromJson(Map<String, dynamic> json) {
    final logs = <String, DayLog>{};
    final raw = json['logs'];
    if (raw is Map) {
      raw.forEach((k, v) {
        logs[k.toString()] = DayLog.fromJson(Map<String, dynamic>.from(v));
      });
    }
    return Worker(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      dailyRate: ((json['dailyRate'] ?? 0.0) as num).toDouble(),
      phone: (json['phone'] ?? '').toString(),
      isArchived: json['isArchived'] ?? false,
      logs: logs,
    );
  }
}

class WorkSite {
  String id;
  String name;
  String location;
  double totalContractAmount;
  double totalPaid;
  bool isDelivered;
  String deliveryNote;

  WorkSite({
    required this.id,
    required this.name,
    required this.location,
    required this.totalContractAmount,
    this.totalPaid = 0.0,
    this.isDelivered = false,
    this.deliveryNote = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'totalContractAmount': totalContractAmount,
        'totalPaid': totalPaid,
        'isDelivered': isDelivered,
        'deliveryNote': deliveryNote,
      };

  factory WorkSite.fromJson(Map<String, dynamic> json) => WorkSite(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        location: (json['location'] ?? '').toString(),
        totalContractAmount:
            ((json['totalContractAmount'] ?? 0.0) as num).toDouble(),
        totalPaid: ((json['totalPaid'] ?? 0.0) as num).toDouble(),
        isDelivered: json['isDelivered'] ?? false,
        deliveryNote: (json['deliveryNote'] ?? '').toString(),
      );
}

// ======================= قاعدة البيانات =======================

class AppDatabase {
  static List<Worker> workers = [];
  static List<WorkSite> sites = [];
  static List<ActivityLog> logs = [];
  static String lastPopupDate = '';
  static String? lastError;

  static ValueNotifier<String> currencyNotifier = ValueNotifier<String>('XOF');
  static String get currency => currencyNotifier.value;
  static set currency(String v) => currencyNotifier.value = v;

  static ValueNotifier<double> overtimeRateNotifier =
      ValueNotifier<double>(1000.0);
  static double get overtimeRate => overtimeRateNotifier.value;
  static set overtimeRate(double v) => overtimeRateNotifier.value = v;

  static List<Worker> get activeWorkers =>
      workers.where((w) => !w.isArchived).toList();

  static List<Worker> get archivedWorkers =>
      workers.where((w) => w.isArchived).toList();

  static List<Worker> workersForWeek(DateTime ws) {
    return workers.where((w) {
      if (!w.isArchived) return true;
      final logs = w.weekLogs(ws);
      return logs.any((l) => l != null);
    }).toList();
  }

  // إضافة حركة لسجل النشاطات تلقائياً وحفظها بالثانية
  static void logActivity(String category, String title, String details) {
    final entry = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      title: title,
      details: details,
      timestamp: DateTime.now(),
    );
    logs.insert(0, entry);
    if (logs.length > 500) logs.removeLast();
    saveLogsOnly();
  }

  static Future<void> saveLogsOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'activity_logs', jsonEncode(logs.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  static Future<void> clearAllLogs() async {
    logs.clear();
    await saveLogsOnly();
  }

  static Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final workersStr = prefs.getString('workers_data');
      final sitesStr = prefs.getString('sites_data');
      final logsStr = prefs.getString('activity_logs');
      lastPopupDate = prefs.getString('last_popup_date') ?? '';
      final savedLang = prefs.getString('app_lang');
      if (savedLang != null && L10n.codes.contains(savedLang)) {
        L10n.lang = savedLang;
      }

      final savedCurrency = prefs.getString('app_currency');
      if (savedCurrency != null && savedCurrency.trim().isNotEmpty) {
        currency = savedCurrency.trim();
      }

      final savedOt = prefs.getDouble('app_overtime_rate');
      if (savedOt != null && savedOt >= 0) {
        overtimeRate = savedOt;
      }

      if (workersStr != null) {
        final List decoded = jsonDecode(workersStr);
        workers = decoded
            .map((e) => Worker.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (sitesStr != null) {
        final List decoded = jsonDecode(sitesStr);
        sites = decoded
            .map((e) => WorkSite.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (logsStr != null) {
        final List decoded = jsonDecode(logsStr);
        logs = decoded
            .map((e) => ActivityLog.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      lastError = 'Load error: $e';
    }
  }

  static Future<bool> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok1 = await prefs.setString(
          'workers_data', jsonEncode(workers.map((e) => e.toJson()).toList()));
      final ok2 = await prefs.setString(
          'sites_data', jsonEncode(sites.map((e) => e.toJson()).toList()));
      final ok3 = await prefs.setString('last_popup_date', lastPopupDate);
      await prefs.setString(
          'activity_logs', jsonEncode(logs.map((e) => e.toJson()).toList()));
      await prefs.setString('app_currency', currency);
      await prefs.setDouble('app_overtime_rate', overtimeRate);

      if (!(ok1 && ok2 && ok3)) {
        lastError = 'Save failed';
      } else {
        lastError = null;
      }
      return ok1 && ok2 && ok3;
    } catch (e) {
      lastError = 'Save error: $e';
      return false;
    }
  }

  static Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_currency', currency);
      await prefs.setDouble('app_overtime_rate', overtimeRate);
    } catch (e) {
      lastError = 'Settings save error: $e';
    }
  }

  static Future<void> saveLang() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_lang', L10n.lang);
    } catch (e) {
      lastError = 'Save error: $e';
    }
  }

  static bool shouldShowDailyPopup() {
    return activeWorkers.isNotEmpty && lastPopupDate != dateKey(DateTime.now());
  }

  static Future<void> markPopupShown() async {
    lastPopupDate = dateKey(DateTime.now());
    await saveData();
  }

  static DayLog ensureLog(Worker w, DateTime day) {
    final key = dateKey(day);
    final existing = w.logs[key];
    if (existing != null) return existing;
    final active = sites.where((s) => !s.isDelivered).toList();
    final log = DayLog(site: active.isNotEmpty ? active.first.name : '');
    w.logs[key] = log;
    return log;
  }

  static String exportBackupJson() {
    final data = {
      'version': '1.2',
      'currency': currency,
      'overtimeRate': overtimeRate,
      'workers': workers.map((w) => w.toJson()).toList(),
      'sites': sites.map((s) => s.toJson()).toList(),
      'logs': logs.map((l) => l.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  static Future<bool> importBackupJson(String jsonStr) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      if (data.containsKey('currency')) {
        currency = data['currency'].toString();
      }
      if (data.containsKey('overtimeRate')) {
        overtimeRate = ((data['overtimeRate'] ?? 1000.0) as num).toDouble();
      }
      if (data.containsKey('workers') && data['workers'] is List) {
        workers = (data['workers'] as List)
            .map((e) => Worker.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (data.containsKey('sites') && data['sites'] is List) {
        sites = (data['sites'] as List)
            .map((e) => WorkSite.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (data.containsKey('logs') && data['logs'] is List) {
        logs = (data['logs'] as List)
            .map((e) => ActivityLog.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      final ok = await saveData();
      if (ok) {
        logActivity('backup', 'استعادة نسخة احتياطية',
            'تمت استعادة البيانات بنجاح من كود النسخة الاحتياطية');
      }
      return ok;
    } catch (e) {
      lastError = 'Import error: $e';
      return false;
    }
  }
}


// ======================= النوافذ المساعدة =======================

Future<void> showLanguageDialog(
    BuildContext context, VoidCallback onChanged) async {
  final code = await showDialog<String>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(t('language')),
      children: [
        for (final c in L10n.codes)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, c),
            child: Row(
              children: [
                Icon(
                    c == L10n.lang
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: Colors.indigo),
                const SizedBox(width: 12),
                Text(L10n.names[c]!, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
      ],
    ),
  );
  if (code != null && code != L10n.lang) {
    L10n.lang = code;
    await AppDatabase.saveLang();
    onChanged();
  }
}

Future<String?> pickReportLang(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(t('report_lang')),
      children: [
        for (final c in L10n.codes)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, c),
            child: Row(
              children: [
                const Icon(Icons.description, color: Colors.indigo),
                const SizedBox(width: 12),
                Text(L10n.names[c]!,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: c == L10n.lang
                            ? FontWeight.bold
                            : FontWeight.normal)),
              ],
            ),
          ),
      ],
    ),
  );
}

Future<void> showCurrencyDialog(
    BuildContext context, VoidCallback onChanged) async {
  final List<String> commonCurrencies = [
    'XOF', 'SAR', 'AED', 'USD', 'EUR', 'DZD', 'MAD', 'EGP', 'TND', 'IQD', 'KWD', 'QAR', 'OMR', 'BHD', 'JOD', 'LBP', 'LYD'
  ];
  final customController = TextEditingController();
  final otController =
      TextEditingController(text: numStr(AppDatabase.overtimeRate));

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setD) => AlertDialog(
        title: Text(t('change_currency')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t('currency')}: ${AppDatabase.currency}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: commonCurrencies.map((c) {
                  final isSelected = c == AppDatabase.currency;
                  return ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    selectedColor: Colors.indigo.shade100,
                    onSelected: (val) {
                      if (val) {
                        setD(() {
                          AppDatabase.currency = c;
                          customController.text = c;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: customController,
                decoration: InputDecoration(
                  labelText: t('custom_currency'),
                  hintText: t('enter_custom_currency'),
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onChanged: (val) {
                  if (val.trim().isNotEmpty) {
                    AppDatabase.currency = val.trim();
                  }
                },
              ),
              const Divider(height: 24),
              TextField(
                controller: otController,
                decoration: InputDecoration(
                  labelText:
                      '${t('edit_overtime_rate')} (${AppDatabase.currency})',
                  helperText: t('overtime_rate_hint'),
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed >= 0) {
                    AppDatabase.overtimeRate = parsed;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () async {
              if (customController.text.trim().isNotEmpty) {
                AppDatabase.currency = customController.text.trim();
              }
              final parsedOt = double.tryParse(otController.text);
              if (parsedOt != null && parsedOt >= 0) {
                AppDatabase.overtimeRate = parsedOt;
              }
              await AppDatabase.saveSettings();
              Navigator.pop(ctx);
              onChanged();
            },
            child: Text(t('save'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

Future<void> showBackupDialog(
    BuildContext context, VoidCallback onDataUpdated) async {
  final importController = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t('backup_menu')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.share, color: Colors.white),
              label: Text(t('export_backup'),
                  style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () async {
                final jsonStr = AppDatabase.exportBackupJson();
                await Share.share(jsonStr,
                    subject: 'WookFlow Backup ${dateKey(DateTime.now())}');
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(t('import_backup'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: importController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: t('paste_json'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.download, color: Colors.white),
              label: Text(t('confirm'),
                  style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final ok =
                    await AppDatabase.importBackupJson(importController.text);
                Navigator.pop(ctx);
                if (ok) {
                  onDataUpdated();
                  messenger.showSnackBar(
                      SnackBar(content: Text(t('restore_done'))));
                } else {
                  messenger.showSnackBar(
                      SnackBar(content: Text(t('restore_err'))));
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: Text(t('cancel'))),
      ],
    ),
  );
}

// ======================= التشغيل =======================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.loadData();
  runApp(const WookFlowApp());
}

class WookFlowApp extends StatelessWidget {
  const WookFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: L10n.notifier,
      builder: (context, lang, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WookFlow',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF4F6F9),
          ),
          builder: (context, child) => Directionality(
            textDirection:
                lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const MainDashboardWrapper(),
        );
      },
    );
  }
}

// ======================= الواجهة الرئيسية =======================

class MainDashboardWrapper extends StatefulWidget {
  const MainDashboardWrapper({super.key});

  @override
  State<MainDashboardWrapper> createState() => _MainDashboardWrapperState();
}

class _MainDashboardWrapperState extends State<MainDashboardWrapper> {
  bool _showDailyPopup = false;

  @override
  void initState() {
    super.initState();
    _showDailyPopup = AppDatabase.shouldShowDailyPopup();
  }

  Future<void> _closePopup() async {
    await AppDatabase.saveData();
    await AppDatabase.markPopupShown();
    if (mounted) setState(() => _showDailyPopup = false);
  }

  void _openPopup() {
    if (AppDatabase.activeWorkers.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('add_workers_first'))));
      return;
    }
    setState(() => _showDailyPopup = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MainDashboard(
            onDataUpdated: () => setState(() {}),
            onOpenDailyReport: _openPopup,
          ),
          if (_showDailyPopup && AppDatabase.activeWorkers.isNotEmpty)
            DailyReportPopup(onClose: _closePopup),
          if (AppDatabase.lastError != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(AppDatabase.lastError!,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ======================= نافذة التقرير اليومي =======================

class DailyReportPopup extends StatefulWidget {
  final Future<void> Function() onClose;
  const DailyReportPopup({super.key, required this.onClose});

  @override
  State<DailyReportPopup> createState() => _DailyReportPopupState();
}

class _DailyReportPopupState extends State<DailyReportPopup> {
  final DateTime _today = dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    for (final w in AppDatabase.activeWorkers) {
      AppDatabase.ensureLog(w, _today);
    }
  }

  Widget _workerCard(Worker worker) {
    final log = AppDatabase.ensureLog(worker, _today);
    final activeSites = AppDatabase.sites.where((s) => !s.isDelivered).toList();
    if (activeSites.isNotEmpty && !activeSites.any((s) => s.name == log.site)) {
      log.site = activeSites.first.name;
    }
    final String? siteValue =
        activeSites.any((s) => s.name == log.site) ? log.site : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(worker.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Text(t('works')),
                Switch(
                  value: log.worked,
                  onChanged: (val) {
                    setState(() => log.worked = val);
                    AppDatabase.saveData();
                    AppDatabase.logActivity('attendance', 'حضور عامل',
                        '${worker.name}: ${val ? "حاضر" : "عطلة"}');
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: t('site')),
                    isEmpty: siteValue == null,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: siteValue,
                        items: activeSites
                            .map((s) => DropdownMenuItem(
                                value: s.name, child: Text(s.name)))
                            .toList(),
                        onChanged: log.worked
                            ? (val) {
                                setState(() => log.site = val ?? '');
                                AppDatabase.saveData();
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('${worker.id}-ot'),
                    initialValue:
                        log.overtimeHours == 0 ? '' : numStr(log.overtimeHours),
                    enabled: log.worked,
                    decoration: InputDecoration(labelText: t('overtime')),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() =>
                          log.overtimeHours = double.tryParse(val) ?? 0.0);
                      AppDatabase.saveData();
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('${worker.id}-tr'),
                    initialValue:
                        log.transport == 0 ? '' : numStr(log.transport),
                    enabled: log.worked,
                    decoration: InputDecoration(
                        labelText: '${t('transport')} (${AppDatabase.currency})'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(
                          () => log.transport = double.tryParse(val) ?? 0.0);
                      AppDatabase.saveData();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('${worker.id}-note'),
                    initialValue: log.note,
                    enabled: log.worked,
                    decoration: InputDecoration(labelText: t('note')),
                    onChanged: (val) {
                      log.note = val;
                      AppDatabase.saveData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${t('day_total')}: ${fmtCurrency(log.total(worker.dailyRate))}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayName = L10n.day(_today.weekday % 7);
    final currentActiveWorkers = AppDatabase.activeWorkers;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                          '${t('daily_title')} - $dayName ${fmtDate(_today)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currentActiveWorkers.length,
                  itemBuilder: (context, index) =>
                      _workerCard(currentActiveWorkers[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      minimumSize: const Size(double.infinity, 50)),
                  onPressed: widget.onClose,
                  child: Text(t('save_close'),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= لوحة التحكم =======================

class MainDashboard extends StatelessWidget {
  final VoidCallback onDataUpdated;
  final VoidCallback onOpenDailyReport;
  const MainDashboard(
      {super.key,
      required this.onDataUpdated,
      required this.onOpenDailyReport});

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final workingToday = AppDatabase.activeWorkers
        .where((w) => w.logFor(today)?.worked ?? false)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('app_title'),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: t('language'),
            onPressed: () => showLanguageDialog(context, onDataUpdated),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(t('manager')),
              accountEmail: Text(t('version')),
              currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child:
                      Icon(Icons.engineering, size: 40, color: Colors.indigo)),
              decoration: const BoxDecoration(color: Colors.indigo),
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: Text(t('m_daily')),
              onTap: () {
                Navigator.pop(context);
                onOpenDailyReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(t('m_add_worker')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddWorkerScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: Text(t('m_delete_worker')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageWorkersScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(t('m_sites')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SitesScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt),
              title: Text(t('m_delivered')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DeliveredSitesScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.indigo),
              title: Text(t('m_site_analytics')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SiteAnalyticsScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: Text(t('m_payment')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewPaymentScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: Text(t('m_workers')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WorkersListScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: Text(t('m_weekly')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WeeklySummaryScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.deepOrange),
              title: Text(t('m_activity_log')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ActivityLogScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.currency_exchange, color: Colors.indigo),
              title: Text('${t('currency')}: ${AppDatabase.currency}'),
              subtitle: Text('${t('card_hour_rate')}: ${fmtCurrency(AppDatabase.overtimeRate)}'),
              onTap: () {
                Navigator.pop(context);
                showCurrencyDialog(context, onDataUpdated);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_sync, color: Colors.teal),
              title: Text(t('backup_menu')),
              onTap: () {
                Navigator.pop(context);
                showBackupDialog(context, onDataUpdated);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text('${t('language')}: ${L10n.names[L10n.lang]}'),
              onTap: () {
                Navigator.pop(context);
                showLanguageDialog(context, onDataUpdated);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  minimumSize: const Size(double.infinity, 56)),
              onPressed: onOpenDailyReport,
              icon: const Icon(Icons.today, color: Colors.white),
              label: Text(t('daily_btn'),
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  _buildDashboardCard(context, t('card_workers_today'),
                      ltr('$workingToday'), Icons.people, Colors.blue,
                      onTap: onOpenDailyReport),
                  _buildDashboardCard(
                      context,
                      t('card_active_sites'),
                      ltr('${AppDatabase.sites.where((s) => !s.isDelivered).length}'),
                      Icons.apartment,
                      Colors.orange,
                      onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SitesScreen()));
                    onDataUpdated();
                  }),
                  _buildDashboardCard(
                      context,
                      t('card_delivered_sites'),
                      ltr('${AppDatabase.sites.where((s) => s.isDelivered).length}'),
                      Icons.task_alt,
                      Colors.teal,
                      onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DeliveredSitesScreen()));
                    onDataUpdated();
                  }),
                  _buildDashboardCard(
                      context,
                      t('m_site_analytics'),
                      t('view_reports'),
                      Icons.analytics,
                      Colors.deepPurple,
                      onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SiteAnalyticsScreen()));
                    onDataUpdated();
                  }),
                  _buildDashboardCard(
                      context,
                      t('m_payment'),
                      t('card_payments_manage'),
                      Icons.payments,
                      Colors.indigo,
                      onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NewPaymentScreen()));
                    onDataUpdated();
                  }),
                  _buildDashboardCard(context, t('card_hour_rate'),
                      fmtCurrency(AppDatabase.overtimeRate), Icons.schedule, Colors.green,
                      onTap: () => showCurrencyDialog(context, onDataUpdated)),
                  _buildDashboardCard(context, t('card_weekly'),
                      t('view_reports'), Icons.bar_chart, Colors.purple,
                      onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WeeklySummaryScreen()));
                    onDataUpdated();
                  }),
                  _buildDashboardCard(context, t('m_activity_log'),
                      '${AppDatabase.logs.length}', Icons.history, Colors.blueGrey,
                      onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ActivityLogScreen()));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String value,
      IconData icon, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 6),
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= إضافة وإدارة العمال =======================

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rateController =
      TextEditingController(text: '0');
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(t('add_worker_title')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: t('worker_name_req')),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? t('enter_name')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateController,
                decoration: InputDecoration(
                    labelText: '${t('rate_req')} (${AppDatabase.currency})'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? t('enter_rate')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: t('phone_opt')),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    minimumSize: const Size(double.infinity, 50)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final workerName = _nameController.text.trim();
                    final rate = double.tryParse(_rateController.text) ?? 0.0;
                    AppDatabase.workers.add(Worker(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: workerName,
                      dailyRate: rate,
                      phone: _phoneController.text.trim(),
                      isArchived: false,
                    ));
                    AppDatabase.logActivity('workers', 'إضافة عامل جديد',
                        'تمت إضافة العامل $workerName بيومية ${fmtCurrency(rate)}');
                    final ok = await AppDatabase.saveData();
                    navigator.pop();
                    messenger.showSnackBar(SnackBar(
                        content: Text(ok
                            ? t('worker_saved')
                            : '${t('save_failed')}: ${AppDatabase.lastError}')));
                  }
                },
                child: Text(t('save_worker'),
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شاشة إدارة وأرشفة العمال مع الزر المصغر والأنيق
class ManageWorkersScreen extends StatefulWidget {
  const ManageWorkersScreen({super.key});

  @override
  State<ManageWorkersScreen> createState() => _ManageWorkersScreenState();
}

class _ManageWorkersScreenState extends State<ManageWorkersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _archiveWorker(Worker worker) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      worker.isArchived = true;
    });
    AppDatabase.logActivity('workers', 'أرشفة عامل',
        'تمت أرشفة العامل ${worker.name} مع الحفاظ على سجلاته');
    await AppDatabase.saveData();
    messenger.showSnackBar(SnackBar(content: Text(t('archive_success'))));
  }

  void _restoreWorker(Worker worker) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      worker.isArchived = false;
    });
    AppDatabase.logActivity('workers', 'استعادة عامل',
        'تمت استعادة وتفعيل العامل ${worker.name}');
    await AppDatabase.saveData();
    messenger.showSnackBar(SnackBar(content: Text(t('restore_success'))));
  }

  void _permanentDeleteWorker(Worker worker) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete_confirm_title')),
        content: Text(t('delete_confirm_body')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('confirm'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final messenger = ScaffoldMessenger.of(context);
      setState(() {
        AppDatabase.workers.removeWhere((w) => w.id == worker.id);
      });
      AppDatabase.logActivity('workers', 'حذف عامل نهائياً',
          'تم الحذف النهائي للعامل ${worker.name}');
      await AppDatabase.saveData();
      messenger
          .showSnackBar(SnackBar(content: Text(t('permanent_delete_success'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = AppDatabase.activeWorkers;
    final archived = AppDatabase.archivedWorkers;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('manage_workers_title')),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: [
            Tab(text: '${t('active_tab')} (${active.length})'),
            Tab(text: '${t('archived_tab')} (${archived.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          active.isEmpty
              ? Center(child: Text(t('no_active_workers')))
              : ListView.builder(
                  itemCount: active.length,
                  itemBuilder: (context, index) {
                    final worker = active[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(worker.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${t('daily_wage')}: ${fmtCurrency(worker.dailyRate)} | ${t('phone')}: ${ltr(worker.phone)}'),
                        trailing: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact),
                          icon: const Icon(Icons.archive, size: 16),
                          label: Text(t('archive_btn')),
                          onPressed: () => _archiveWorker(worker),
                        ),
                      ),
                    );
                  },
                ),
          archived.isEmpty
              ? Center(child: Text(t('no_archived_workers')))
              : ListView.builder(
                  itemCount: archived.length,
                  itemBuilder: (context, index) {
                    final worker = archived[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      color: Colors.grey.shade100,
                      child: ListTile(
                        title: Text(worker.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey)),
                        subtitle: Text(
                            '${t('daily_wage')}: ${fmtCurrency(worker.dailyRate)} | ${t('phone')}: ${ltr(worker.phone)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  visualDensity: VisualDensity.compact),
                              icon: const Icon(Icons.unarchive, size: 16),
                              label: Text(t('restore_btn')),
                              onPressed: () => _restoreWorker(worker),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete_forever, color: Colors.red),
                              tooltip: t('permanent_delete_btn'),
                              onPressed: () =>
                                  _permanentDeleteWorker(worker),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

// ======================= الورش =======================

class SitesScreen extends StatefulWidget {
  const SitesScreen({super.key});

  @override
  State<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showAddSiteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t('add_site_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: t('site_name'))),
            TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: t('site_address'))),
            TextField(
                controller: _amountController,
                decoration: InputDecoration(
                    labelText:
                        '${t('site_total')} (${AppDatabase.currency})'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                final sName = _nameController.text.trim();
                final amt = double.tryParse(_amountController.text) ?? 0.0;
                AppDatabase.sites.add(WorkSite(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: sName,
                  location: _locationController.text.trim(),
                  totalContractAmount: amt,
                ));
                AppDatabase.logActivity('sites', 'إضافة موقع عمل جديد',
                    'تم إنشاء ورشة $sName بمبلغ إجمالي ${fmtCurrency(amt)}');
                _nameController.clear();
                _locationController.clear();
                _amountController.clear();
                Navigator.pop(dialogContext);
                setState(() {});
                await AppDatabase.saveData();
                if (mounted) setState(() {});
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  // تعديل الورشة مع إمكانية إضافة مبالغ إضافية مع ذكر السبب
  void _showEditSiteDialog(WorkSite site) {
    final nameCtrl = TextEditingController(text: site.name);
    final locCtrl = TextEditingController(text: site.location);
    final extraAmtCtrl = TextEditingController();
    final extraReasonCtrl = TextEditingController();
    final totalCtrl =
        TextEditingController(text: numStr(site.totalContractAmount));

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(t('edit_site_title')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: t('site_name')),
                ),
                TextField(
                  controller: locCtrl,
                  decoration: InputDecoration(labelText: t('site_address')),
                ),
                TextField(
                  controller: totalCtrl,
                  decoration: InputDecoration(
                      labelText:
                          '${t('site_total')} (${AppDatabase.currency})'),
                  keyboardType: TextInputType.number,
                ),
                const Divider(height: 24),
                Text(t('add_extra_amount'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 6),
                TextField(
                  controller: extraAmtCtrl,
                  decoration: InputDecoration(
                    labelText:
                        '${t('extra_amount_val')} (${AppDatabase.currency})',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final extra = double.tryParse(val) ?? 0.0;
                    if (extra > 0) {
                      totalCtrl.text = numStr(site.totalContractAmount + extra);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: extraReasonCtrl,
                  decoration: InputDecoration(
                    labelText: t('extra_amount_reason'),
                    hintText: 'مثال: أعمال صبغ إضافية، تعديل في المخطط',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(t('cancel'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () async {
                final oldTotal = site.totalContractAmount;
                final newTotal =
                    double.tryParse(totalCtrl.text) ?? site.totalContractAmount;
                final extra = double.tryParse(extraAmtCtrl.text) ?? 0.0;
                final reason = extraReasonCtrl.text.trim();

                site.name = nameCtrl.text.trim();
                site.location = locCtrl.text.trim();
                site.totalContractAmount = newTotal;

                if (extra > 0) {
                  AppDatabase.logActivity('sites', 'زيادة مبلغ عقد الورشة',
                      'ورشة ${site.name}: إضافة ${fmtCurrency(extra)} - السبب: ${reason.isEmpty ? "أعمال إضافية" : reason}');
                } else if (newTotal != oldTotal) {
                  AppDatabase.logActivity('sites', 'تعديل قيمة العقد',
                      'ورشة ${site.name}: تعديل الإجمالي من ${fmtCurrency(oldTotal)} إلى ${fmtCurrency(newTotal)}');
                } else {
                  AppDatabase.logActivity('sites', 'تعديل بيانات ورشة',
                      'تم تعديل بيانات ورشة ${site.name}');
                }

                Navigator.pop(dialogCtx);
                setState(() {});
                await AppDatabase.saveData();
              },
              child: Text(t('save'),
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // تسليم الورشة مع التحقق الدقيق من تسكير الحساب أو الاستثناء
  void _handleDeliverSite(BuildContext context, WorkSite site) async {
    final remaining = site.totalContractAmount - site.totalPaid;
    final messenger = ScaffoldMessenger.of(context);

    if (remaining <= 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t('confirm_delivery_title')),
          content: Text('${t('confirm_delivery_paid_body')}\n(${site.name})'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(t('cancel'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  Text(t('confirm'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() {
          site.isDelivered = true;
          site.deliveryNote = t('paid_in_full_on_delivery');
        });
        AppDatabase.logActivity('sites', 'تسليم ورشة منتهية',
            'تم تسليم ورشة ${site.name} ونقلها للأرشيف (الحساب مسدد بالكامل)');
        await AppDatabase.saveData();
        messenger.showSnackBar(SnackBar(content: Text(t('delivered_msg'))));
      }
    } else {
      final noteController = TextEditingController();
      await showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (dialogCtx, setD) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(t('unsettled_delivery_title'),
                      style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t('site')}: ${site.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                      '${t('contract_total')}: ${fmtCurrency(site.totalContractAmount)}'),
                  Text('${t('received')}: ${fmtCurrency(site.totalPaid)}'),
                  Text(
                    '${t('remaining')}: ${fmtCurrency(remaining)}',
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Text(
                      t('unsettled_warning_note'),
                      style: TextStyle(
                          fontSize: 12, color: Colors.amber.shade900),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: t('exception_note_label'),
                      hintText: t('exception_note_hint'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(t('cancel')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  site.totalPaid = site.totalContractAmount;
                  site.isDelivered = true;
                  site.deliveryNote = t('paid_in_full_on_delivery');
                  AppDatabase.logActivity('sites', 'تسليم ورشة وسداد المتبقي',
                      'ورشة ${site.name}: سداد المتبقي ${fmtCurrency(remaining)} بالكامل وتسليمها للأرشيف');
                  Navigator.pop(dialogCtx);
                  setState(() {});
                  await AppDatabase.saveData();
                  messenger
                      .showSnackBar(SnackBar(content: Text(t('delivered_msg'))));
                },
                child: Text(t('pay_all_and_deliver'),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800),
                onPressed: () async {
                  if (noteController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t('exception_note_required'))),
                    );
                    return;
                  }
                  site.isDelivered = true;
                  site.deliveryNote = noteController.text.trim();
                  AppDatabase.logActivity('sites', 'تسليم ورشة باستثناء',
                      'ورشة ${site.name}: تسليم باستثناء ومتبقي غير مسدد ${fmtCurrency(remaining)} - السبب: ${site.deliveryNote}');
                  Navigator.pop(dialogCtx);
                  setState(() {});
                  await AppDatabase.saveData();
                  messenger
                      .showSnackBar(SnackBar(content: Text(t('delivered_msg'))));
                },
                child: Text(t('deliver_with_exception'),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
      );
    }
  }

  // حذف ورشة حالية من قائمة الورش النشطة
  void _deleteActiveSite(WorkSite site) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete_site_title')),
        content: Text('${t('delete_site_confirm_msg')}\n(${site.name})'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(t('confirm'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        AppDatabase.sites.removeWhere((s) => s.id == site.id);
      });
      AppDatabase.logActivity('sites', 'حذف ورشة',
          'تم حذف ورشة ${site.name} نهائياً');
      await AppDatabase.saveData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('site_deleted_msg'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSites = AppDatabase.sites.where((s) => !s.isDelivered).toList();

    return Scaffold(
      appBar: AppBar(
          title: Text(t('sites_title')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: activeSites.isEmpty
          ? Center(child: Text(t('no_active_sites')))
          : ListView.builder(
              itemCount: activeSites.length,
              itemBuilder: (context, index) {
                final site = activeSites[index];
                final remaining =
                    site.totalContractAmount - site.totalPaid;
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(site.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${t('site_address')}: ${site.location} | ${t('total')}: ${fmtCurrency(site.totalContractAmount)}\n${t('received')}: ${fmtCurrency(site.totalPaid)} | ${t('remaining')}: ${fmtCurrency(remaining)}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          tooltip: t('edit_site_title'),
                          onPressed: () => _showEditSiteDialog(site),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              visualDensity: VisualDensity.compact),
                          onPressed: () =>
                              _handleDeliverSite(context, site),
                          child: Text(t('deliver')),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          tooltip: t('delete_site_title'),
                          onPressed: () => _deleteActiveSite(site),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: _showAddSiteDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// قائمة الورش المسلمة مع خيار الحذف النهائي وزر إعادة الفتح
class DeliveredSitesScreen extends StatefulWidget {
  const DeliveredSitesScreen({super.key});

  @override
  State<DeliveredSitesScreen> createState() => _DeliveredSitesScreenState();
}

class _DeliveredSitesScreenState extends State<DeliveredSitesScreen> {
  void _reopenSite(WorkSite site) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('reopen_confirm_title')),
        content: Text('${t('reopen_confirm_msg')}\n(${site.name})'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(t('confirm'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        site.isDelivered = false;
        site.deliveryNote = '';
      });
      AppDatabase.logActivity('sites', 'إعادة فتح ورشة',
          'تمت إعادة فتح ورشة ${site.name} ونقلها إلى الورش النشطة');
      await AppDatabase.saveData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('site_reopened_msg'))),
        );
      }
    }
  }

  void _deleteDeliveredSite(WorkSite site) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete_delivered_site')),
        content:
            Text('${t('delete_delivered_confirm_msg')}\n(${site.name})'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(t('confirm'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        AppDatabase.sites.removeWhere((s) => s.id == site.id);
      });
      AppDatabase.logActivity('sites', 'حذف ورشة من الأرشيف',
          'تم حذف ورشة ${site.name} نهائياً من أرشيف الورش المسلمة');
      await AppDatabase.saveData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('site_deleted_msg'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveredSites =
        AppDatabase.sites.where((s) => s.isDelivered).toList();

    return Scaffold(
      appBar: AppBar(
          title: Text(t('delivered_title')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: deliveredSites.isEmpty
          ? Center(child: Text(t('no_delivered')))
          : ListView.builder(
              itemCount: deliveredSites.length,
              itemBuilder: (context, index) {
                final site = deliveredSites[index];
                final remaining =
                    site.totalContractAmount - site.totalPaid;
                return Card(
                  margin: const EdgeInsets.all(8),
                  color: Colors.grey.shade100,
                  child: ListTile(
                    title: Text(site.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough)),
                    subtitle: Text(
                        '${t('site_address')}: ${site.location} | ${t('contract_total')}: ${fmtCurrency(site.totalContractAmount)}\n'
                        '${t('received')}: ${fmtCurrency(site.totalPaid)}'
                        '${remaining > 0 ? " | ${t('remaining')}: ${fmtCurrency(remaining)}" : ""}'
                        ' (${t('delivered_flag')})'
                        '${site.deliveryNote.isNotEmpty ? "\n📌 ${t('delivery_note_prefix')}: ${site.deliveryNote}" : ""}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay, color: Colors.indigo),
                          tooltip: t('reopen_site'),
                          onPressed: () => _reopenSite(site),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete_forever, color: Colors.red),
                          tooltip: t('delete_delivered_site'),
                          onPressed: () => _deleteDeliveredSite(site),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ======================= إدارة الدفعات مع فحص المتبقي =======================

class NewPaymentScreen extends StatefulWidget {
  const NewPaymentScreen({super.key});

  @override
  State<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends State<NewPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    final activeSites = AppDatabase.sites.where((s) => !s.isDelivered).toList();

    return Scaffold(
      appBar: AppBar(
          title: Text(t('payments_title')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: activeSites.isEmpty
          ? Center(child: Text(t('no_sites_payment')))
          : ListView.builder(
              itemCount: activeSites.length,
              itemBuilder: (context, index) {
                final site = activeSites[index];
                final remaining = site.totalContractAmount - site.totalPaid;
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(site.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${t('total')}: ${fmtCurrency(site.totalContractAmount)}\n${t('received')}: ${fmtCurrency(site.totalPaid)}\n${t('remaining')}: ${fmtCurrency(remaining)}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.add_card, color: Colors.indigo),
                      onPressed: () => _showPaymentDialog(context, site),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showPaymentDialog(BuildContext context, WorkSite site) {
    final remaining = site.totalContractAmount - site.totalPaid;

    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('site_already_fully_paid'))),
      );
      return;
    }

    final paymentController = TextEditingController(text: numStr(remaining));
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text('${t('add_payment_for')} ${site.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t('contract_total')}: ${fmtCurrency(site.totalContractAmount)}'),
              Text('${t('payments_sum')}: ${fmtCurrency(site.totalPaid)}'),
              Text(
                  '${t('remaining')}: ${fmtCurrency(remaining)}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: paymentController,
                decoration: InputDecoration(
                  labelText: '${t('new_payment')} (${AppDatabase.currency})',
                  errorText: errorText,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final entered = double.tryParse(val) ?? 0.0;
                  if (entered > remaining) {
                    setD(() => errorText =
                        '${t('payment_exceeds_remaining')} (${fmtCurrency(remaining)})');
                  } else {
                    setD(() => errorText = null);
                  }
                },
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.flash_on, size: 16),
                  label: Text(t('pay_remaining_all')),
                  onPressed: () {
                    setD(() {
                      paymentController.text = numStr(remaining);
                      errorText = null;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(t('cancel'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () async {
                final payment = double.tryParse(paymentController.text) ?? 0.0;
                if (payment <= 0) {
                  setD(() => errorText = t('invalid_payment_amount'));
                  return;
                }
                if (payment > remaining) {
                  setD(() => errorText =
                      '${t('payment_exceeds_remaining')} (${fmtCurrency(remaining)})');
                  return;
                }

                site.totalPaid += payment;
                AppDatabase.logActivity('payments', 'إضافة دفعة مالية',
                    'ورشة ${site.name}: دفعة بقيمة ${fmtCurrency(payment)} | المتبقي: ${fmtCurrency(site.totalContractAmount - site.totalPaid)}');
                Navigator.pop(dialogContext);
                if (mounted) setState(() {});
                await AppDatabase.saveData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('payment_saved_ok'))),
                );
              },
              child: Text(t('save'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= ملخص وتحليل الورش والأرباح =======================

class SiteAnalyticsScreen extends StatefulWidget {
  const SiteAnalyticsScreen({super.key});

  @override
  State<SiteAnalyticsScreen> createState() => _SiteAnalyticsScreenState();
}

class _SiteAnalyticsScreenState extends State<SiteAnalyticsScreen> {
  WorkSite? _selectedSite;

  @override
  void initState() {
    super.initState();
    if (AppDatabase.sites.isNotEmpty) {
      _selectedSite = AppDatabase.sites.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppDatabase.sites.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text(t('m_site_analytics')),
            backgroundColor: Colors.indigo,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(child: Text(t('no_active_sites'))),
      );
    }

    final site = _selectedSite ?? AppDatabase.sites.first;

    // حسابات تكاليف العمال في هذه الورشة
    int totalSiteDays = 0;
    double totalSiteWages = 0;
    double totalSiteOvertimeHours = 0;
    double totalSiteOvertimePay = 0;
    double totalSiteTransport = 0;
    final workerBreakdown = <String, Map<String, dynamic>>{};

    for (final w in AppDatabase.workers) {
      int wDays = 0;
      double wOtHours = 0;
      double wTransport = 0;
      double wEarnings = 0;

      for (final log in w.logs.values) {
        if (log.worked && log.site == site.name) {
          wDays++;
          wOtHours += log.overtimeHours;
          wTransport += log.transport;
          wEarnings += log.total(w.dailyRate);
        }
      }

      if (wDays > 0) {
        workerBreakdown[w.name] = {
          'days': wDays,
          'otHours': wOtHours,
          'transport': wTransport,
          'earnings': wEarnings,
          'dailyRate': w.dailyRate,
        };
        totalSiteDays += wDays;
        totalSiteOvertimeHours += wOtHours;
        totalSiteOvertimePay += wOtHours * AppDatabase.overtimeRate;
        totalSiteTransport += wTransport;
        totalSiteWages += wEarnings;
      }
    }

    final contractTotal = site.totalContractAmount;
    final received = site.totalPaid;
    final remaining = contractTotal - received;
    final laborCost = totalSiteWages;
    final expectedNetProfit = contractTotal - laborCost;
    final realCurrentProfit = received - laborCost;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('m_site_analytics')),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: t('share_tip'),
            onPressed: () {
              final sb = StringBuffer();
              sb.writeln('🏗️ ${t('m_site_analytics')}: ${site.name}');
              sb.writeln('📍 ${t('site_address')}: ${site.location}');
              sb.writeln('💰 ${t('site_kpi_contract')}: ${fmtCurrency(contractTotal)}');
              sb.writeln('💵 ${t('site_kpi_received')}: ${fmtCurrency(received)}');
              sb.writeln('⏳ ${t('site_kpi_remaining')}: ${fmtCurrency(remaining)}');
              sb.writeln('👷 ${t('site_kpi_cost')}: ${fmtCurrency(laborCost)}');
              sb.writeln('📈 ${t('site_kpi_net_profit')}: ${fmtCurrency(expectedNetProfit)}');
              sb.writeln('📊 ${t('site_kpi_real_profit')}: ${fmtCurrency(realCurrentProfit)}');
              sb.writeln('👥 ${t('site_workers_count')}: ${workerBreakdown.length}');
              sb.writeln('🗓️ ${t('site_total_days')}: $totalSiteDays');
              Share.share(sb.toString());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اختيار الورشة
            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.apartment, color: Colors.indigo),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<WorkSite>(
                          isExpanded: true,
                          value: AppDatabase.sites.contains(site) ? site : null,
                          items: AppDatabase.sites.map((s) {
                            return DropdownMenuItem<WorkSite>(
                              value: s,
                              child: Text(
                                '${s.name} ${s.isDelivered ? "(${t('delivered_flag')})" : ""}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: s.isDelivered
                                      ? Colors.grey.shade700
                                      : Colors.indigo.shade900,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newSite) {
                            if (newSite != null) {
                              setState(() => _selectedSite = newSite);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // كروت الأرباح والتحليل المالي
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _kpiCard(t('site_kpi_contract'), fmtCurrency(contractTotal),
                    Colors.indigo, Icons.account_balance),
                _kpiCard(t('site_kpi_received'), fmtCurrency(received),
                    Colors.teal, Icons.payments),
                _kpiCard(t('site_kpi_remaining'), fmtCurrency(remaining),
                    remaining > 0 ? Colors.red : Colors.green, Icons.pending),
                _kpiCard(t('site_kpi_cost'), fmtCurrency(laborCost),
                    Colors.orange.shade800, Icons.engineering),
                _kpiCard(t('site_kpi_net_profit'),
                    fmtCurrency(expectedNetProfit),
                    expectedNetProfit >= 0 ? Colors.green : Colors.red,
                    Icons.trending_up),
                _kpiCard(t('site_kpi_real_profit'),
                    fmtCurrency(realCurrentProfit),
                    realCurrentProfit >= 0 ? Colors.green : Colors.red,
                    Icons.account_balance_wallet),
              ],
            ),
            const SizedBox(height: 12),

            // إحصائيات العمل
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _metricRow(t('site_workers_count'), '${workerBreakdown.length}'),
                    const Divider(height: 12),
                    _metricRow(t('site_total_days'), '$totalSiteDays'),
                    const Divider(height: 12),
                    _metricRow(t('site_total_ot'),
                        '${fmtNum(totalSiteOvertimeHours)} ${t('hour_short')} (${fmtCurrency(totalSiteOvertimePay)})'),
                    const Divider(height: 12),
                    _metricRow(t('site_total_transport'),
                        fmtCurrency(totalSiteTransport)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // تفاصيل العمال في هذه الورشة
            Text(t('site_worker_breakdown'),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo)),
            const SizedBox(height: 8),

            workerBreakdown.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text('لم يتم تسجيل أي حضور للعمال في هذه الورشة بعد.'),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: workerBreakdown.length,
                    itemBuilder: (ctx, idx) {
                      final wName = workerBreakdown.keys.elementAt(idx);
                      final data = workerBreakdown[wName]!;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: const Icon(Icons.person, color: Colors.indigo),
                          ),
                          title: Text(wName,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${t('work_days')}: ${data['days']} | ${t('overtime_short')}: ${fmtNum(data['otHours'])} ${t('hour_short')} | ${t('transport_short')}: ${fmtCurrency(data['transport'])}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(t('worker_site_earnings'),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                              Text(fmtCurrency(data['earnings']),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String val, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(title,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(val,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ======================= سجل الحركات والنشاطات (Audit Log) =======================

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  String _selectedCategory = 'all';

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'payments':
        return Colors.green;
      case 'sites':
        return Colors.orange.shade800;
      case 'workers':
        return Colors.blue;
      case 'attendance':
        return Colors.purple;
      case 'pdf':
        return Colors.red;
      case 'backup':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'payments':
        return Icons.payments;
      case 'sites':
        return Icons.apartment;
      case 'workers':
        return Icons.people;
      case 'attendance':
        return Icons.event_available;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'backup':
        return Icons.cloud_sync;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _selectedCategory == 'all'
        ? AppDatabase.logs
        : AppDatabase.logs.where((l) => l.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t('m_activity_log')),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: t('clear_logs'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(t('clear_logs')),
                  content: Text(t('clear_logs_confirm')),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(t('cancel'))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(t('confirm'),
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AppDatabase.clearAllLogs();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط الفلاتر
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _filterChip('all', t('filter_all')),
                _filterChip('payments', t('filter_payments')),
                _filterChip('sites', t('filter_sites')),
                _filterChip('workers', t('filter_workers')),
                _filterChip('attendance', t('filter_attendance')),
                _filterChip('pdf', t('filter_pdf')),
                _filterChip('backup', t('filter_backup')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(child: Text(t('no_logs_found')))
                : ListView.builder(
                    itemCount: filteredLogs.length,
                    itemBuilder: (ctx, idx) {
                      final log = filteredLogs[idx];
                      final color = _categoryColor(log.category);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(_categoryIcon(log.category), color: color),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(log.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ),
                              Text(
                                fmtFullDateTime(log.timestamp),
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(log.details,
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String cat, String label) {
    final isSelected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.indigo.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.indigo.shade900 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (val) {
          if (val) setState(() => _selectedCategory = cat);
        },
      ),
    );
  }
}

// ======================= قائمة العمال =======================

class WorkersListScreen extends StatefulWidget {
  const WorkersListScreen({super.key});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  @override
  Widget build(BuildContext context) {
    final allWorkers = AppDatabase.workers;

    return Scaffold(
      appBar: AppBar(
          title: Text(t('workers_list_title')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: allWorkers.isEmpty
          ? Center(child: Text(t('no_workers')))
          : ListView.builder(
              itemCount: allWorkers.length,
              itemBuilder: (context, index) {
                final worker = allWorkers[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          worker.isArchived ? Colors.grey : Colors.indigo,
                      child: Icon(
                        worker.isArchived
                            ? Icons.person_off
                            : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(worker.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        if (worker.isArchived) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(t('archived_tab'),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange.shade900)),
                          ),
                        ]
                      ],
                    ),
                    subtitle: Text(
                        '${t('daily_wage')}: ${fmtCurrency(worker.dailyRate)} | ${t('phone')}: ${ltr(worker.phone)}'),
                    trailing: const Icon(Icons.edit, color: Colors.indigo),
                    onTap: () => _editWorkerDialog(context, worker),
                  ),
                );
              },
            ),
    );
  }

  void _editWorkerDialog(BuildContext context, Worker worker) {
    final nameController = TextEditingController(text: worker.name);
    final rateController =
        TextEditingController(text: numStr(worker.dailyRate));
    final phoneController = TextEditingController(text: worker.phone);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t('edit_worker')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: t('worker_name'))),
            TextField(
                controller: rateController,
                decoration: InputDecoration(
                    labelText: '${t('daily_wage')} (${AppDatabase.currency})'),
                keyboardType: TextInputType.number),
            TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: t('phone_number')),
                keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                worker.name = nameController.text.trim();
                worker.dailyRate =
                    double.tryParse(rateController.text) ?? worker.dailyRate;
                worker.phone = phoneController.text.trim();
              });
              AppDatabase.logActivity('workers', 'تعديل بيانات عامل',
                  'تم تعديل بيانات العامل ${worker.name}');
              Navigator.pop(dialogContext);
              await AppDatabase.saveData();
            },
            child: Text(t('save_edits')),
          ),
        ],
      ),
    );
  }
}

// ======================= التقارير الأسبوعية =======================

class WeekNavigator extends StatelessWidget {
  final DateTime weekStart;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const WeekNavigator(
      {super.key,
      required this.weekStart,
      required this.onPrev,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    final end = addDays(weekStart, 6);
    return Container(
      color: Colors.indigo.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.indigo),
                onPressed: onPrev),
            Flexible(
              child: Text(
                '${t('week')}: ${fmtFullDate(weekStart)} - ${fmtFullDate(end)}',
                textAlign: TextAlign.center,
                textDirection:
                    L10n.isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.indigo),
                onPressed: onNext),
          ],
        ),
      ),
    );
  }
}

String dayCellText(DayLog? log, double rate, String lang) {
  if (log == null) return '';
  if (!log.worked) return L10n.tr('holiday', lang);
  return fmtMoney(log.total(rate));
}

String buildWorkerWeekText(Worker w, DateTime ws, String lang) {
  String tr(String k) => L10n.tr(k, lang);
  final sb = StringBuffer();
  sb.writeln('📊 ${tr('worker_report')}: ${w.name}');
  sb.writeln('📅 ${tr('week')}: ${fmtDate(ws)} - ${fmtDate(addDays(ws, 6))}');
  sb.writeln('');
  double total = 0, base = 0, ot = 0, trans = 0;
  int days = 0;
  for (int i = 0; i < 7; i++) {
    final d = addDays(ws, i);
    final log = w.logFor(d);
    final label = '${L10n.day(i, lang)} ${fmtDate(d)}';
    if (log == null) {
      sb.writeln('$label: —');
    } else if (!log.worked) {
      sb.writeln('$label: ${tr('holiday')}');
    } else {
      final dayTotal = log.total(w.dailyRate);
      total += dayTotal;
      base += w.dailyRate;
      ot += log.overtimeHours * AppDatabase.overtimeRate;
      trans += log.transport;
      days++;
      sb.writeln(
          '$label: ${log.site.isEmpty ? "" : "${log.site} | "}${tr('overtime_short')} ${fmtNum(log.overtimeHours)}${tr('hour_short')} | ${tr('transport_short')} ${fmtMoney(log.transport)} = ${fmtCurrency(dayTotal)}${log.note.isEmpty ? "" : " | ${log.note}"}');
    }
  }
  sb.writeln('');
  sb.writeln('${tr('work_days')}: ${ltr('$days')}');
  sb.writeln('${tr('sum_days')}: ${fmtCurrency(base)}');
  sb.writeln('${tr('sum_overtime')}: ${fmtCurrency(ot)}');
  sb.writeln('${tr('sum_transport')}: ${fmtCurrency(trans)}');
  sb.writeln('💰 ${tr('weekly_total')}: ${fmtCurrency(total)}');
  return sb.toString();
}

String buildAllWeekText(DateTime ws, String lang) {
  String tr(String k) => L10n.tr(k, lang);
  final sb = StringBuffer();
  sb.writeln('📊 ${tr('all_report')}');
  sb.writeln('📅 ${fmtDate(ws)} - ${fmtDate(addDays(ws, 6))}');
  sb.writeln('');
  double grand = 0;
  final weekWorkers = AppDatabase.workersForWeek(ws);
  for (final w in weekWorkers) {
    final tot = w.weekTotal(ws);
    grand += tot;
    sb.writeln('👷 ${w.name}: ${fmtCurrency(tot)}');
  }
  sb.writeln('');
  sb.writeln('💰 ${tr('grand_total')}: ${fmtCurrency(grand)}');
  return sb.toString();
}

// ---------- محرك إنشاء الـ PDF بحل مشكلة المربعات والخطوط ----------

// خط عربي مضغوط مدمج مباشرة بالكود ليعمل الـ PDF بدون إنترنت نهائياً بنسبة 100%
const String _kArabicFontGzB64 = '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';

bool gPdfFontFailed = false;

Future<pw.Document> _newPdf() async {
  gPdfFontFailed = false;
  pw.Font? regular;

  // 1. الخط العربي المدمج مباشرة بالكود (يعمل بدون إنترنت وبدون ملفات إضافية)
  try {
    final fontBytes = gzip.decode(base64Decode(_kArabicFontGzB64));
    final byteData = ByteData.view(Uint8List.fromList(fontBytes).buffer);
    regular = pw.Font.ttf(byteData);
  } catch (_) {
    try {
      final regData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      regular = pw.Font.ttf(regData);
    } catch (_) {
      try {
        regular = await PdfGoogleFonts.cairoRegular();
      } catch (_) {
        try {
          regular = await PdfGoogleFonts.notoSansArabicRegular();
        } catch (_) {
          gPdfFontFailed = true;
        }
      }
    }
  }

  if (regular != null) {
    return pw.Document(
      theme: pw.ThemeData.withFont(
        base: regular,
        bold: regular,
        fontFallback: [regular],
      ),
    );
  } else {
    return pw.Document();
  }
}

pw.Widget _pdfCell(String text,
    {bool bold = false, bool rtl = false, bool numeric = false}) {
  final cleanText = plain(text);
  final isAr = hasArabic(cleanText);
  final textDir = (isAr || (rtl && !numeric))
      ? pw.TextDirection.rtl
      : pw.TextDirection.ltr;

  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      cleanText,
      textDirection: textDir,
      style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
    ),
  );
}

pw.Widget _pdfLine(String label, String value,
    {required bool rtl, bool big = false}) {
  final style = pw.TextStyle(
      fontSize: big ? 15 : 11,
      fontWeight: big ? pw.FontWeight.bold : pw.FontWeight.normal);
  final labelW = pw.Text('$label:',
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      style: style);
  final valueW = pw.Text(plain(value),
      textDirection: pw.TextDirection.ltr, style: style);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 3),
    child: pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: rtl
          ? [valueW, pw.SizedBox(width: 6), labelW]
          : [labelW, pw.SizedBox(width: 6), valueW],
    ),
  );
}

Future<void> shareWorkerWeekPdf(
    BuildContext context, Worker w, DateTime ws, String lang) async {
  final messenger = ScaffoldMessenger.of(context);
  String tr(String k) => L10n.tr(k, lang);
  final rtl = lang == 'ar';
  final td = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
  final pdf = await _newPdf();

  List<pw.Widget> order(List<pw.Widget> c) => rtl ? c.reversed.toList() : c;

  final rows = <pw.TableRow>[
    pw.TableRow(
      children: order(<pw.Widget>[
        _pdfCell(tr('day_col'), bold: true, rtl: rtl),
        _pdfCell(tr('site'), bold: true, rtl: rtl),
        _pdfCell(tr('overtime_short'), bold: true, rtl: rtl),
        _pdfCell(tr('transport_short'), bold: true, rtl: rtl),
        _pdfCell(tr('amount'), bold: true, rtl: rtl),
      ]),
    ),
  ];

  double base = 0, ot = 0, trans = 0, total = 0;
  int days = 0;
  for (int i = 0; i < 7; i++) {
    final d = addDays(ws, i);
    final log = w.logFor(d);
    String siteText = '-';
    if (log != null) {
      siteText = log.worked ? (log.site.isEmpty ? '-' : log.site) : tr('holiday');
    }
    if (log != null && log.worked) {
      days++;
      base += w.dailyRate;
      ot += log.overtimeHours * AppDatabase.overtimeRate;
      trans += log.transport;
      total += log.total(w.dailyRate);
    }
    rows.add(pw.TableRow(
      children: order(<pw.Widget>[
        _pdfCell('${L10n.day(i, lang)} ${fmtDate(d)}', rtl: rtl),
        _pdfCell(siteText, rtl: rtl),
        _pdfCell(log != null && log.worked ? fmtNum(log.overtimeHours) : '-',
            numeric: true),
        _pdfCell(log != null && log.worked ? fmtMoney(log.transport) : '-',
            numeric: true),
        _pdfCell(log == null ? '-' : fmtMoney(log.total(w.dailyRate)),
            numeric: true),
      ]),
    ));
  }

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(28),
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment:
            rtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          pw.Text('${tr('worker_report')}: ${w.name}',
              textDirection: hasArabic(w.name) ? pw.TextDirection.rtl : td,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _pdfLine(tr('week'), '${fmtDate(ws)} - ${fmtDate(addDays(ws, 6))}',
              rtl: rtl),
          pw.SizedBox(height: 14),
          pw.Table(border: pw.TableBorder.all(), children: rows),
          pw.SizedBox(height: 14),
          _pdfLine(tr('work_days'), '$days', rtl: rtl),
          _pdfLine(tr('sum_days'), fmtCurrency(base), rtl: rtl),
          _pdfLine(tr('sum_overtime'), fmtCurrency(ot), rtl: rtl),
          _pdfLine(tr('sum_transport'), fmtCurrency(trans), rtl: rtl),
          pw.SizedBox(height: 8),
          _pdfLine(tr('weekly_total'), fmtCurrency(total), rtl: rtl, big: true),
        ],
      ),
    ),
  );

  AppDatabase.logActivity('pdf', 'تصدير تقرير عامل PDF',
      'تم تصدير تقرير PDF للعامل ${w.name} للأسبوع ${fmtDate(ws)}');

  await Printing.sharePdf(
      bytes: await pdf.save(), filename: 'report_${w.name}.pdf');
  if (gPdfFontFailed) {
    messenger.showSnackBar(SnackBar(content: Text(t('pdf_font_err'))));
  }
}

Future<void> shareAllWeekPdf(
    BuildContext context, DateTime ws, String lang) async {
  final messenger = ScaffoldMessenger.of(context);
  String tr(String k) => L10n.tr(k, lang);
  final rtl = lang == 'ar';
  final td = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
  final pdf = await _newPdf();

  List<pw.Widget> order(List<pw.Widget> c) => rtl ? c.reversed.toList() : c;

  final header = <pw.Widget>[_pdfCell(tr('worker_col'), bold: true, rtl: rtl)];
  for (int i = 0; i < 7; i++) {
    header.add(_pdfCell('${L10n.day(i, lang)}\n${fmtDate(addDays(ws, i))}',
        bold: true, rtl: rtl));
  }
  header.add(_pdfCell(tr('total_word'), bold: true, rtl: rtl));

  final rows = <pw.TableRow>[pw.TableRow(children: order(header))];
  double grand = 0;
  final dayTotals = List<double>.filled(7, 0.0);
  final weekWorkers = AppDatabase.workersForWeek(ws);

  for (final w in weekWorkers) {
    final cells = <pw.Widget>[_pdfCell(w.name, rtl: rtl)];
    for (int i = 0; i < 7; i++) {
      final log = w.logFor(addDays(ws, i));
      dayTotals[i] += log?.total(w.dailyRate) ?? 0.0;
      cells.add(_pdfCell(dayCellText(log, w.dailyRate, lang),
          rtl: rtl, numeric: log != null && log.worked));
    }
    final tot = w.weekTotal(ws);
    grand += tot;
    cells.add(_pdfCell(fmtMoney(tot), bold: true, numeric: true));
    rows.add(pw.TableRow(children: order(cells)));
  }

  final totalCells = <pw.Widget>[_pdfCell(tr('total_word'), bold: true, rtl: rtl)];
  for (int i = 0; i < 7; i++) {
    totalCells.add(_pdfCell(fmtMoney(dayTotals[i]), bold: true, numeric: true));
  }
  totalCells.add(_pdfCell(fmtMoney(grand), bold: true, numeric: true));
  rows.add(pw.TableRow(children: order(totalCells)));

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment:
            rtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(tr('all_report'),
              textDirection: td,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _pdfLine(tr('week'), '${fmtDate(ws)} - ${fmtDate(addDays(ws, 6))}',
              rtl: rtl),
          pw.SizedBox(height: 12),
          pw.Table(border: pw.TableBorder.all(), children: rows),
          pw.SizedBox(height: 12),
          _pdfLine(tr('grand_total'), fmtCurrency(grand), rtl: rtl, big: true),
        ],
      ),
    ),
  );

  AppDatabase.logActivity('pdf', 'تصدير تقرير أسبوعي لجميع العمال PDF',
      'تم تصدير التقرير المشترك للأسبوع ${fmtDate(ws)} بمبلغ إجمالي ${fmtCurrency(grand)}');

  await Printing.sharePdf(bytes: await pdf.save(), filename: 'weekly_all.pdf');
  if (gPdfFontFailed) {
    messenger.showSnackBar(SnackBar(content: Text(t('pdf_font_err'))));
  }
}

// ---------- شاشات التقارير ----------

class WeeklySummaryScreen extends StatefulWidget {
  const WeeklySummaryScreen({super.key});

  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
  DateTime _weekStart = weekStartOf(DateTime.now());

  void _shift(int weeks) =>
      setState(() => _weekStart = addDays(_weekStart, 7 * weeks));

  @override
  Widget build(BuildContext context) {
    final weekWorkers = AppDatabase.workersForWeek(_weekStart);
    double grand = 0;
    for (final w in weekWorkers) {
      grand += w.weekTotal(_weekStart);
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(t('weekly_title')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: weekWorkers.isEmpty
          ? Center(child: Text(t('no_data')))
          : Column(
              children: [
                WeekNavigator(
                    weekStart: _weekStart,
                    onPrev: () => _shift(-1),
                    onNext: () => _shift(1)),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        color: Colors.indigo.shade50,
                        child: ListTile(
                          title: Text(t('joint_report'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text(
                              '${t('joint_sub')}\n${t('total_word')}: ${fmtCurrency(grand)}'),
                          isThreeLine: true,
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllWorkersWeekScreen(
                                        weekStart: _weekStart)));
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(t('per_worker'),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...weekWorkers.map((worker) {
                        final logs = worker.weekLogs(_weekStart);
                        final days =
                            logs.where((l) => l != null && l.worked).length;
                        return Card(
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(worker.name),
                                if (worker.isArchived) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                    child: Text(t('archived_tab'),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange.shade900)),
                                  ),
                                ]
                              ],
                            ),
                            subtitle:
                                Text('${t('work_days')}: ${ltr('$days')}'),
                            trailing: Text(fmtCurrency(worker.weekTotal(_weekStart)),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo)),
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WorkerWeekReportScreen(
                                              worker: worker,
                                              weekStart: _weekStart)));
                              setState(() {});
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class AllWorkersWeekScreen extends StatefulWidget {
  final DateTime weekStart;
  const AllWorkersWeekScreen({super.key, required this.weekStart});

  @override
  State<AllWorkersWeekScreen> createState() => _AllWorkersWeekScreenState();
}

class _AllWorkersWeekScreenState extends State<AllWorkersWeekScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = widget.weekStart;
  }

  void _shift(int weeks) =>
      setState(() => _weekStart = addDays(_weekStart, 7 * weeks));

  @override
  Widget build(BuildContext context) {
    final workers = AppDatabase.workersForWeek(_weekStart);
    final lang = L10n.lang;
    double grand = 0;
    final dayTotals = List<double>.filled(7, 0.0);
    for (final w in workers) {
      grand += w.weekTotal(_weekStart);
      for (int i = 0; i < 7; i++) {
        dayTotals[i] +=
            w.logFor(addDays(_weekStart, i))?.total(w.dailyRate) ?? 0.0;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t('joint_report')),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: t('pdf_tip'),
            onPressed: () async {
              final rl = await pickReportLang(context);
              if (rl == null || !mounted) return;
              await shareAllWeekPdf(context, _weekStart, rl);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: t('share_tip'),
            onPressed: () async {
              final rl = await pickReportLang(context);
              if (rl == null) return;
              await Share.share(buildAllWeekText(_weekStart, rl));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          WeekNavigator(
              weekStart: _weekStart,
              onPrev: () => _shift(-1),
              onNext: () => _shift(1)),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 14,
                  headingRowHeight: 60,
                  columns: [
                    DataColumn(label: Text(t('worker_col'))),
                    for (int i = 0; i < 7; i++)
                      DataColumn(
                        label: Text(
                            '${L10n.day(i)}\n${fmtDate(addDays(_weekStart, i))}',
                            textAlign: TextAlign.center),
                      ),
                    DataColumn(label: Text(t('total_word'))),
                  ],
                  rows: [
                    ...workers.map((w) => DataRow(cells: [
                          DataCell(Text(w.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                          for (int i = 0; i < 7; i++)
                            DataCell(Text(dayCellText(
                                w.logFor(addDays(_weekStart, i)),
                                w.dailyRate,
                                lang))),
                          DataCell(Text(fmtMoney(w.weekTotal(_weekStart)),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo))),
                        ])),
                    DataRow(cells: [
                      DataCell(Text(t('total_word'),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      for (int i = 0; i < 7; i++)
                        DataCell(Text(fmtMoney(dayTotals[i]),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold))),
                      DataCell(Text(fmtMoney(grand),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo))),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${t('grand_total')}:',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                Text(fmtCurrency(grand),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerWeekReportScreen extends StatefulWidget {
  final Worker worker;
  final DateTime weekStart;
  const WorkerWeekReportScreen(
      {super.key, required this.worker, required this.weekStart});

  @override
  State<WorkerWeekReportScreen> createState() => _WorkerWeekReportScreenState();
}

class _WorkerWeekReportScreenState extends State<WorkerWeekReportScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = widget.weekStart;
  }

  void _shift(int weeks) =>
      setState(() => _weekStart = addDays(_weekStart, 7 * weeks));

  String _describe(DayLog? log) {
    if (log == null) return t('not_logged');
    if (!log.worked) return t('holiday');
    final siteText = log.site.isEmpty ? '—' : log.site;
    return '${t('site')}: $siteText\n${t('overtime_short')}: ${fmtNum(log.overtimeHours)} ${t('hour_short')} | ${t('transport_short')}: ${fmtCurrency(log.transport)}${log.note.isEmpty ? "" : "\n${log.note}"}';
  }

  void _editDay(DateTime day) {
    final w = widget.worker;
    final key = dateKey(day);
    final existing = w.logs[key];

    bool worked = existing?.worked ?? true;
    final names = AppDatabase.sites
        .where((s) => !s.isDelivered)
        .map((s) => s.name)
        .toList();
    String site = existing?.site ?? '';
    if (site.isNotEmpty && !names.contains(site)) names.add(site);
    if (site.isEmpty && names.isNotEmpty) site = names.first;

    final otCtrl = TextEditingController(
        text: (existing == null || existing.overtimeHours == 0)
            ? ''
            : numStr(existing.overtimeHours));
    final trCtrl = TextEditingController(
        text: (existing == null || existing.transport == 0)
            ? ''
            : numStr(existing.transport));
    final noteCtrl = TextEditingController(text: existing?.note ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text('${L10n.day(day.weekday % 7)} ${fmtDate(day)} - ${w.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t('works')),
                    Switch(
                        value: worked, onChanged: (v) => setD(() => worked = v)),
                  ],
                ),
                if (names.isNotEmpty)
                  InputDecorator(
                    decoration: InputDecoration(labelText: t('site')),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: names.contains(site) ? site : null,
                        items: names
                            .map((n) =>
                                DropdownMenuItem(value: n, child: Text(n)))
                            .toList(),
                        onChanged:
                            worked ? (v) => setD(() => site = v ?? '') : null,
                      ),
                    ),
                  ),
                TextField(
                  controller: otCtrl,
                  enabled: worked,
                  decoration: InputDecoration(labelText: t('overtime')),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: trCtrl,
                  enabled: worked,
                  decoration: InputDecoration(
                      labelText: '${t('transport')} (${AppDatabase.currency})'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: noteCtrl,
                  enabled: worked,
                  decoration: InputDecoration(labelText: t('note')),
                ),
              ],
            ),
          ),
          actions: [
            if (existing != null)
              TextButton(
                onPressed: () async {
                  w.logs.remove(key);
                  AppDatabase.logActivity('attendance', 'مسح يوم عمل',
                      '${w.name} - تم مسح تسجيل يوم ${fmtDate(day)}');
                  Navigator.pop(dialogContext);
                  if (mounted) setState(() {});
                  await AppDatabase.saveData();
                },
                child: Text(t('delete_day'),
                    style: const TextStyle(color: Colors.red)),
              ),
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(t('cancel'))),
            ElevatedButton(
              onPressed: () async {
                w.logs[key] = DayLog(
                  worked: worked,
                  site: site,
                  overtimeHours: double.tryParse(otCtrl.text) ?? 0.0,
                  transport: double.tryParse(trCtrl.text) ?? 0.0,
                  note: noteCtrl.text.trim(),
                );
                AppDatabase.logActivity('attendance', 'تعديل تسجيل يوم',
                    '${w.name} (${fmtDate(day)}): ${worked ? "يعمل في $site" : "عطلة"}');
                Navigator.pop(dialogContext);
                if (mounted) setState(() {});
                await AppDatabase.saveData();
              },
              child: Text(t('save')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sumRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value)],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final w = widget.worker;
    final logs = w.weekLogs(_weekStart);
    final today = dateOnly(DateTime.now());

    int daysWorked = 0;
    double baseTotal = 0, overtimeTotal = 0, transportTotal = 0;
    for (final l in logs) {
      if (l != null && l.worked) {
        daysWorked++;
        baseTotal += w.dailyRate;
        overtimeTotal += l.overtimeHours * AppDatabase.overtimeRate;
        transportTotal += l.transport;
      }
    }
    final total = w.weekTotal(_weekStart);

    return Scaffold(
      appBar: AppBar(
        title: Text('${t('worker_report')}: ${w.name}',
            overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: t('pdf_tip'),
            onPressed: () async {
              final rl = await pickReportLang(context);
              if (rl == null || !mounted) return;
              await shareWorkerWeekPdf(context, w, _weekStart, rl);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: t('share_tip'),
            onPressed: () async {
              final rl = await pickReportLang(context);
              if (rl == null) return;
              await Share.share(buildWorkerWeekText(w, _weekStart, rl));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          WeekNavigator(
              weekStart: _weekStart,
              onPrev: () => _shift(-1),
              onNext: () => _shift(1)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                for (int i = 0; i < 7; i++)
                  Builder(builder: (context) {
                    final d = addDays(_weekStart, i);
                    final log = logs[i];
                    return Card(
                      color: d == today ? Colors.indigo.shade50 : null,
                      child: ListTile(
                        isThreeLine: log != null && log.worked,
                        title: Text('${L10n.day(i)}  ${fmtDate(d)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(_describe(log)),
                        trailing: Text(
                            log == null ? '—' : fmtCurrency(log.total(w.dailyRate)),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo)),
                        onTap: () => _editDay(d),
                      ),
                    );
                  }),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _sumRow(t('work_days'), ltr('$daysWorked')),
                        _sumRow(t('sum_days'), fmtCurrency(baseTotal)),
                        _sumRow(t('sum_overtime'), fmtCurrency(overtimeTotal)),
                        _sumRow(t('sum_transport'), fmtCurrency(transportTotal)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${t('weekly_total')}:',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Text(fmtCurrency(total),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
