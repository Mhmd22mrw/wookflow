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
    'version': ['نظام إدارة المشاريع v1.4.0', 'Gestion de projets v1.4.0', 'Project management v1.4.0'],
    'language': ['اللغة', 'Langue', 'Language'],
    'report_lang': ['لغة التقرير', 'Langue du rapport', 'Report language'],
    'm_daily': ['التقرير اليومي (حضور اليوم)', 'Rapport journalier (présence)', 'Daily report (attendance)'],
    'm_add_worker': ['إضافة عامل جديد', 'Ajouter un ouvrier', 'Add worker'],
    'm_delete_worker': ['إدارة وأرشفة العمال', 'Gérer / archiver ouvriers', 'Manage / archive workers'],
    'm_worker_advance': ['تقديم سلفة لعامل', 'Avance sur salaire', 'Worker advance'],
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
    'card_advances': ['سلف العمال', 'Avances ouvriers', 'Worker advances'],
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
    'received': ['الواصل (المقبوض)', 'Reçu (Encaissé)', 'Received'],
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
    'gross_total': ['إجمالي المستحق', 'Total brut', 'Gross total'],
    'total_advances': ['مجموع السلف', 'Total des avances', 'Total advances'],
    'advances_deducted': ['خصم السلف', 'Déduction avances', 'Advances deduction'],
    'net_total': ['صافي الراتب المستحق', 'Net à payer', 'Net payable'],
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
    'filter_advances': ['سلف العمال', 'Avances', 'Advances'],
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
    'add_contract_payment': ['تسديد دفعة للمقاول', 'Payer un acompte au sous-traitant', 'Pay contractor installment'],
    'contract_paid': ['الواصل للمقاول', 'Acomptes versés', 'Paid to contractor'],
    'contract_remaining': ['المتبقي للمقاول', 'Reste à payer', 'Remaining to contractor'],
    'contract_already_paid': ['تم سداد كامل قيمة العقد، لا يوجد متبقي لإضافة دفعات', 'Le contrat est déjà entièrement payé', 'Contract already fully paid, no remaining balance'],
    'contract_payment_saved': ['تم تسجيل دفعة المقاول بنجاح', 'Paiement au sous-traitant enregistré', 'Contractor payment recorded successfully'],
    'last_contract_payment': ['آخر دفعة للمقاول', 'Dernier versement au sous-traitant', 'Last contractor payment'],
    'undo_contract_payment': ['إلغاء آخر دفعة للمقاول', 'Annuler dernier versement', 'Undo last contractor payment'],
    'contract_payment_undone': ['تم إلغاء آخر دفعة بنجاح وتعديل رصيد العقد', 'Dernier versement annulé avec succès', 'Last payment undone successfully'],
    'contract_finish_unpaid_warning': ['تنبيه: يوجد متبقي غير مسدد للمقاول، هل تريد سداد المتبقي الآن أم إنهاء العقد بالرصيد الحالي؟', 'Attention : Solde impayé. Solder maintenant ou clôturer ?', 'Warning: Unpaid balance remaining. Settle now or finish with current balance?'],
    'worker_advances_title': ['سلف ودفعات العمال', 'Avances sur salaire des ouvriers', 'Worker advances on wages'],
    'give_advance': ['تقديم سلفة', 'Donner une avance', 'Give advance'],
    'advance_amount': ['قيمة السلفة', 'Montant de l’avance', 'Advance amount'],
    'advance_date': ['تاريخ السلفة', 'Date de l’avance', 'Advance date'],
    'advance_note': ['ملاحظة / سبب السلفة (اختياري)', 'Motif de l’avance (facultatif)', 'Advance note (optional)'],
    'save_advance_finish': ['إنهاء وحفظ السلفة', 'Enregistrer et terminer', 'Finish & save advance'],
    'advance_saved_ok': ['تم تسجيل السلفة وخصمها من الحساب بنجاح', 'Avance enregistrée et déduite', 'Advance recorded and deducted successfully'],
    'no_advances': ['لا توجد سلف مسجلة لهذا العامل', 'Aucune avance enregistrée', 'No advances recorded for this worker'],
    'delete_advance': ['حذف السلفة', 'Supprimer l’avance', 'Delete advance'],
    'delete_advance_confirm': ['هل تريد حذف هذه السلفة وإلغاء خصمها؟', 'Voulez-vous annuler et supprimer cette avance ?', 'Delete and restore this advance?'],
    'advance_deleted_msg': ['تم حذف السلفة بنجاح', 'Avance supprimée avec succès', 'Advance deleted successfully'],
    'select_worker_for_advance': ['اختر العامل لتقديم سلفة:', 'Sélectionnez un ouvrier pour l’avance :', 'Select worker for advance:'],
    'enter_advance_amount': ['يرجى إدخال مبلغ السلفة', 'Veuillez saisir le montant de l’avance', 'Please enter advance amount'],
    'advances_history': ['سجل السلف السابقة', 'Historique des avances', 'Advances history'],
    'site_kpi_total_costs': ['إجمالي التكاليف (عمال + مقاولين)', 'Coût total (ouvriers + sous-traitants)', 'Total costs (labor + subcontractors)'],
    'site_kpi_contractors_cost': ['عقود المقاولين', 'Contrats sous-traitants', 'Subcontractors contracts'],
    'site_kpi_contractors_paid': ['المدفوع للمقاولين', 'Payé aux sous-traitants', 'Paid to subcontractors'],
    'site_kpi_contractors_remaining': ['المتبقي للمقاولين', 'Reste aux sous-traitants', 'Remaining to subcontractors'],
    'site_contractors_breakdown': ['تفاصيل عقود مقاولي هذه الورشة', 'Détail des sous-traitants du chantier', 'Site subcontractors breakdown'],
    'no_contracts_for_site': ['لا توجد عقود مقاولين مسجلة لهذه الورشة بعد.', 'Aucun contrat sous-traitant pour ce chantier.', 'No subcontractor contracts for this site yet.'],
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

class WorkerAdvance {
  String id;
  DateTime date;
  double amount;
  String note;

  WorkerAdvance({
    required this.id,
    required this.date,
    required this.amount,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'note': note,
      };

  factory WorkerAdvance.fromJson(Map<String, dynamic> json) => WorkerAdvance(
        id: (json['id'] ?? '').toString(),
        date: json['date'] != null
            ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        amount: ((json['amount'] ?? 0.0) as num).toDouble(),
        note: (json['note'] ?? '').toString(),
      );
}

class ActivityLog {
  String id;
  String category; // 'payments', 'advances', 'sites', 'workers', 'attendance', 'contracts', 'pdf', 'backup'
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
  List<WorkerAdvance> advances;

  Worker({
    required this.id,
    required this.name,
    required this.dailyRate,
    this.phone = '',
    this.isArchived = false,
    Map<String, DayLog>? logs,
    List<WorkerAdvance>? advances,
  })  : logs = logs ?? {},
        advances = advances ?? [];

  DayLog? logFor(DateTime d) => logs[dateKey(d)];

  List<DayLog?> weekLogs(DateTime weekStart) =>
      List.generate(7, (i) => logs[dateKey(addDays(weekStart, i))]);

  List<WorkerAdvance> weekAdvances(DateTime weekStart) {
    final ws = dateOnly(weekStart);
    final we = addDays(ws, 6);
    return advances.where((a) {
      final d = dateOnly(a.date);
      return (d.isAtSameMomentAs(ws) || d.isAfter(ws)) &&
          (d.isAtSameMomentAs(we) || d.isBefore(we));
    }).toList();
  }

  double weekAdvancesTotal(DateTime weekStart) =>
      weekAdvances(weekStart).fold<double>(0.0, (s, a) => s + a.amount);

  double weekGrossTotal(DateTime weekStart) => weekLogs(weekStart)
      .fold<double>(0.0, (s, l) => s + (l?.total(dailyRate) ?? 0.0));

  double weekNetTotal(DateTime weekStart) =>
      weekGrossTotal(weekStart) - weekAdvancesTotal(weekStart);

  double weekTotal(DateTime weekStart) => weekNetTotal(weekStart);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dailyRate': dailyRate,
        'phone': phone,
        'isArchived': isArchived,
        'logs': logs.map((k, v) => MapEntry(k, v.toJson())),
        'advances': advances.map((a) => a.toJson()).toList(),
      };

  factory Worker.fromJson(Map<String, dynamic> json) {
    final logs = <String, DayLog>{};
    final raw = json['logs'];
    if (raw is Map) {
      raw.forEach((k, v) {
        logs[k.toString()] = DayLog.fromJson(Map<String, dynamic>.from(v));
      });
    }
    final advList = <WorkerAdvance>[];
    final rawAdv = json['advances'];
    if (rawAdv is List) {
      for (final a in rawAdv) {
        if (a is Map) {
          advList.add(WorkerAdvance.fromJson(Map<String, dynamic>.from(a)));
        }
      }
    }
    return Worker(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      dailyRate: ((json['dailyRate'] ?? 0.0) as num).toDouble(),
      phone: (json['phone'] ?? '').toString(),
      isArchived: json['isArchived'] ?? false,
      logs: logs,
      advances: advList,
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
  double totalPaid;
  List<double> paymentHistory;

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
    this.totalPaid = 0.0,
    List<double>? paymentHistory,
  }) : paymentHistory = paymentHistory ?? [];

  double get remaining => (amount - totalPaid).clamp(0.0, double.infinity);

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
        'totalPaid': totalPaid,
        'paymentHistory': paymentHistory,
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
        totalPaid: ((json['totalPaid'] ?? 0.0) as num).toDouble(),
        paymentHistory: (json['paymentHistory'] as List?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            [],
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
      final hasLogs = logs.any((l) => l != null);
      final hasAdvs = w.weekAdvances(ws).isNotEmpty;
      return hasLogs || hasAdvs;
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
      'version': '1.4',
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
              leading: const Icon(Icons.price_change, color: Colors.deepOrange),
              title: Text(t('m_worker_advance')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WorkerAdvancesScreen()));
                onDataUpdated();
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
                      t('card_advances'),
                      t('give_advance'),
                      Icons.price_change,
                      Colors.deepOrange,
                      onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WorkerAdvancesScreen()));
                    onDataUpdated();
                  }),
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

// ======================= شاشة سلف ودفعات العمال =======================

class WorkerAdvancesScreen extends StatefulWidget {
  const WorkerAdvancesScreen({super.key});

  @override
  State<WorkerAdvancesScreen> createState() => _WorkerAdvancesScreenState();
}

class _WorkerAdvancesScreenState extends State<WorkerAdvancesScreen> {
  void _openGiveAdvanceDialog(Worker worker) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime advanceDate = dateOnly(DateTime.now());

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.price_change, color: Colors.deepOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${t('give_advance')}: ${worker.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${t('daily_wage')}: ${fmtCurrency(worker.dailyRate)}'),
                      Text('${t('advance_date')}: ${fmtDate(advanceDate)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '${t('advance_amount')} (${AppDatabase.currency})',
                    hintText: t('enter_advance_amount'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.monetization_on, color: Colors.deepOrange),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: t('advance_note'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                  ),
                ),
                if (worker.advances.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(t('advances_history'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 140),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: worker.advances.length,
                      itemBuilder: (context, idx) {
                        final adv = worker.advances[worker.advances.length - 1 - idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${fmtDate(adv.date)}: ${fmtCurrency(adv.amount)}${adv.note.isNotEmpty ? " (${adv.note})" : ""}',
                                  style: const TextStyle(fontSize: 12)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                tooltip: t('delete_advance'),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: Text(t('delete_advance')),
                                      content: Text(t('delete_advance_confirm')),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('cancel'))),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.pop(c, true),
                                          child: Text(t('confirm'), style: const TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    worker.advances.removeWhere((a) => a.id == adv.id);
                                    AppDatabase.logActivity('advances', 'حذف سلفة عامل',
                                        '${worker.name}: تم حذف سلفة ${fmtCurrency(adv.amount)} المؤرخة ${fmtDate(adv.date)}');
                                    await AppDatabase.saveData();
                                    setD(() {});
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(t('cancel')),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(t('save_advance_finish'),
                  style: const TextStyle(color: Colors.white)),
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                if (amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t('enter_advance_amount'))),
                  );
                  return;
                }
                final newAdv = WorkerAdvance(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: advanceDate,
                  amount: amt,
                  note: noteCtrl.text.trim(),
                );
                worker.advances.add(newAdv);
                AppDatabase.logActivity('advances', 'تقديم سلفة لعامل',
                    '${worker.name}: تم تقديم سلفة بقيمة ${fmtCurrency(amt)}${noteCtrl.text.trim().isNotEmpty ? " (" + noteCtrl.text.trim() + ")" : ""}');
                Navigator.pop(dialogCtx);
                setState(() {});
                await AppDatabase.saveData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('advance_saved_ok'))),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkers = AppDatabase.activeWorkers;
    final currentWeek = weekStartOf(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(t('worker_advances_title')),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: activeWorkers.isEmpty
          ? Center(child: Text(t('no_active_workers')))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.deepOrange.shade50,
                  width: double.infinity,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t('select_worker_for_advance'),
                          style: TextStyle(
                              color: Colors.deepOrange.shade900,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: activeWorkers.length,
                    itemBuilder: (ctx, idx) {
                      final worker = activeWorkers[idx];
                      final weekAdv = worker.weekAdvancesTotal(currentWeek);
                      final totalAdv = worker.advances.fold<double>(0.0, (s, a) => s + a.amount);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepOrange.shade100,
                            child: const Icon(Icons.person, color: Colors.deepOrange),
                          ),
                          title: Text(worker.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${t('daily_wage')}: ${fmtCurrency(worker.dailyRate)}\n${t('card_weekly')} (${t('total_advances')}): ${fmtCurrency(weekAdv)} | ${t('total')}: ${fmtCurrency(totalAdv)}'),
                          isThreeLine: true,
                          trailing: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: Text(t('give_advance')),
                            onPressed: () => _openGiveAdvanceDialog(worker),
                          ),
                          onTap: () => _openGiveAdvanceDialog(worker),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

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


// ======================= مواقع العمل (الورش) =======================

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

// ======================= إدارة دفعات الورش =======================

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

class ActiveContractsScreen extends StatefulWidget {
  const ActiveContractsScreen({super.key});

  @override
  State<ActiveContractsScreen> createState() => _ActiveContractsScreenState();
}

class _ActiveContractsScreenState extends State<ActiveContractsScreen> {
  void _showContractPaymentDialog(WorkContract contract) {
    final remaining = contract.remaining;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('contract_already_paid'))),
      );
      return;
    }

    final paymentCtrl = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.payments, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${t('add_contract_payment')} - ${contract.contractorName}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t('site')}: ${contract.siteName}'),
                Text('${t('contract_amount')}: ${fmtCurrency(contract.amount)}'),
                Text('${t('contract_paid')}: ${fmtCurrency(contract.totalPaid)}'),
                Text('${t('contract_remaining')}: ${fmtCurrency(remaining)}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: paymentCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '${t('new_payment')} (${AppDatabase.currency})',
                    hintText: 'أدخل قيمة الدفعة',
                    errorText: errorText,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.monetization_on, color: Colors.green),
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
                        paymentCtrl.text = numStr(remaining);
                        errorText = null;
                      });
                    },
                  ),
                ),
                if (contract.paymentHistory.isNotEmpty) ...[
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${t('last_contract_payment')}: ${fmtCurrency(contract.paymentHistory.last)}',
                          style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        icon: const Icon(Icons.undo, size: 16),
                        label: Text(t('undo_contract_payment'), style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          final lastAmt = contract.paymentHistory.removeLast();
                          contract.totalPaid = (contract.totalPaid - lastAmt).clamp(0.0, contract.amount);
                          paymentCtrl.text = '';
                          setD(() {});
                          AppDatabase.logActivity('contracts', 'إلغاء دفعة مقاول',
                              'عقد ${contract.contractorName} (${contract.siteName}): تم إلغاء دفعة ${fmtCurrency(lastAmt)} | المدفوع: ${fmtCurrency(contract.totalPaid)}');
                          AppDatabase.saveData();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t('contract_payment_undone'))),
                          );
                        },
                      ),
                    ],
                  ),
                ],
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
                final payment = double.tryParse(paymentCtrl.text) ?? 0.0;
                if (payment <= 0) {
                  setD(() => errorText = t('invalid_payment_amount'));
                  return;
                }
                if (payment > remaining) {
                  setD(() => errorText =
                      '${t('payment_exceeds_remaining')} (${fmtCurrency(remaining)})');
                  return;
                }

                contract.totalPaid += payment;
                contract.paymentHistory.add(payment);
                AppDatabase.logActivity('contracts', 'تسديد دفعة للمقاول',
                    'عقد ${contract.contractorName} (${contract.siteName}): دفعة ${fmtCurrency(payment)} | الواصل: ${fmtCurrency(contract.totalPaid)} | المتبقي: ${fmtCurrency(contract.remaining)}');
                Navigator.pop(dialogCtx);
                setState(() {});
                await AppDatabase.saveData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('contract_payment_saved'))),
                );
              },
              child: Text(t('save'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _editContract(WorkContract contract) {
    final contractorCtrl = TextEditingController(text: contract.contractorName);
    final phoneCtrl = TextEditingController(text: contract.phone);
    final amountCtrl = TextEditingController(text: numStr(contract.amount));
    final paidCtrl = TextEditingController(text: numStr(contract.totalPaid));
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
                TextField(controller: paidCtrl, decoration: InputDecoration(labelText: '${t('contract_paid')} (${AppDatabase.currency})'), keyboardType: TextInputType.number),
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
                contract.totalPaid = (double.tryParse(paidCtrl.text) ?? contract.totalPaid).clamp(0.0, contract.amount);
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
    final remaining = contract.remaining;
    if (remaining > 0) {
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t('finish_contract')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('contract_finish_unpaid_warning')),
              const SizedBox(height: 8),
              Text('${t('contract_remaining')}: ${fmtCurrency(remaining)}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, 'cancel'), child: Text(t('cancel'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(ctx, 'settle'),
              child: Text(t('settle_and_finish'), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => Navigator.pop(ctx, 'keep'),
              child: Text(t('finish_with_remaining'), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
      );

      if (choice == 'settle') {
        contract.totalPaid = contract.amount;
        contract.isFinished = true;
        AppDatabase.logActivity('contracts', 'إنهاء عقد وسداد المتبقي',
            'تم تسديد كامل متبقي عقد المقاول ${contract.contractorName} (${fmtCurrency(remaining)}) وإنهاؤه');
        await AppDatabase.saveData();
        setState(() {});
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('contract_finished_msg'))));
      } else if (choice == 'keep') {
        contract.isFinished = true;
        AppDatabase.logActivity('contracts', 'إنهاء عقد مع رصيد متبقي',
            'تم إنهاء عقد المقاول ${contract.contractorName} مع بقاء رصيد غير مسدد ${fmtCurrency(remaining)}');
        await AppDatabase.saveData();
        setState(() {});
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('contract_finished_msg'))));
      }
    } else {
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
                final remaining = c.remaining;
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${t('contract_amount')}: ${fmtCurrency(c.amount)}',
                                style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                            Text('${t('contract_paid')}: ${fmtCurrency(c.totalPaid)}',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${t('contract_remaining')}: ${fmtCurrency(remaining)}',
                          style: TextStyle(
                            color: remaining > 0 ? Colors.red : Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                              icon: const Icon(Icons.add_card, color: Colors.green),
                              tooltip: t('add_contract_payment'),
                              onPressed: () => _showContractPaymentDialog(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.indigo),
                              tooltip: t('share_contract_pdf'),
                              onPressed: () async {
                                final rl = await pickReportLang(context);
                                if (rl == null || !mounted) return;
                                await shareContractPdf(context, c, rl);
                              },
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
                final remaining = c.remaining;
                return Card(
                  margin: const EdgeInsets.all(8),
                  color: Colors.grey.shade100,
                  child: ListTile(
                    title: Text(c.contractorName, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
                    subtitle: Text('${t('site')}: ${c.siteName} | ${t('contract_amount')}: ${fmtCurrency(c.amount)} | ${t('contract_paid')}: ${fmtCurrency(c.totalPaid)}${remaining > 0 ? " | " + t('contract_remaining') + ": " + fmtCurrency(remaining) : ""}\n${c.contractType} (${fmtDate(c.date)})'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.indigo),
                          tooltip: t('share_contract_pdf'),
                          onPressed: () async {
                            final rl = await pickReportLang(context);
                            if (rl == null || !mounted) return;
                            await shareContractPdf(context, c, rl);
                          },
                        ),
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

    // عقود المقاولين المرتبطة بهذه الورشة
    final siteContracts = AppDatabase.contracts
        .where((c) => c.siteId == site.id || c.siteName == site.name)
        .toList();
    final double totalContractsAmount =
        siteContracts.fold<double>(0.0, (sum, c) => sum + c.amount);
    final double totalContractsPaid =
        siteContracts.fold<double>(0.0, (sum, c) => sum + c.totalPaid);
    final double totalContractsRemaining =
        (totalContractsAmount - totalContractsPaid).clamp(0.0, double.infinity);

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
    final totalSiteCostExpected = laborCost + totalContractsAmount;
    final totalSiteCostPaidActual = laborCost + totalContractsPaid;

    final expectedNetProfit = contractTotal - totalSiteCostExpected;
    final realCurrentProfit = received - totalSiteCostPaidActual;

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
              if (siteContracts.isNotEmpty) {
                sb.writeln('📋 ${t('site_kpi_contractors_cost')}: ${fmtCurrency(totalContractsAmount)} (${t('received')}: ${fmtCurrency(totalContractsPaid)})');
              }
              sb.writeln('📦 ${t('site_kpi_total_costs')}: ${fmtCurrency(totalSiteCostExpected)}');
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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                _kpiCard(t('site_kpi_contract'), fmtCurrency(contractTotal),
                    Colors.indigo, Icons.account_balance),
                _kpiCard(t('site_kpi_received'), fmtCurrency(received),
                    Colors.teal, Icons.payments),
                _kpiCard(t('site_kpi_remaining'), fmtCurrency(remaining),
                    remaining > 0 ? Colors.red : Colors.green, Icons.pending),
                _kpiCard(t('site_kpi_total_costs'), fmtCurrency(totalSiteCostExpected),
                    Colors.deepOrange.shade800, Icons.monetization_on),
                _kpiCard(t('site_kpi_cost'), fmtCurrency(laborCost),
                    Colors.orange.shade800, Icons.engineering),
                _kpiCard(t('site_kpi_contractors_cost'), fmtCurrency(totalContractsAmount),
                    Colors.blueGrey.shade800, Icons.history_edu),
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
                    if (siteContracts.isNotEmpty) ...[
                      const Divider(height: 12),
                      _metricRow(t('site_kpi_contractors_paid'), fmtCurrency(totalContractsPaid)),
                      const Divider(height: 12),
                      _metricRow(t('site_kpi_contractors_remaining'), fmtCurrency(totalContractsRemaining)),
                    ],
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
            const SizedBox(height: 16),
            Text(t('site_contractors_breakdown'),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo)),
            const SizedBox(height: 8),
            siteContracts.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(t('no_contracts_for_site')),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: siteContracts.length,
                    itemBuilder: (ctx, idx) {
                      final c = siteContracts[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade100,
                            child: Icon(Icons.assignment, color: Colors.blueGrey.shade800),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c.contractorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Chip(
                                label: Text(c.contractType, style: const TextStyle(fontSize: 10, color: Colors.indigo)),
                                backgroundColor: Colors.indigo.shade50,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          subtitle: Text(
                              '${t('contract_amount')}: ${fmtCurrency(c.amount)} | ${t('contract_paid')}: ${fmtCurrency(c.totalPaid)} | ${t('contract_remaining')}: ${fmtCurrency(c.remaining)}${c.note.isNotEmpty ? "\n📌 " + c.note : ""}'),
                          isThreeLine: c.note.isNotEmpty,
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
      case 'advances':
        return Colors.deepOrange;
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
      case 'advances':
        return Icons.price_change;
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
                _filterChip('advances', t('filter_advances')),
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
  double base = 0, ot = 0, trans = 0;
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
      base += w.dailyRate;
      ot += log.overtimeHours * AppDatabase.overtimeRate;
      trans += log.transport;
      days++;
      sb.writeln(
          '$label: ${log.site.isEmpty ? "" : "${log.site} | "}${tr('overtime_short')} ${fmtNum(log.overtimeHours)}${tr('hour_short')} | ${tr('transport_short')} ${fmtMoney(log.transport)} = ${fmtCurrency(dayTotal)}${log.note.isEmpty ? "" : " | ${log.note}"}');
    }
  }
  final gross = w.weekGrossTotal(ws);
  final advances = w.weekAdvancesTotal(ws);
  final net = w.weekNetTotal(ws);

  sb.writeln('');
  sb.writeln('${tr('work_days')}: ${ltr('$days')}');
  sb.writeln('${tr('sum_days')}: ${fmtCurrency(base)}');
  sb.writeln('${tr('sum_overtime')}: ${fmtCurrency(ot)}');
  sb.writeln('${tr('sum_transport')}: ${fmtCurrency(trans)}');
  sb.writeln('${tr('gross_total')}: ${fmtCurrency(gross)}');
  if (advances > 0) {
    sb.writeln('${tr('advances_deducted')}: -${fmtCurrency(advances)}');
  }
  sb.writeln('💰 ${tr('net_total')}: ${fmtCurrency(net)}');
  return sb.toString();
}

String buildAllWeekText(DateTime ws, String lang) {
  String tr(String k) => L10n.tr(k, lang);
  final sb = StringBuffer();
  sb.writeln('📊 ${tr('all_report')}');
  sb.writeln('📅 ${fmtDate(ws)} - ${fmtDate(addDays(ws, 6))}');
  sb.writeln('');
  double grandGross = 0;
  double grandAdv = 0;
  double grandNet = 0;
  final weekWorkers = AppDatabase.workersForWeek(ws);
  for (final w in weekWorkers) {
    final g = w.weekGrossTotal(ws);
    final a = w.weekAdvancesTotal(ws);
    final n = w.weekNetTotal(ws);
    grandGross += g;
    grandAdv += a;
    grandNet += n;
    sb.writeln('👷 ${w.name}: ${tr('gross_total')} ${fmtCurrency(g)}${a > 0 ? " | " + tr('advances_deducted') + " -" + fmtCurrency(a) : ""} = ${tr('net_total')} ${fmtCurrency(n)}');
  }
  sb.writeln('');
  sb.writeln('${tr('gross_total')}: ${fmtCurrency(grandGross)}');
  if (grandAdv > 0) sb.writeln('${tr('total_advances')}: -${fmtCurrency(grandAdv)}');
  sb.writeln('💰 ${tr('grand_total')} (${tr('net_total')}): ${fmtCurrency(grandNet)}');
  return sb.toString();
}

// ---------- محرك إنشاء الـ PDF مع خط ثنائي مدمج بدون إنترنت ----------

const String _kArabicFontGzB64 = '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';

bool gPdfFontFailed = false;

Future<pw.Document> _newPdf() async {
  gPdfFontFailed = false;
  pw.Font? regular;

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

  final gross = w.weekGrossTotal(ws);
  final advances = w.weekAdvancesTotal(ws);
  final net = w.weekNetTotal(ws);

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
          _pdfLine(tr('gross_total'), fmtCurrency(gross), rtl: rtl),
          if (advances > 0)
            _pdfLine(tr('advances_deducted'), '- ${fmtCurrency(advances)}', rtl: rtl),
          pw.SizedBox(height: 8),
          _pdfLine(tr('net_total'), fmtCurrency(net), rtl: rtl, big: true),
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
  header.add(_pdfCell(tr('gross_total'), bold: true, rtl: rtl));
  header.add(_pdfCell(tr('total_advances'), bold: true, rtl: rtl));
  header.add(_pdfCell(tr('net_total'), bold: true, rtl: rtl));

  final rows = <pw.TableRow>[pw.TableRow(children: order(header))];
  double grandGross = 0;
  double grandAdv = 0;
  double grandNet = 0;
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
    final g = w.weekGrossTotal(ws);
    final a = w.weekAdvancesTotal(ws);
    final n = w.weekNetTotal(ws);
    grandGross += g;
    grandAdv += a;
    grandNet += n;

    cells.add(_pdfCell(fmtMoney(g), numeric: true));
    cells.add(_pdfCell(a > 0 ? fmtMoney(a) : '-', numeric: true));
    cells.add(_pdfCell(fmtMoney(n), bold: true, numeric: true));
    rows.add(pw.TableRow(children: order(cells)));
  }

  final totalCells = <pw.Widget>[_pdfCell(tr('total_word'), bold: true, rtl: rtl)];
  for (int i = 0; i < 7; i++) {
    totalCells.add(_pdfCell(fmtMoney(dayTotals[i]), bold: true, numeric: true));
  }
  totalCells.add(_pdfCell(fmtMoney(grandGross), bold: true, numeric: true));
  totalCells.add(_pdfCell(fmtMoney(grandAdv), bold: true, numeric: true));
  totalCells.add(_pdfCell(fmtMoney(grandNet), bold: true, numeric: true));
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
          _pdfLine('${tr('grand_total')} (${tr('net_total')})', fmtCurrency(grandNet), rtl: rtl, big: true),
        ],
      ),
    ),
  );

  AppDatabase.logActivity('pdf', 'تصدير تقرير أسبوعي لجميع العمال PDF',
      'تم تصدير التقرير المشترك للأسبوع ${fmtDate(ws)} بمبلغ إجمالي صافي ${fmtCurrency(grandNet)}');

  await Printing.sharePdf(bytes: await pdf.save(), filename: 'weekly_all.pdf');
}

// تصدير ومشاركة عقد المقاول كـ PDF رسمي مع دعم 3 لغات وعرض المدفوع والمتبقي
Future<void> shareContractPdf(BuildContext context, WorkContract c, String lang) async {
  String tr(String k) => L10n.tr(k, lang);
  final rtl = lang == 'ar';
  final td = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
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
                pw.Text(tr('contract_doc_title'),
                    textDirection: td,
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('${tr('contract_date')}: ${fmtFullDate(c.date)}',
                    textDirection: td,
                    style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          pw.Text('${tr('first_party')}: WookFlow Management',
              textDirection: td,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text('${tr('second_party')}: ${c.contractorName} ${c.phone.isNotEmpty ? "(${c.phone})" : ""}',
              textDirection: td,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Divider(),

          pw.SizedBox(height: 8),
          _pdfLine(tr('site'), c.siteName, rtl: rtl, big: true),
          _pdfLine(tr('contract_type'), c.contractType == 'عقد جزئي' ? tr('contract_type_partial') : tr('contract_type_full'), rtl: rtl),
          _pdfLine(tr('contract_amount'), fmtCurrency(c.amount), rtl: rtl, big: true),
          _pdfLine(tr('contract_paid'), fmtCurrency(c.totalPaid), rtl: rtl),
          _pdfLine(tr('contract_remaining'), fmtCurrency(c.remaining), rtl: rtl, big: true),
          pw.SizedBox(height: 12),

          if (c.note.isNotEmpty) ...[
            pw.Text('${tr('contract_notes')}:',
                textDirection: td,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
              child: pw.Text(c.note,
                  textDirection: td,
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
                  pw.Text(tr('signature_first'), textDirection: td),
                  pw.SizedBox(height: 40),
                  pw.Text('................................', textDirection: td),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(tr('signature_second'), textDirection: td),
                  pw.SizedBox(height: 40),
                  pw.Text('................................', textDirection: td),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );

  AppDatabase.logActivity('contracts', 'تصدير عقد مقاول PDF',
      'تم تصدير وثيقة عقد المقاول ${c.contractorName} لورشة ${c.siteName} بلغة ($lang)');

  await Printing.sharePdf(bytes: await pdf.save(), filename: 'contract_${c.contractorName}.pdf');
}


// ======================= واجهات التقارير الأسبوعية =======================

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
    double grandGross = 0;
    double grandAdv = 0;
    double grandNet = 0;
    for (final w in weekWorkers) {
      grandGross += w.weekGrossTotal(_weekStart);
      grandAdv += w.weekAdvancesTotal(_weekStart);
      grandNet += w.weekNetTotal(_weekStart);
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
                              '${t('joint_sub')}\n${t('gross_total')}: ${fmtCurrency(grandGross)}${grandAdv > 0 ? " | " + t('total_advances') + ": -" + fmtCurrency(grandAdv) : ""}\n${t('net_total')}: ${fmtCurrency(grandNet)}'),
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
                        final gross = worker.weekGrossTotal(_weekStart);
                        final adv = worker.weekAdvancesTotal(_weekStart);
                        final net = worker.weekNetTotal(_weekStart);

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
                            subtitle: Text(
                                '${t('work_days')}: ${ltr('$days')} | ${t('gross_total')}: ${fmtCurrency(gross)}${adv > 0 ? " | " + t('total_advances') + ": -" + fmtCurrency(adv) : ""}'),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(t('net_total'), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                Text(fmtCurrency(net),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo)),
                              ],
                            ),
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
    double grandGross = 0;
    double grandAdv = 0;
    double grandNet = 0;
    final dayTotals = List<double>.filled(7, 0.0);
    for (final w in workers) {
      grandGross += w.weekGrossTotal(_weekStart);
      grandAdv += w.weekAdvancesTotal(_weekStart);
      grandNet += w.weekNetTotal(_weekStart);
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
                    DataColumn(label: Text(t('gross_total'))),
                    DataColumn(label: Text(t('total_advances'))),
                    DataColumn(label: Text(t('net_total'))),
                  ],
                  rows: [
                    ...workers.map((w) {
                      final g = w.weekGrossTotal(_weekStart);
                      final a = w.weekAdvancesTotal(_weekStart);
                      final n = w.weekNetTotal(_weekStart);
                      return DataRow(cells: [
                        DataCell(Text(w.name,
                            style: const TextStyle(fontWeight: FontWeight.bold))),
                        for (int i = 0; i < 7; i++)
                          DataCell(Text(dayCellText(
                              w.logFor(addDays(_weekStart, i)),
                              w.dailyRate,
                              lang))),
                        DataCell(Text(fmtMoney(g))),
                        DataCell(Text(a > 0 ? fmtMoney(a) : '-',
                            style: TextStyle(color: a > 0 ? Colors.deepOrange : null))),
                        DataCell(Text(fmtMoney(n),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo))),
                      ]);
                    }),
                    DataRow(cells: [
                      DataCell(Text(t('total_word'),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      for (int i = 0; i < 7; i++)
                        DataCell(Text(fmtMoney(dayTotals[i]),
                            style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(fmtMoney(grandGross),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(fmtMoney(grandAdv),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange))),
                      DataCell(Text(fmtMoney(grandNet),
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
                  child: Text('${t('grand_total')} (${t('net_total')}):',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                Text(fmtCurrency(grandNet),
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

  Widget _sumRow(String label, String value, {bool isBold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
            Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final w = widget.worker;
    final logs = w.weekLogs(_weekStart);
    final weekAdvs = w.weekAdvances(_weekStart);
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
    final grossTotal = w.weekGrossTotal(_weekStart);
    final advancesTotal = w.weekAdvancesTotal(_weekStart);
    final netTotal = w.weekNetTotal(_weekStart);

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
                if (weekAdvs.isNotEmpty) ...[
                  Card(
                    color: Colors.deepOrange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(t('total_advances'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                              Text(fmtCurrency(advancesTotal),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                            ],
                          ),
                          const Divider(),
                          ...weekAdvs.map((adv) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('📌 ${fmtDate(adv.date)}${adv.note.isNotEmpty ? " (" + adv.note + ")" : ""}',
                                        style: const TextStyle(fontSize: 12)),
                                    Text('- ${fmtCurrency(adv.amount)}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _sumRow(t('work_days'), ltr('$daysWorked')),
                        _sumRow(t('sum_days'), fmtCurrency(baseTotal)),
                        _sumRow(t('sum_overtime'), fmtCurrency(overtimeTotal)),
                        _sumRow(t('sum_transport'), fmtCurrency(transportTotal)),
                        const Divider(),
                        _sumRow(t('gross_total'), fmtCurrency(grossTotal), isBold: true),
                        if (advancesTotal > 0)
                          _sumRow(t('advances_deducted'), '- ${fmtCurrency(advancesTotal)}', color: Colors.red, isBold: true),
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
                  child: Text('${t('net_total')}:',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Text(fmtCurrency(netTotal),
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
