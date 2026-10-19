import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:typed_data';

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

  static const Map<String, List<String>> _s = {
    'app_title': [
      'WookFlow - إدارة الورش والعمال',
      'WookFlow - Chantiers & ouvriers',
      'WookFlow - Sites & workers'
    ],
    'manager': ['مدير الورشة', 'Chef de chantier', 'Site manager'],
    'version': ['نظام إدارة المشاريع v1.3.0', 'Gestion de projets v1.3.0', 'Project management v1.3.0'],
    'language': ['اللغة', 'Langue', 'Language'],
    'report_lang': ['لغة التقرير', 'Langue du rapport', 'Report language'],
    'm_daily': ['التقرير اليومي (حضور اليوم)', 'Rapport journalier (présence)', 'Daily report (attendance)'],
    'm_add_worker': ['إضافة عامل جديد', 'Ajouter un ouvrier', 'Add worker'],
    'm_delete_worker': ['إدارة وأرشفة العمال', 'Gérer / archiver ouvriers', 'Manage / archive workers'],
    'm_sites': ['مواقع العمل (الورش النشطة)', 'Chantiers actifs', 'Active work sites'],
    'm_delivered': ['الورش المسلمة والمنتهية', 'Chantiers livrés / terminés', 'Delivered sites'],
    'm_payment': ['دفعة جديدة (حسابات الورش)', 'Nouveau paiement (comptes chantiers)', 'New payment (site accounts)'],
    'm_workers': ['قائمة العمال وتعديلهم', 'Liste des ouvriers / modifier', 'Workers list / edit'],
    'm_weekly': ['ملخص الأسبوع والتقارير', 'Résumé hebdo & rapports', 'Weekly summary & reports'],
    'm_site_analytics': ['ملخص وتحليل الورش والأرباح', 'Analyse & rentabilité chantiers', 'Site analytics & profit'],
    'm_activity_log': ['سجل الحركات والنشاطات', 'Journal des activités', 'Activity audit log'],
    'm_contracts_new': ['إبرام عقد جديد', 'Nouveau contrat', 'New contract'],
    'm_contracts_active': ['قائمة العقود الحالية', 'Contrats en cours', 'Active contracts'],
    'm_contracts_finished': ['قائمة العقود المنتهية', 'Contrats terminés', 'Finished contracts'],
    'section_workers': ['إدارة شؤون العمال', 'Gestion des ouvriers', 'Workers management'],
    'section_sites': ['إدارة مواقع العمل (الورش)', 'Gestion des chantiers', 'Sites & accounts'],
    'section_contracts': ['إدارة عقود المقاولين', 'Contrats & sous-traitance', 'Contractors contracts'],
    'section_reports_settings': ['التقارير والإعدادات', 'Rapports & paramètres', 'Reports & settings'],
    'add_workers_first': ['أضف عمالًا أولًا من القائمة الجانبية', "Ajoutez d'abord des ouvriers depuis le menu", 'Add workers first from the side menu'],
    'daily_btn': ['التقرير اليومي (تسجيل حضور اليوم)', 'Rapport journalier (pointage du jour)', "Daily report (today's attendance)"],
    'card_workers_today': ['العمال اليوم', "Ouvriers aujourd'hui", 'Workers today'],
    'card_active_sites': ['الورش النشطة', 'Chantiers actifs', 'Active sites'],
    'card_delivered_sites': ['الورش المسلمة', 'Chantiers livrés', 'Delivered sites'],
    'card_contracts_active': ['العقود الحالية', 'Contrats en cours', 'Active contracts'],
    'card_payments_manage': ['إدارة الدفعات', 'Gestion paiements', 'Manage payments'],
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
    'save_close': ['حفظ وإغلاق التقرير اليومي', 'Enregistrer et fermer', 'Save & close'],
    'add_worker_title': ['إضافة عامل جديد', 'Nouvel ouvrier', 'New worker'],
    'worker_name_req': ['اسم العامل (إجباري)', "Nom de l'ouvrier (obligatoire)", 'Worker name (required)'],
    'enter_name': ['يرجى إدخال اسم العامل', 'Veuillez saisir le nom', 'Please enter the name'],
    'rate_req': ['الأجر اليومي', 'Salaire journalier', 'Daily wage'],
    'enter_rate': ['يرجى إدخال اليومية', 'Veuillez saisir le salaire', 'Please enter the wage'],
    'phone_opt': ['رقم الهاتف (اختياري)', 'Téléphone (facultatif)', 'Phone (optional)'],
    'save_worker': ['حفظ العامل', "Enregistrer l'ouvrier", 'Save worker'],
    'worker_saved': ['تم إضافة العامل وحفظه بنجاح', 'Ouvrier ajouté et enregistré', 'Worker added and saved'],
    'save_failed': ['فشل الحفظ', "Échec de l'enregistrement", 'Save failed'],
    'manage_workers_title': ['أرشفة وحذف العمال', 'Archivage / suppression ouvriers', 'Archive / delete workers'],
    'archive_btn': ['أرشفة', 'Archiver', 'Archive'],
    'restore_btn': ['استعادة', 'Réactiver', 'Restore'],
    'permanent_delete_btn': ['حذف نهائي', 'Suppression définitive', 'Permanent delete'],
    'active_tab': ['النشطون', 'Actifs', 'Active'],
    'archived_tab': ['المؤرشفون (السابقون)', 'Archivés', 'Archived'],
    'archive_success': ['تم أرشفة العامل بنجاح مع الحفاظ على جميع سجلاته السابقة', 'Ouvrier archivé (historique conservé)', 'Worker archived (history preserved)'],
    'restore_success': ['تم إعادة تفعيل العامل بنجاح', 'Ouvrier réactivé avec succès', 'Worker reactivated'],
    'permanent_delete_success': ['تم الحذف النهائي للعامل', 'Ouvrier supprimé définitivement', 'Worker permanently deleted'],
    'delete_confirm_title': ['تأكيد الحذف النهائي', 'Confirmation de suppression', 'Confirm permanent deletion'],
    'delete_confirm_body': ['تحذير: الحذف النهائي سيحذف العامل وجميع أيامه وسجلاته القديمة تماماً! للأمان، يفضل استخدام (الأرشفة) للاحتفاظ بالتقارير. هل تريد المتابعة؟', 'Attention : Cela effacera définitivement l’ouvrier et son historique. Voulez-vous continuer ?', 'Warning: This permanently deletes the worker and all historical records. Proceed?'],
    'no_active_workers': ['لا يوجد عمال نشطون حالياً', 'Aucun ouvrier actif', 'No active workers'],
    'no_archived_workers': ['لا يوجد عمال مؤرشفون', 'Aucun ouvrier archivé', 'No archived workers'],
    'daily_wage': ['اليومية', 'Salaire/jour', 'Daily wage'],
    'phone': ['الهاتف', 'Tél.', 'Phone'],
    'add_site_title': ['إضافة موقع عمل جديد', 'Nouveau chantier', 'New work site'],
    'edit_site_title': ['تعديل بيانات الورشة والحساب', 'Modifier chantier & montant', 'Edit site & contract amount'],
    'site_name': ['اسم الموقع', 'Nom du chantier', 'Site name'],
    'site_address': ['العنوان', 'Adresse', 'Address'],
    'site_total': ['الأجر الكامل للورشة', 'Montant total du chantier', 'Total contract amount'],
    'add_extra_amount': ['إضافة مبلغ على العقد (ملحق / أعمال إضافية)', 'Ajouter un supplément au contrat', 'Add extra amount to contract'],
    'extra_amount_val': ['قيمة المبلغ الإضافي', 'Montant du supplément', 'Extra amount'],
    'extra_amount_reason': ['سبب الإضافة (ملاحظة)', 'Motif du supplément', 'Reason for extra amount'],
    'current_paid_amount': ['المبلغ المدفوع (الواصل) الحالي', 'Montant payé actuel', 'Current paid amount'],
    'edit_paid_amount': ['تعديل المبلغ المدفوع (الواصل)', 'Modifier montant payé', 'Edit paid amount'],
    'undo_last_payment': ['إلغاء آخر دفعة', 'Annuler dernier paiement', 'Undo last payment'],
    'last_payment_info': ['آخر دفعة مسجلة', 'Dernier paiement', 'Last payment'],
    'payment_undone_msg': ['تم إلغاء آخر دفعة بنجاح وتعديل الحساب', 'Dernier paiement annulé avec succès', 'Last payment undone successfully'],
    'cancel': ['إلغاء', 'Annuler', 'Cancel'],
    'save': ['حفظ', 'Enregistrer', 'Save'],
    'confirm': ['تأكيد', 'Confirmer', 'Confirm'],
    'sites_title': ['مواقع العمل النشطة', 'Chantiers actifs', 'Active work sites'],
    'no_active_sites': ['لا توجد ورش نشطة حالياً', 'Aucun chantier actif', 'No active sites'],
    'total': ['الإجمالي', 'Total', 'Total'],
    'deliver': ['تسليم الورشة', 'Livrer le chantier', 'Deliver site'],
    'delivered_msg': ['تم تسليم الورشة ونقلها للأرشيف', 'Chantier livré et archivé', 'Site delivered and archived'],
    'delivered_title': ['الورش المسلمة والمنتهية', 'Chantiers livrés / terminés', 'Delivered sites'],
    'no_delivered': ['لا توجد ورش مسلمة حتى الآن', 'Aucun chantier livré', 'No delivered sites yet'],
    'contract_total': ['الأجر الإجمالي', 'Montant total', 'Contract total'],
    'received': ['الواصل', 'Reçu', 'Received'],
    'delivered_flag': ['تم التسليم', 'Livré', 'Delivered'],
    'reopen_site': ['إعادة فتح الورشة للنشطة', 'Rouvrir le chantier (actif)', 'Reopen site (make active)'],
    'reopen_confirm_title': ['إعادة فتح الورشة', 'Rouvrir le chantier', 'Reopen work site'],
    'reopen_confirm_msg': ['هل تريد إعادة فتح هذه الورشة وإعادتها إلى قائمة الورش النشطة؟', 'Voulez-vous réintégrer ce chantier dans les chantiers actifs ?', 'Do you want to reopen this site and move it back to active sites?'],
    'site_reopened_msg': ['تمت إعادة فتح الورشة ونقلها للنشطة بنجاح', 'Chantier rouvert avec succès', 'Site reopened successfully'],
    'confirm_delivery_title': ['تأكيد تسليم الورشة', 'Confirmer la livraison', 'Confirm delivery'],
    'confirm_delivery_paid_body': ['الحساب مقفل بالكامل، هل تريد تأكيد تسليم الورشة ونقلها للأرشيف؟', 'Le compte est soldé. Confirmer la livraison du chantier ?', 'Account fully settled. Confirm delivery and move to archive?'],
    'unsettled_delivery_title': ['تنبيه: الحساب غير مقفل بعد', 'Attention : Compte non soldé', 'Warning: Account not settled'],
    'unsettled_warning_note': ['تنبيه: لا يمكن تسليم الورشة مع وجود متبقي غير مسدد، إلا بإغلاق الحساب الآن أو التسليم باستثناء مع توضيح السبب بملاحظة.', 'Attention : Chantier non soldé. Veuillez solder ou justifier par une remarque.', 'Warning: Site has unpaid balance. Please settle in full or provide an exception note.'],
    'exception_note_label': ['ملاحظة / سبب التسليم الاستثنائي (إجباري)', 'Motif exceptionnel (obligatoire)', 'Exception reason / note (required)'],
    'exception_note_hint': ['مثال: اتفاق على تأجيل الدفع، خصم متفق عليه...', 'Ex : report de paiement, remise...', 'E.g. payment postponed, agreed discount...'],
    'exception_note_required': ['يرجى كتابة سبب التسليم الاستثنائي قبل المتابعة', 'Veuillez saisir le motif exceptionnel', 'Please enter the exception reason'],
    'pay_all_and_deliver': ['تسديد المتبقي وتسليم', 'Tout solder et livrer', 'Settle all and deliver'],
    'deliver_with_exception': ['تسليم باستثناء مع الملاحظة', 'Livrer avec dérogation', 'Deliver with exception'],
    'paid_in_full_on_delivery': ['تم سداد كامل المتبقي عند التسليم', 'Soldé intégralement à la livraison', 'Settled in full on delivery'],
    'delivery_note_prefix': ['ملاحظة التسليم', 'Note de livraison', 'Delivery note'],
    'delete_site_title': ['حذف الورشة', 'Supprimer le chantier', 'Delete site'],
    'delete_site_confirm_msg': ['هل أنت متأكد من حذف الورشة نهائياً؟', 'Êtes-vous sûr de supprimer définitivement ce chantier ?', 'Are you sure you want to permanently delete this site?'],
    'site_deleted_msg': ['تم حذف الورشة بنجاح', 'Chantier supprimé avec succès', 'Site deleted successfully'],
    'delete_delivered_site': ['حذف من الأرشيف', 'Supprimer des archives', 'Delete from archives'],
    'delete_delivered_confirm_msg': ['هل أنت متأكد من حذف هذه الورشة المسلمة نهائياً من الأرشيف؟', 'Êtes-vous sûr de supprimer définitivement ce chantier des archives ?', 'Are you sure you want to permanently delete this site from archives?'],
    'payments_title': ['إدارة الدفعات والواصل', 'Gestion des paiements', 'Payments management'],
    'no_sites_payment': ['لا توجد ورش نشطة لإضافة دفعات', 'Aucun chantier actif pour ajouter un paiement', 'No active sites to add payments'],
    'remaining': ['الباقي', 'Reste', 'Remaining'],
    'add_payment_for': ['إضافة دفعة لـ', 'Ajouter un paiement pour', 'Add payment for'],
    'payments_sum': ['مجموع الدفعات (الواصل)', 'Total des paiements (reçu)', 'Total payments (received)'],
    'new_payment': ['قيمة الدفعة الجديدة', 'Nouveau paiement', 'New payment'],
    'pay_remaining_all': ['دفع كامل المتبقي', 'Payer tout le reste', 'Pay all remaining'],
    'site_already_fully_paid': ['تم سداد كامل قيمة الورشة، لا يوجد متبقي لإضافة دفعات', 'Le chantier est déjà entièrement payé', 'Site already fully paid, no remaining balance'],
    'invalid_payment_amount': ['يرجى إدخال مبلغ صحيح أكبر من صفر', 'Veuillez saisir un montant supérieur à zéro', 'Please enter a valid amount greater than zero'],
    'payment_exceeds_remaining': ['خطأ: المبلغ المدخل أكبر من المتبقي', 'Erreur : Le montant dépasse le solde restant', 'Error: Amount exceeds remaining balance'],
    'payment_saved_ok': ['تم تسجيل الدفعة بنجاح', 'Paiement enregistré avec succès', 'Payment recorded successfully'],
    'workers_list_title': ['قائمة العمال وتعديل بياناتهم', 'Liste des ouvriers', 'Workers list'],
    'no_workers': ['لا يوجد عمال مضافون', 'Aucun ouvrier', 'No workers'],
    'edit_worker': ['تعديل بيانات العامل', "Modifier l'ouvrier", 'Edit worker'],
    'worker_name': ['اسم العامل', "Nom de l'ouvrier", 'Worker name'],
    'phone_number': ['رقم الهاتف', 'Téléphone', 'Phone number'],
    'save_edits': ['حفظ التعديلات', 'Enregistrer les modifications', 'Save changes'],
    'weekly_title': ['ملخص الأسبوع والرواتب', 'Résumé hebdomadaire et salaires', 'Weekly summary & wages'],
    'no_data': ['لا توجد بيانات لعرض الملخص', 'Aucune donnée à afficher', 'No data to display'],
    'week': ['الأسبوع', 'Semaine', 'Week'],
    'joint_report': ['التقرير المشترك لجميع العمال', 'Rapport commun de tous les ouvriers', 'Combined report for all workers'],
    'joint_sub': ['من الأحد إلى السبت', 'Du dimanche au samedi', 'Sunday to Saturday'],
    'total_word': ['المجموع', 'Total', 'Total'],
    'per_worker': ['تقرير كل عامل على حدة', 'Rapport par ouvrier', 'Report per worker'],
    'work_days': ['أيام العمل', 'Jours travaillés', 'Days worked'],
    'worker_col': ['العامل', 'Ouvrier', 'Worker'],
    'grand_total': ['المجموع الكلي لجميع العمال', 'Total général de tous les ouvriers', 'Grand total of all workers'],
    'worker_report': ['تقرير العامل', "Rapport de l'ouvrier", 'Worker report'],
    'all_report': ['التقرير الأسبوعي لجميع العمال', 'Rapport hebdomadaire de tous les ouvriers', 'Weekly report for all workers'],
    'not_logged': ['لم يُسجَّل (اضغط للتعديل)', 'Non renseigné (appuyer pour modifier)', 'Not recorded (tap to edit)'],
    'holiday': ['عطلة', 'Repos', 'Day off'],
    'overtime_short': ['إضافي', 'Heures supp.', 'Overtime'],
    'transport_short': ['نقل', 'Transport', 'Transport'],
    'hour_short': ['س', 'h', 'h'],
    'delete_day': ['مسح اليوم', 'Effacer le jour', 'Clear day'],
    'sum_days': ['مجموع اليوميات', 'Total des journées', 'Total daily wages'],
    'sum_overtime': ['مجموع الإضافي', 'Total heures supp.', 'Total overtime'],
    'sum_transport': ['مجموع المواصلات', 'Total transport', 'Total transport'],
    'weekly_total': ['المجموع الأسبوعي', 'Total de la semaine', 'Weekly total'],
    'amount': ['المبلغ', 'Montant', 'Amount'],
    'day_col': ['اليوم', 'Jour', 'Day'],
    'pdf_tip': ['تنزيل ومشاركة PDF', 'Télécharger / partager PDF', 'Download / share PDF'],
    'share_tip': ['مشاركة كنص (واتساب)', 'Partager en texte (WhatsApp)', 'Share as text (WhatsApp)'],
    'currency': ['العملة', 'Devise', 'Currency'],
    'change_currency': ['تغيير العملة', 'Changer la devise', 'Change currency'],
    'custom_currency': ['عملة مخصصة', 'Devise personnalisée', 'Custom currency'],
    'enter_custom_currency': ['أدخل رمز العملة', 'Entrez la devise', 'Enter currency'],
    'edit_overtime_rate': ['تعديل سعر ساعة الإضافي', 'Modifier taux heure supp.', 'Edit overtime hourly rate'],
    'overtime_rate_hint': ['سعر ساعة العمل الإضافي الافتراضي', 'Taux horaire par défaut', 'Default overtime hourly rate'],
    'backup_menu': ['النسخ الاحتياطي للبيانات', 'Sauvegarde des données', 'Data backup & restore'],
    'export_backup': ['تصدير نسخة احتياطية (مشاركة/حفظ)', 'Exporter une sauvegarde', 'Export backup'],
    'import_backup': ['استعادة نسخة احتياطية (لصق كود)', 'Restaurer une sauvegarde', 'Import backup'],
    'paste_json': ['الصق نص النسخة الاحتياطية هنا:', 'Collez le code de sauvegarde ici :', 'Paste backup JSON here:'],
    'restore_done': ['تمت استعادة البيانات بنجاح!', 'Données restaurées avec succès !', 'Data restored successfully!'],
    'restore_err': ['فشلت الاستعادة: البيانات غير صالحة', 'Échec : données invalides', 'Restore failed: Invalid data'],
    'pdf_font_err': ['تعذر إنشاء ملف PDF', 'Échec PDF', 'PDF Error'],
    'select_site_hint': ['اختر ورشة لعرض تحليلها الكامل', 'Sélectionnez un chantier', 'Select a site to view analysis'],
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
    'filter_contracts': ['العقود', 'Contrats', 'Contracts'],
    'filter_pdf': ['تقارير PDF', 'Rapports PDF', 'PDF reports'],
    'filter_backup': ['النسخ الاحتياطي', 'Sauvegardes', 'Backups'],
    'no_logs_found': ['لا توجد نشاطات مسجلة حالياً', 'Aucune activité enregistrée', 'No activities recorded yet'],
    'contractor_name': ['اسم المقاول', 'Nom de l’entrepreneur', 'Contractor name'],
    'contractor_phone': ['رقم الهاتف (اختياري)', 'Téléphone', 'Phone (optional)'],
    'contract_amount': ['مبلغ العقد', 'Montant du contrat', 'Contract amount'],
    'contract_type': ['نوع العقد', 'Type de contrat', 'Contract type'],
    'contract_type_full': ['عقد كامل', 'Contrat complet', 'Full contract'],
    'contract_type_partial': ['عقد جزئي', 'Contrat partiel', 'Partial contract'],
    'contract_notes': ['ملاحظات وشروط العقد', 'Remarques & clauses', 'Contract notes & terms'],
    'save_contract': ['إبرام وحفظ العقد', 'Enregistrer le contrat', 'Sign & save contract'],
    'contract_saved': ['تم إبرام العقد وحفظه بنجاح', 'Contrat enregistré avec succès', 'Contract saved successfully'],
    'select_site_for_contract': ['اختر موقع العمل (الورشة)', 'Sélectionnez le chantier', 'Select work site'],
    'no_active_contracts': ['لا توجد عقود جارية حالياً', 'Aucun contrat en cours', 'No active contracts'],
    'no_finished_contracts': ['لا توجد عقود منتهية', 'Aucun contrat terminé', 'No finished contracts'],
    'edit_contract': ['تعديل بيانات العقد', 'Modifier le contrat', 'Edit contract'],
    'finish_contract': ['إنهاء العقد', 'Clôturer le contrat', 'Finish contract'],
    'finish_contract_confirm': ['هل تريد إنهاء هذا العقد ونقله لقائمة العقود المنتهية؟', 'Voulez-vous clôturer ce contrat ?', 'Finish and archive this contract?'],
    'contract_finished_msg': ['تم إنهاء العقد ونقله للأرشيف بنجاح', 'Contrat clôturé avec succès', 'Contract finished successfully'],
    'delete_contract': ['حذف العقد', 'Supprimer le contrat', 'Delete contract'],
    'delete_contract_confirm': ['هل أنت متأكد من حذف هذا العقد نهائياً؟', 'Supprimer définitivement ce contrat ?', 'Permanently delete this contract?'],
    'contract_deleted_msg': ['تم حذف العقد بنجاح', 'Contrat supprimé avec succès', 'Contract deleted successfully'],
    'reopen_contract': ['إعادة فتح العقد للنشط', 'Rouvrir le contrat', 'Reopen contract'],
    'reopen_contract_msg': ['تمت إعادة تفعيل العقد بنجاح', 'Contrat réactivé avec succès', 'Contract reopened successfully'],
    'share_contract_pdf': ['تصدير العقد PDF ومشاركته', 'Partager contrat PDF', 'Share contract PDF'],
    'contract_doc_title': ['وثيقة عقد عمل ومقاولة', 'Contrat de sous-traitance', 'Subcontract Agreement'],
    'contract_date': ['تاريخ الإبرام', 'Date de signature', 'Date of agreement'],
    'first_party': ['الطرف الأول (إدارة المشروع)', 'Première partie (Maître d’ouvrage)', 'First Party (Project Owner)'],
    'second_party': ['الطرف الثاني (المقاول)', 'Deuxième partie (Sous-traitant)', 'Second Party (Contractor)'],
    'signature_first': ['توقيع الطرف الأول', 'Signature 1ère partie', 'First party signature'],
    'signature_second': ['توقيع الطرف الثاني', 'Signature 2ème partie', 'Second party signature'],
  };
}

String t(String key) => L10n.t(key);

// ======================= دوال مساعدة نقية بدون أخطاء الرموز =======================

const String kLrm = '\u200E';
const String kNbsp = ' ';

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

String fmtFullDateTime(DateTime d) {
  final y = d.year.toString();
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  final ss = d.second.toString().padLeft(2, '0');
  return ltr('$day/$m/$y - $hh:$mm:$ss');
}

String plain(String s) => s.replaceAll(kLrm, '').replaceAll('\u00A0', ' ');

bool hasArabic(String text) {
  return RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]').hasMatch(text);
}

// ======================= النماذج البرمجية =======================

class ActivityLog {
  String id;
  String category; // 'payments', 'sites', 'workers', 'attendance', 'contracts', 'pdf', 'backup'
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
  List<double> paymentHistory;

  WorkSite({
    required this.id,
    required this.name,
    required this.location,
    required this.totalContractAmount,
    this.totalPaid = 0.0,
    this.isDelivered = false,
    this.deliveryNote = '',
    List<double>? paymentHistory,
  }) : paymentHistory = paymentHistory ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'totalContractAmount': totalContractAmount,
        'totalPaid': totalPaid,
        'isDelivered': isDelivered,
        'deliveryNote': deliveryNote,
        'paymentHistory': paymentHistory,
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
        paymentHistory: (json['paymentHistory'] as List?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            [],
      );
}

// نموذج عقد المقاول
class WorkContract {
  String id;
  String siteId;
  String siteName;
  String contractorName;
  String phone;
  double amount;
  String contractType; // 'عقد كامل' / 'عقد جزئي'
  String note;
  DateTime date;
  bool isFinished;

  WorkContract({
    required this.id,
    required this.siteId,
    required this.siteName,
    required this.contractorName,
    this.phone = '',
    required this.amount,
    required this.contractType,
    this.note = '',
    required this.date,
    this.isFinished = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'siteId': siteId,
        'siteName': siteName,
        'contractorName': contractorName,
        'phone': phone,
        'amount': amount,
        'contractType': contractType,
        'note': note,
        'date': date.toIso8601String(),
        'isFinished': isFinished,
      };

  factory WorkContract.fromJson(Map<String, dynamic> json) => WorkContract(
        id: (json['id'] ?? '').toString(),
        siteId: (json['siteId'] ?? '').toString(),
        siteName: (json['siteName'] ?? '').toString(),
        contractorName: (json['contractorName'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
        amount: ((json['amount'] ?? 0.0) as num).toDouble(),
        contractType: (json['contractType'] ?? 'عقد كامل').toString(),
        note: (json['note'] ?? '').toString(),
        date: json['date'] != null
            ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        isFinished: json['isFinished'] ?? false,
      );
}

// ======================= قاعدة البيانات =======================

class AppDatabase {
  static List<Worker> workers = [];
  static List<WorkSite> sites = [];
  static List<WorkContract> contracts = [];
  static List<ActivityLog> logs = [];
  static String lastPopupDate = '';
  static String? lastError;

  static ValueNotifier<String> currencyNotifier = ValueNotifier<String>('XOF');
  static String get currency => currencyNotifier.value;
  static set currency(String v) => currencyNotifier.value = v;

  static ValueNotifier<double> overtimeRateNotifier = ValueNotifier<double>(1000.0);
  static double get overtimeRate => overtimeRateNotifier.value;
  static set overtimeRate(double v) => overtimeRateNotifier.value = v;

  static List<Worker> get activeWorkers => workers.where((w) => !w.isArchived).toList();
  static List<Worker> get archivedWorkers => workers.where((w) => w.isArchived).toList();

  static List<WorkContract> get activeContracts => contracts.where((c) => !c.isFinished).toList();
  static List<WorkContract> get finishedContracts => contracts.where((c) => c.isFinished).toList();

  static List<Worker> workersForWeek(DateTime ws) {
    return workers.where((w) {
      if (!w.isArchived) return true;
      final logs = w.weekLogs(ws);
      return logs.any((l) => l != null);
    }).toList();
  }

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
      await prefs.setString('activity_logs', jsonEncode(logs.map((e) => e.toJson()).toList()));
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
      final contractsStr = prefs.getString('contracts_data');
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
        workers = decoded.map((e) => Worker.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      if (sitesStr != null) {
        final List decoded = jsonDecode(sitesStr);
        sites = decoded.map((e) => WorkSite.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      if (contractsStr != null) {
        final List decoded = jsonDecode(contractsStr);
        contracts = decoded.map((e) => WorkContract.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      if (logsStr != null) {
        final List decoded = jsonDecode(logsStr);
        logs = decoded.map((e) => ActivityLog.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      lastError = 'Load error: $e';
    }
  }

  static Future<bool> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok1 = await prefs.setString('workers_data', jsonEncode(workers.map((e) => e.toJson()).toList()));
      final ok2 = await prefs.setString('sites_data', jsonEncode(sites.map((e) => e.toJson()).toList()));
      final ok3 = await prefs.setString('contracts_data', jsonEncode(contracts.map((e) => e.toJson()).toList()));
      final ok4 = await prefs.setString('last_popup_date', lastPopupDate);
      await prefs.setString('activity_logs', jsonEncode(logs.map((e) => e.toJson()).toList()));
      await prefs.setString('app_currency', currency);
      await prefs.setDouble('app_overtime_rate', overtimeRate);

      return ok1 && ok2 && ok3 && ok4;
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
      'version': '1.3',
      'currency': currency,
      'overtimeRate': overtimeRate,
      'workers': workers.map((w) => w.toJson()).toList(),
      'sites': sites.map((s) => s.toJson()).toList(),
      'contracts': contracts.map((c) => c.toJson()).toList(),
      'logs': logs.map((l) => l.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  static Future<bool> importBackupJson(String jsonStr) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      if (data.containsKey('currency')) currency = data['currency'].toString();
      if (data.containsKey('overtimeRate')) overtimeRate = ((data['overtimeRate'] ?? 1000.0) as num).toDouble();
      if (data.containsKey('workers') && data['workers'] is List) {
        workers = (data['workers'] as List).map((e) => Worker.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      if (data.containsKey('sites') && data['sites'] is List) {
        sites = (data['sites'] as List).map((e) => WorkSite.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      if (data.containsKey('contracts') && data['contracts'] is List) {
        contracts = (data['contracts'] as List).map((e) => WorkContract.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      if (data.containsKey('logs') && data['logs'] is List) {
        logs = (data['logs'] as List).map((e) => ActivityLog.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      final ok = await saveData();
      if (ok) {
        logActivity('backup', 'استعادة نسخة احتياطية', 'تمت استعادة البيانات بنجاح من كود النسخة الاحتياطية');
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

// ======================= لوحة التحكم مع تقسيم أنيق ومحدد =======================

class MainDashboard extends StatelessWidget {
  final VoidCallback onDataUpdated;
  final VoidCallback onOpenDailyReport;
  const MainDashboard(
      {super.key,
      required this.onDataUpdated,
      required this.onOpenDailyReport});

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Color(0xFF283593)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // 1. قسم إدارة العمال
            _sectionTitle(t('section_workers'), Icons.people, Colors.indigo),
            ListTile(
              dense: true,
              leading: const Icon(Icons.today, color: Colors.indigo),
              title: Text(t('m_daily')),
              onTap: () {
                Navigator.pop(context);
                onOpenDailyReport();
              },
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.person_add, color: Colors.indigo),
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
              dense: true,
              leading: const Icon(Icons.manage_accounts, color: Colors.indigo),
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
              dense: true,
              leading: const Icon(Icons.group, color: Colors.indigo),
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

            const Divider(thickness: 1.2, height: 16),

            // 2. قسم إدارة الورش والحسابات
            _sectionTitle(t('section_sites'), Icons.apartment, Colors.orange.shade800),
            ListTile(
              dense: true,
              leading: Icon(Icons.location_city, color: Colors.orange.shade800),
              title: Text(t('m_sites')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SitesScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.task_alt, color: Colors.teal),
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
              dense: true,
              leading: Icon(Icons.analytics, color: Colors.deepPurple),
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
              dense: true,
              leading: Icon(Icons.payments, color: Colors.green.shade700),
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

            const Divider(thickness: 1.2, height: 16),

            // 3. قسم إدارة عقود المقاولين
            _sectionTitle(t('section_contracts'), Icons.history_edu, Colors.blueGrey.shade800),
            ListTile(
              dense: true,
              leading: Icon(Icons.post_add, color: Colors.blueGrey.shade800),
              title: Text(t('m_contracts_new')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewContractScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.assignment, color: Colors.blueGrey.shade800),
              title: Text(t('m_contracts_active')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ActiveContractsScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.assignment_turned_in, color: Colors.blueGrey.shade800),
              title: Text(t('m_contracts_finished')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FinishedContractsScreen()));
                onDataUpdated();
              },
            ),

            const Divider(thickness: 1.2, height: 16),

            // 4. قسم التقارير والإعدادات
            _sectionTitle(t('section_reports_settings'), Icons.tune, Colors.indigo),
            ListTile(
              dense: true,
              leading: const Icon(Icons.summarize, color: Colors.purple),
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
              dense: true,
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
            ListTile(
              dense: true,
              leading: const Icon(Icons.currency_exchange, color: Colors.indigo),
              title: Text('${t('currency')}: ${AppDatabase.currency}'),
              subtitle: Text('${t('card_hour_rate')}: ${fmtCurrency(AppDatabase.overtimeRate)}'),
              onTap: () {
                Navigator.pop(context);
                showCurrencyDialog(context, onDataUpdated);
              },
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.cloud_sync, color: Colors.teal),
              title: Text(t('backup_menu')),
              onTap: () {
                Navigator.pop(context);
                showBackupDialog(context, onDataUpdated);
              },
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.language, color: Colors.indigo),
              title: Text('${t('language')}: ${L10n.names[L10n.lang]}'),
              onTap: () {
                Navigator.pop(context);
                showLanguageDialog(context, onDataUpdated);
              },
            ),
            const SizedBox(height: 16),
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
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: onOpenDailyReport,
              icon: const Icon(Icons.today, color: Colors.white),
              label: Text(t('daily_btn'),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 14),
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
                      Colors.orange.shade800,
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
                      t('card_contracts_active'),
                      ltr('${AppDatabase.activeContracts.length}'),
                      Icons.assignment,
                      Colors.blueGrey.shade800,
                      onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ActiveContractsScreen()));
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
                      Colors.green.shade700,
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
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
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
  // يبدأ فارغاً تماماً كما طلب المستخدم
  final TextEditingController _rateController = TextEditingController();
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
                    labelText: '${t('rate_req')} (${AppDatabase.currency})',
                    hintText: 'أدخل الأجر اليومي'),
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
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
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

// ======================= مواقع العمل (الورش) مع تعديل المدفوع وإلغاء آخر دفعة =======================

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

  void _showEditSiteDialog(WorkSite site) {
    final nameCtrl = TextEditingController(text: site.name);
    final locCtrl = TextEditingController(text: site.location);
    final totalCtrl = TextEditingController(text: numStr(site.totalContractAmount));
    final paidCtrl = TextEditingController(text: numStr(site.totalPaid));
    final extraAmtCtrl = TextEditingController();
    final extraReasonCtrl = TextEditingController();

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
                      labelText: '${t('site_total')} (${AppDatabase.currency})'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // قسم تعديل المبلغ المدفوع (الواصل) وإلغاء آخر دفعة
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t('current_paid_amount'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(fmtCurrency(site.totalPaid),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: paidCtrl,
                        decoration: InputDecoration(
                          labelText: '${t('edit_paid_amount')} (${AppDatabase.currency})',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      if (site.paymentHistory.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${t('last_payment_info')}: ${fmtCurrency(site.paymentHistory.last)}',
                                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              icon: const Icon(Icons.undo, size: 16),
                              label: Text(t('undo_last_payment'), style: const TextStyle(fontSize: 12)),
                              onPressed: () {
                                final lastAmt = site.paymentHistory.removeLast();
                                site.totalPaid = (site.totalPaid - lastAmt).clamp(0.0, site.totalContractAmount);
                                paidCtrl.text = numStr(site.totalPaid);
                                setD(() {});
                                AppDatabase.logActivity('payments', 'إلغاء آخر دفعة',
                                    'ورشة ${site.name}: تم إلغاء دفعة ${fmtCurrency(lastAmt)} | الواصل الجديد: ${fmtCurrency(site.totalPaid)}');
                                AppDatabase.saveData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(t('payment_undone_msg'))),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const Divider(height: 24),
                Text(t('add_extra_amount'),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 6),
                TextField(
                  controller: extraAmtCtrl,
                  decoration: InputDecoration(
                    labelText: '${t('extra_amount_val')} (${AppDatabase.currency})',
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
                final newTotal = double.tryParse(totalCtrl.text) ?? site.totalContractAmount;
                final newPaid = double.tryParse(paidCtrl.text) ?? site.totalPaid;
                final extra = double.tryParse(extraAmtCtrl.text) ?? 0.0;
                final reason = extraReasonCtrl.text.trim();

                site.name = nameCtrl.text.trim();
                site.location = locCtrl.text.trim();
                site.totalContractAmount = newTotal;
                site.totalPaid = newPaid.clamp(0.0, newTotal);

                if (extra > 0) {
                  AppDatabase.logActivity('sites', 'زيادة مبلغ عقد الورشة',
                      'ورشة ${site.name}: إضافة ${fmtCurrency(extra)} - السبب: ${reason.isEmpty ? "أعمال إضافية" : reason}');
                } else if (newTotal != oldTotal) {
                  AppDatabase.logActivity('sites', 'تعديل قيمة العقد',
                      'ورشة ${site.name}: تعديل الإجمالي من ${fmtCurrency(oldTotal)} إلى ${fmtCurrency(newTotal)}');
                }

                Navigator.pop(dialogCtx);
                setState(() {});
                await AppDatabase.saveData();
              },
              child: Text(t('save'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDeliverSite(BuildContext context, WorkSite site) async {
    final remaining = site.totalContractAmount - site.totalPaid;
    final messenger = ScaffoldMessenger.of(context);

    if (remaining <= 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t('confirm_delivery_title')),
          content: Text("${t('confirm_delivery_paid_body')} (${site.name})"),
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

  void _deleteActiveSite(WorkSite site) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete_site_title')),
        content: Text("${t('delete_site_confirm_msg')} (${site.name})"),
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
                final remaining = site.totalContractAmount - site.totalPaid;
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(site.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "${t('site_address')}: ${site.location} | ${t('total')}: ${fmtCurrency(site.totalContractAmount)} | ${t('received')}: ${fmtCurrency(site.totalPaid)} | ${t('remaining')}: ${fmtCurrency(remaining)}"),
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

// قائمة الورش المسلمة مع خيار الحذف وزر إعادة الفتح
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
        content: Text("${t('reopen_confirm_msg')} (${site.name})"),
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
        content: Text("${t('delete_delivered_confirm_msg')} (${site.name})"),
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
                final remaining = site.totalContractAmount - site.totalPaid;
                return Card(
                  margin: const EdgeInsets.all(8),
                  color: Colors.grey.shade100,
                  child: ListTile(
                    title: Text(site.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough)),
                    subtitle: Text(
                        "${t('site_address')}: ${site.location} | ${t('contract_total')}: ${fmtCurrency(site.totalContractAmount)} | ${t('received')}: ${fmtCurrency(site.totalPaid)}${remaining > 0 ? ' | ' + t('remaining') + ': ' + fmtCurrency(remaining) : ''} (${t('delivered_flag')})${site.deliveryNote.isNotEmpty ? ' | ' + t('delivery_note_prefix') + ': ' + site.deliveryNote : ''}"),
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

// ======================= إدارة الدفعات مع فحص المتبقي وبدء الحقل فارغاً =======================

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

    // الحقل يبدأ فارغاً تماماً كما طلب المستخدم بدلاً من كتابة المتبقي تلقائياً
    final paymentController = TextEditingController();
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
                autofocus: true,
                decoration: InputDecoration(
                  labelText: '${t('new_payment')} (${AppDatabase.currency})',
                  hintText: 'أدخل قيمة الدفعة',
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
                site.paymentHistory.add(payment);
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

// ======================= نظام إدارة عقود المقاولين =======================

// 1. إبرام عقد جديد
class NewContractScreen extends StatefulWidget {
  const NewContractScreen({super.key});

  @override
  State<NewContractScreen> createState() => _NewContractScreenState();
}

class _NewContractScreenState extends State<NewContractScreen> {
  WorkSite? _selectedSite;
  final _formKey = GlobalKey<FormState>();
  final _contractorController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _contractType = 'عقد كامل';

  @override
  void initState() {
    super.initState();
    if (AppDatabase.sites.isNotEmpty) {
      _selectedSite = AppDatabase.sites.first;
    }
  }

  @override
  void dispose() {
    _contractorController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppDatabase.sites.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            title: Text(t('m_contracts_new')),
            backgroundColor: Colors.indigo,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(child: Text(t('no_active_sites'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(t('m_contracts_new')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // اختيار الورشة
              Text(t('select_site_for_contract'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Card(
                color: Colors.indigo.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<WorkSite>(
                      isExpanded: true,
                      value: _selectedSite,
                      items: AppDatabase.sites.map((s) {
                        return DropdownMenuItem<WorkSite>(
                          value: s,
                          child: Text('${s.name} (${s.location})',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSite = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _contractorController,
                decoration: InputDecoration(
                  labelText: t('contractor_name'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'يرجى إدخال اسم المقاول' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: t('contractor_phone'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: '${t('contract_amount')} (${AppDatabase.currency})',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'يرجى إدخال مبلغ العقد' : null,
              ),
              const SizedBox(height: 14),

              // نوع العقد (كامل أو جزئي)
              Text(t('contract_type'), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(t('contract_type_full')),
                      value: 'عقد كامل',
                      groupValue: _contractType,
                      onChanged: (v) => setState(() => _contractType = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text(t('contract_type_partial')),
                      value: 'عقد جزئي',
                      groupValue: _contractType,
                      onChanged: (v) => setState(() => _contractType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: t('contract_notes'),
                  hintText: 'مثال: يشمل توريد وتركيب الرخام خلال 30 يوماً',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.history_edu, color: Colors.white),
                label: Text(t('save_contract'),
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _selectedSite != null) {
                    final contractor = _contractorController.text.trim();
                    final amt = double.tryParse(_amountController.text) ?? 0.0;
                    final contract = WorkContract(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      siteId: _selectedSite!.id,
                      siteName: _selectedSite!.name,
                      contractorName: contractor,
                      phone: _phoneController.text.trim(),
                      amount: amt,
                      contractType: _contractType,
                      note: _noteController.text.trim(),
                      date: DateTime.now(),
                    );
                    AppDatabase.contracts.add(contract);
                    AppDatabase.logActivity('contracts', 'إبرام عقد جديد',
                        'عقد مع المقاول $contractor لورشة ${_selectedSite!.name} بقيمة ${fmtCurrency(amt)} (${_contractType})');
                    await AppDatabase.saveData();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t('contract_saved'))),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. قائمة العقود الحالية مع التعديل والتصدير والإنهاء والحذف
class ActiveContractsScreen extends StatefulWidget {
  const ActiveContractsScreen({super.key});

  @override
  State<ActiveContractsScreen> createState() => _ActiveContractsScreenState();
}

class _ActiveContractsScreenState extends State<ActiveContractsScreen> {
  void _editContract(WorkContract contract) {
    final contractorCtrl = TextEditingController(text: contract.contractorName);
    final phoneCtrl = TextEditingController(text: contract.phone);
    final amountCtrl = TextEditingController(text: numStr(contract.amount));
    final noteCtrl = TextEditingController(text: contract.note);
    String type = contract.contractType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setD) => AlertDialog(
          title: Text(t('edit_contract')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: contractorCtrl, decoration: InputDecoration(labelText: t('contractor_name'))),
                TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: t('contractor_phone'))),
                TextField(controller: amountCtrl, decoration: InputDecoration(labelText: '${t('contract_amount')} (${AppDatabase.currency})'), keyboardType: TextInputType.number),
                Row(
                  children: [
                    Radio<String>(value: 'عقد كامل', groupValue: type, onChanged: (v) => setD(() => type = v!)),
                    Text(t('contract_type_full')),
                    Radio<String>(value: 'عقد جزئي', groupValue: type, onChanged: (v) => setD(() => type = v!)),
                    Text(t('contract_type_partial')),
                  ],
                ),
                TextField(controller: noteCtrl, maxLines: 2, decoration: InputDecoration(labelText: t('contract_notes'))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(t('cancel'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () async {
                contract.contractorName = contractorCtrl.text.trim();
                contract.phone = phoneCtrl.text.trim();
                contract.amount = double.tryParse(amountCtrl.text) ?? contract.amount;
                contract.contractType = type;
                contract.note = noteCtrl.text.trim();
                AppDatabase.logActivity('contracts', 'تعديل عقد', 'تم تعديل بيانات عقد المقاول ${contract.contractorName}');
                Navigator.pop(dialogCtx);
                setState(() {});
                await AppDatabase.saveData();
              },
              child: Text(t('save'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _finishContract(WorkContract contract) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('finish_contract')),
        content: Text(t('finish_contract_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('confirm'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => contract.isFinished = true);
      AppDatabase.logActivity('contracts', 'إنهاء عقد مقاولة', 'تم إنهاء عقد المقاول ${contract.contractorName} لورشة ${contract.siteName}');
      await AppDatabase.saveData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('contract_finished_msg'))));
    }
  }

  void _deleteContract(WorkContract contract) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete_contract')),
        content: Text(t('delete_contract_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('confirm'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => AppDatabase.contracts.removeWhere((c) => c.id == contract.id));
      AppDatabase.logActivity('contracts', 'حذف عقد', 'تم حذف عقد المقاول ${contract.contractorName} نهائياً');
      await AppDatabase.saveData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('contract_deleted_msg'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = AppDatabase.activeContracts;

    return Scaffold(
      appBar: AppBar(
          title: Text(t('m_contracts_active')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: active.isEmpty
          ? Center(child: Text(t('no_active_contracts')))
          : ListView.builder(
              itemCount: active.length,
              itemBuilder: (ctx, idx) {
                final c = active[idx];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(c.contractorName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Chip(
                              label: Text(c.contractType, style: const TextStyle(fontSize: 11, color: Colors.indigo)),
                              backgroundColor: Colors.indigo.shade50,
                            ),
                          ],
                        ),
                        Text('${t('site')}: ${c.siteName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${t('contract_amount')}: ${fmtCurrency(c.amount)}',
                            style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                        if (c.phone.isNotEmpty) Text('${t('phone')}: ${ltr(c.phone)}'),
                        Text('${t('contract_date')}: ${fmtDate(c.date)}'),
                        if (c.note.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('📌 ${c.note}', style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                        ],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.indigo),
                              tooltip: t('share_contract_pdf'),
                              onPressed: () => shareContractPdf(context, c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.indigo),
                              tooltip: t('edit_contract'),
                              onPressed: () => _editContract(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline, color: Colors.teal),
                              tooltip: t('finish_contract'),
                              onPressed: () => _finishContract(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: t('delete_contract'),
                              onPressed: () => _deleteContract(c),
                            ),
                          ],
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

// 3. قائمة العقود المنتهية
class FinishedContractsScreen extends StatefulWidget {
  const FinishedContractsScreen({super.key});

  @override
  State<FinishedContractsScreen> createState() => _FinishedContractsScreenState();
}

class _FinishedContractsScreenState extends State<FinishedContractsScreen> {
  void _reopen(WorkContract contract) async {
    setState(() => contract.isFinished = false);
    AppDatabase.logActivity('contracts', 'إعادة تفعيل عقد', 'تمت إعادة فتح عقد المقاول ${contract.contractorName}');
    await AppDatabase.saveData();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('reopen_contract_msg'))));
  }

  void _delete(WorkContract contract) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete_contract')),
        content: Text(t('delete_contract_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('confirm'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => AppDatabase.contracts.removeWhere((c) => c.id == contract.id));
      AppDatabase.logActivity('contracts', 'حذف عقد منتهي', 'تم حذف العقد المنتهي للمقاول ${contract.contractorName}');
      await AppDatabase.saveData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('contract_deleted_msg'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final finished = AppDatabase.finishedContracts;

    return Scaffold(
      appBar: AppBar(
          title: Text(t('m_contracts_finished')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: finished.isEmpty
          ? Center(child: Text(t('no_finished_contracts')))
          : ListView.builder(
              itemCount: finished.length,
              itemBuilder: (ctx, idx) {
                final c = finished[idx];
                return Card(
                  margin: const EdgeInsets.all(8),
                  color: Colors.grey.shade100,
                  child: ListTile(
                    title: Text(c.contractorName, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
                    subtitle: Text('${t('site')}: ${c.siteName} | ${t('contract_amount')}: ${fmtCurrency(c.amount)}\n${c.contractType} (${fmtDate(c.date)})'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay, color: Colors.indigo),
                          tooltip: t('reopen_contract'),
                          onPressed: () => _reopen(c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          tooltip: t('delete_contract'),
                          onPressed: () => _delete(c),
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
                                '${s.name} ${s.isDelivered ? "($${t('delivered_flag')})" : ""}',
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
            Text(t('site_worker_breakdown'),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo)),
            const SizedBox(height: 8),
            workerBreakdown.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
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

// ======================= سجل الحركات والنشاطات =======================

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
      case 'contracts':
        return Colors.blueGrey.shade800;
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
      case 'contracts':
        return Icons.assignment;
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _filterChip('all', t('filter_all')),
                _filterChip('payments', t('filter_payments')),
                _filterChip('sites', t('filter_sites')),
                _filterChip('contracts', t('filter_contracts')),
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

// ======================= قائمة العمال وتعديلهم =======================

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

// ---------- محرك إنشاء الـ PDF مع خط ثنائي مدمج (عربي ولاتيني) بدون إنترنت نهائياً ----------

const String _kArabicFontGzB64 = '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';

bool gPdfFontFailed = false;

Future<pw.Document> _newPdf() async {
  gPdfFontFailed = false;
  pw.Font? regular;

  // 1. الخط الثنائي المدمج مباشرة بالكود (يدعم العربية والحروف اللاتينية الفرنسية والإنجليزية والأرقام)
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
        gPdfFontFailed = true;
      }
    }
  }

  if (regular != null) {
    return pw.Document(
      theme: pw.ThemeData.withFont(
        base: regular,
        bold: regular,
        fontFallback: [regular, pw.Font.helvetica()],
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
        _pdfCell(log != null && log.worked ? fmtNum(log.overtimeHours) : '-', numeric: true),
        _pdfCell(log != null && log.worked ? fmtMoney(log.transport) : '-', numeric: true),
        _pdfCell(log == null ? '-' : fmtMoney(log.total(w.dailyRate)), numeric: true),
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
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _pdfLine(tr('week'), '${fmtDate(ws)} - ${fmtDate(addDays(ws, 6))}', rtl: rtl),
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

  await Printing.sharePdf(bytes: await pdf.save(), filename: 'report_${w.name}.pdf');
}

Future<void> shareAllWeekPdf(
    BuildContext context, DateTime ws, String lang) async {
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
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _pdfLine(tr('week'), '${fmtDate(ws)} - ${fmtDate(addDays(ws, 6))}', rtl: rtl),
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
}

// تصدير ومشاركة عقد المقاول كـ PDF رسمي
Future<void> shareContractPdf(BuildContext context, WorkContract c) async {
  final pdf = await _newPdf();

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                pw.Text(t('contract_doc_title'),
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('${t('contract_date')}: ${fmtFullDate(c.date)}',
                    textDirection: pw.TextDirection.rtl,
                    style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          pw.Text('${t('first_party')}: إدارة مشروع WookFlow',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text('${t('second_party')}: ${c.contractorName} ${c.phone.isNotEmpty ? "(${c.phone})" : ""}',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Divider(),

          pw.SizedBox(height: 8),
          _pdfLine(t('site'), c.siteName, rtl: true, big: true),
          _pdfLine(t('contract_type'), c.contractType, rtl: true),
          _pdfLine(t('contract_amount'), fmtCurrency(c.amount), rtl: true, big: true),
          pw.SizedBox(height: 12),

          if (c.note.isNotEmpty) ...[
            pw.Text('${t('contract_notes')}:',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
              child: pw.Text(c.note,
                  textDirection: pw.TextDirection.rtl,
                  style: const pw.TextStyle(fontSize: 11)),
            ),
            pw.SizedBox(height: 24),
          ],

          pw.Spacer(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Text(t('signature_second'), textDirection: pw.TextDirection.rtl),
                  pw.SizedBox(height: 40),
                  pw.Text('................................', textDirection: pw.TextDirection.rtl),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(t('signature_first'), textDirection: pw.TextDirection.rtl),
                  pw.SizedBox(height: 40),
                  pw.Text('................................', textDirection: pw.TextDirection.rtl),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );

  AppDatabase.logActivity('contracts', 'تصدير عقد مقاول PDF',
      'تم تصدير وثيقة عقد المقاول ${c.contractorName} لورشة ${c.siteName}');

  await Printing.sharePdf(bytes: await pdf.save(), filename: 'contract_${c.contractorName}.pdf');
}

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
