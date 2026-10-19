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
    'settle_and_finish': ['تسديد المتبقي وإنهاء', 'Tout solder et clôturer', 'Settle all and finish'],
    'finish_with_remaining': ['إنهاء مع الإبقاء على الرصيد', 'Clôturer avec solde restant', 'Finish with remaining balance'],
    'copy_backup': ['نسخ كود النسخة الاحتياطية', 'Copier le code de sauvegarde', 'Copy backup code'],
    'backup_copied': ['تم نسخ كود النسخة الاحتياطية إلى الحافظة', 'Code de sauvegarde copié dans le presse-papiers', 'Backup code copied to clipboard'],
    'paste_from_clipboard': ['لصق واستعادة من الحافظة مباشرة', 'Coller et restaurer depuis le presse-papiers', 'Paste & restore from clipboard'],
    'enter_payment_amount': ['أدخل قيمة الدفعة', 'Saisir le montant du paiement', 'Enter payment amount'],
    'enter_daily_wage': ['أدخل الأجر اليومي', 'Saisir le salaire journalier', 'Enter daily wage'],
    'enter_contractor_name_err': ['يرجى إدخال اسم المقاول', 'Veuillez saisir le nom de l’entrepreneur', 'Please enter contractor name'],
    'enter_contract_amount_err': ['يرجى إدخال مبلغ العقد', 'Veuillez saisir le montant du contrat', 'Please enter contract amount'],
    'contract_notes_hint': ['مثال: يشمل توريد وتركيب الرخام خلال 30 يوماً', 'Ex : fourniture et pose dans les 30 jours', 'E.g. supply and installation within 30 days'],
    'extra_amount_reason_hint': ['مثال: أعمال صبغ إضافية، تعديل في المخطط', 'Ex : travaux de peinture supplémentaires', 'E.g. extra painting work, plan change'],
    'no_attendance_for_site': ['لم يتم تسجيل أي حضور للعمال في هذه الورشة بعد.', 'Aucun pointage d’ouvrier enregistré pour ce chantier.', 'No worker attendance recorded for this site yet.'],
    'act_restore_worker': ['استعادة عامل', 'Réactivation ouvrier', 'Restore worker'],
    'act_archive_worker': ['أرشفة عامل', 'Archivage ouvrier', 'Archive worker'],
    'act_delete_worker': ['حذف عامل نهائياً', 'Suppression définitive ouvrier', 'Delete worker'],
    'act_add_worker': ['إضافة عامل جديد', 'Nouvel ouvrier ajouté', 'Add new worker'],
    'act_edit_worker': ['تعديل بيانات عامل', 'Modification ouvrier', 'Edit worker'],
    'act_give_advance': ['تقديم سلفة لعامل', 'Avance sur salaire', 'Worker advance'],
    'act_delete_advance': ['حذف سلفة عامل', 'Suppression d’avance', 'Delete advance'],
    'act_add_site': ['إضافة موقع عمل جديد', 'Nouveau chantier ajouté', 'Add work site'],
    'act_edit_site': ['تعديل بيانات ورشة', 'Modification chantier', 'Edit site'],
    'act_deliver_site': ['تسليم ورشة منتهية', 'Livraison chantier', 'Deliver site'],
    'act_reopen_site': ['إعادة فتح ورشة', 'Réouverture chantier', 'Reopen site'],
    'act_delete_site': ['حذف ورشة', 'Suppression chantier', 'Delete site'],
    'act_add_payment': ['إضافة دفعة مالية', 'Paiement enregistré', 'Add payment'],
    'act_undo_payment': ['إلغاء آخر دفعة', 'Annulation dernier paiement', 'Undo payment'],
    'act_new_contract': ['إبرام عقد جديد', 'Nouveau contrat signé', 'New contract'],
    'act_edit_contract': ['تعديل عقد', 'Modification contrat', 'Edit contract'],
    'act_finish_contract': ['إنهاء عقد مقاولة', 'Clôture contrat', 'Finish contract'],
    'act_reopen_contract': ['إعادة تفعيل عقد', 'Réactivation contrat', 'Reopen contract'],
    'act_delete_contract': ['حذف عقد', 'Suppression contrat', 'Delete contract'],
    'act_contract_payment': ['تسديد دفعة للمقاول', 'Paiement sous-traitant', 'Contractor payment'],
    'act_undo_contract_payment': ['إلغاء دفعة مقاول', 'Annulation paiement sous-traitant', 'Undo contractor payment'],
    'act_attendance': ['حضور عامل', 'Pointage présence', 'Worker attendance'],
    'act_delete_day': ['مسح يوم عمل', 'Effacement journée', 'Clear day'],
    'act_backup_export': ['تصدير نسخة احتياطية', 'Export sauvegarde', 'Export backup'],
    'act_backup_restore': ['استعادة نسخة احتياطية', 'Restauration sauvegarde', 'Restore backup'],
    'act_pdf_worker': ['تصدير تقرير عامل PDF', 'Export PDF ouvrier', 'Export worker PDF'],
    'act_pdf_all': ['تصدير تقرير أسبوعي PDF', 'Export PDF hebdo', 'Export weekly PDF'],
    'act_pdf_contract': ['تصدير عقد مقاول PDF', 'Export PDF contrat', 'Export contract PDF'],
    'حذف سلفة عامل': ['حذف سلفة عامل', 'Suppression d’avance', 'Delete advance'],
    'تقديم سلفة لعامل': ['تقديم سلفة لعامل', 'Avance sur salaire', 'Worker advance'],
    'تصدير تقرير عامل PDF': ['تصدير تقرير عامل PDF', 'Export PDF ouvrier', 'Export worker PDF'],
    'إضافة عامل جديد': ['إضافة عامل جديد', 'Nouvel ouvrier ajouté', 'Add new worker'],
    'تسديد دفعة للمقاول': ['تسديد دفعة للمقاول', 'Paiement sous-traitant', 'Contractor payment'],
    'إبرام عقد جديد': ['إبرام عقد جديد', 'Nouveau contrat signé', 'New contract'],
    'أرشفة عامل': ['أرشفة عامل', 'Archivage ouvrier', 'Archive worker'],
    'استعادة عامل': ['استعادة عامل', 'Réactivation ouvrier', 'Restore worker'],
    'حذف عامل نهائياً': ['حذف عامل نهائياً', 'Suppression définitive ouvrier', 'Delete worker permanently'],
    'إضافة موقع عمل جديد': ['إضافة موقع عمل جديد', 'Nouveau chantier ajouté', 'Add work site'],
    'إلغاء آخر دفعة': ['إلغاء آخر دفعة', 'Annulation dernier paiement', 'Undo payment'],
    'تسليم ورشة منتهية': ['تسليم ورشة منتهية', 'Livraison chantier', 'Deliver site'],
    'تسليم ورشة وسداد المتبقي': ['تسليم ورشة وسداد المتبقي', 'Solde et livraison chantier', 'Settle and deliver site'],
    'تسليم ورشة باستثناء': ['تسليم ورشة باستثناء', 'Livraison avec dérogation', 'Deliver with exception'],
    'حذف ورشة': ['حذف ورشة', 'Suppression chantier', 'Delete site'],
    'إعادة فتح ورشة': ['إعادة فتح ورشة', 'Réouverture chantier', 'Reopen site'],
    'حذف ورشة من الأرشيف': ['حذف ورشة من الأرشيف', 'Suppression des archives', 'Delete from archives'],
    'إضافة دفعة مالية': ['إضافة دفعة مالية', 'Paiement enregistré', 'Add payment'],
    'تعديل عقد': ['تعديل عقد', 'Modification contrat', 'Edit contract'],
    'إلغاء دفعة مقاول': ['إلغاء دفعة مقاول', 'Annulation paiement sous-traitant', 'Undo contractor payment'],
    'إنهاء عقد مقاولة': ['إنهاء عقد مقاولة', 'Clôture contrat', 'Finish contract'],
    'إنهاء عقد وسداد المتبقي': ['إنهاء عقد وسداد المتبقي', 'Solde et clôture contrat', 'Settle and finish contract'],
    'إنهاء عقد مع رصيد متبقي': ['إنهاء عقد مع رصيد متبقي', 'Clôture avec solde restant', 'Finish with remaining balance'],
    'حذف عقد': ['حذف عقد', 'Suppression contrat', 'Delete contract'],
    'إعادة تفعيل عقد': ['إعادة تفعيل عقد', 'Réactivation contrat', 'Reopen contract'],
    'حذف عقد منتهي': ['حذف عقد منتهي', 'Suppression contrat terminé', 'Delete finished contract'],
    'تصدير تقرير أسبوعي لجميع العمال PDF': ['تصدير تقرير أسبوعي لجميع العمال PDF', 'Export PDF hebdomadaire', 'Export weekly PDF'],
    'تصدير عقد مقاول PDF': ['تصدير عقد مقاول PDF', 'Export PDF contrat', 'Export contract PDF'],
    'حضور عامل': ['حضور عامل', 'Pointage présence', 'Worker attendance'],
    'مسح يوم عمل': ['مسح يوم عمل', 'Effacement journée', 'Clear day'],
    'تعديل تسجيل يوم': ['تعديل تسجيل يوم', 'Modification pointage', 'Edit day log'],
    'زيادة مبلغ عقد الورشة': ['زيادة مبلغ عقد الورشة', 'Supplément au contrat', 'Contract extra amount'],
    'تعديل قيمة العقد': ['تعديل قيمة العقد', 'Modification montant contrat', 'Edit contract amount'],
    'استعادة نسخة احتياطية': ['استعادة نسخة احتياطية', 'Restauration sauvegarde', 'Restore backup'],
    'تصدير نسخة احتياطية': ['تصدير نسخة احتياطية', 'Export sauvegarde', 'Export backup'],
  };
}

String t(String key) => L10n.t(key);

String contractTypeLabel(String type) {
  if (type == 'عقد جزئي') return t('contract_type_partial');
  if (type == 'عقد كامل') return t('contract_type_full');
  return type;
}

String translateLogDetails(String details, String lang) {
  if (lang == 'ar' || details.trim().isEmpty) return details;

  if (lang == 'fr') {
    const replacements = [
      ['تمت استعادة البيانات بنجاح من كود النسخة الاحتياطية', 'Données restaurées avec succès depuis la sauvegarde'],
      ['تم حذف سلفة', 'Avance supprimée:'],
      ['المؤرخة', 'du'],
      ['تم تقديم سلفة بقيمة', 'Avance accordée de'],
      ['تمت إضافة العامل', 'Ouvrier ajouté:'],
      ['بيومية', 'avec salaire/jour:'],
      ['تمت أرشفة العامل مع الحفاظ على سجلاته', 'Ouvrier archivé (historique conservé)'],
      ['تمت أرشفة العامل', 'Ouvrier archivé:'],
      ['تمت إعادة تفعيل العامل بنجاح', 'Ouvrier réactivé avec succès'],
      ['تمت استعادة وتفعيل العامل', 'Ouvrier réactivé:'],
      ['تم الحذف النهائي للعامل', 'Ouvrier supprimé définitivement:'],
      ['تم تعديل بيانات العامل', 'Données modifiées pour l’ouvrier:'],
      ['تم إنشاء ورشة', 'Chantier créé:'],
      ['بمبلغ إجمالي', 'montant total:'],
      ['ورشة', 'Chantier'],
      ['عقد مع المقاول', 'Contrat avec l’entrepreneur'],
      ['عقد', 'Contrat'],
      ['لورشة', 'pour le chantier'],
      ['بقيمة', 'montant:'],
      ['دفعة بقيمة', 'Versement de'],
      ['دفعة', 'Versement:'],
      ['تم إلغاء دفعة', 'Versement annulé:'],
      ['الواصل الجديد', 'Nouveau total reçu:'],
      ['الواصل', 'Reçu:'],
      ['المتبقي', 'Reste:'],
      ['المدفوع', 'Payé:'],
      ['إضافة', 'Supplément:'],
      ['السبب', 'Motif:'],
      ['أعمال إضافية', 'Travaux supplémentaires'],
      ['تم تسليم ورشة', 'Chantier livré:'],
      ['ونقلها للأرشيف', 'et archivé'],
      ['الحساب مسدد بالكامل', 'compte soldé intégralement'],
      ['سداد المتبقي', 'solde du reste'],
      ['بالكامل وتسليمها للأرشيف', 'intégral et archivage'],
      ['تسليم باستثناء ومتبقي غير مسدد', 'livraison avec dérogation et solde restant:'],
      ['تم حذف ورشة', 'Chantier supprimé:'],
      ['نهائياً من أرشيف الورش المسلمة', 'définitivement des archives'],
      ['نهائياً', 'définitivement'],
      ['تمت إعادة فتح ورشة', 'Chantier rouvert:'],
      ['ونقلها إلى الورش النشطة', 'et réintégré aux chantiers actifs'],
      ['تم إنهاء عقد المقاول', 'Contrat clôturé pour:'],
      ['مع بقاء رصيد غير مسدد', 'avec solde restant:'],
      ['تم تسديد كامل متبقي عقد المقاول', 'Solde intégral du contrat de:'],
      ['وإنهاؤه', 'et clôture'],
      ['تم حذف العقد المنتهي للمقاول', 'Contrat terminé supprimé pour:'],
      ['تم حذف عقد المقاول', 'Contrat supprimé pour:'],
      ['تمت إعادة فتح عقد المقاول', 'Contrat réactivé pour:'],
      ['تم تعديل بيانات عقد المقاول', 'Contrat modifié pour:'],
      ['تم تصدير تقرير PDF للعامل', 'Rapport PDF exporté pour'],
      ['للأسبوع', 'semaine du'],
      ['تم تصدير التقرير المشترك للأسبوع', 'Rapport commun PDF exporté pour la semaine du'],
      ['بمبلغ إجمالي صافي', 'montant net:'],
      ['تم تصدير وثيقة عقد المقاول', 'Document de contrat exporté pour:'],
      ['بلغة', 'en langue'],
      ['تم مسح تسجيل يوم', 'Pointage effacé pour le jour:'],
      ['يعمل في', 'Présent sur:'],
      ['عطلة', 'Repos'],
      ['حاضر', 'Présent'],
      ['عقد جزئي', 'Contrat partiel'],
      ['عقد كامل', 'Contrat complet'],
    ];
    String res = details;
    for (final pair in replacements) {
      res = res.replaceAll(pair[0], pair[1]);
    }
    return res;
  }

  if (lang == 'en') {
    const replacements = [
      ['تمت استعادة البيانات بنجاح من كود النسخة الاحتياطية', 'Data restored successfully from backup code'],
      ['تم حذف سلفة', 'Advance deleted:'],
      ['المؤرخة', 'dated'],
      ['تم تقديم سلفة بقيمة', 'Advance given of'],
      ['تمت إضافة العامل', 'Worker added:'],
      ['بيومية', 'daily wage:'],
      ['تمت أرشفة العامل مع الحفاظ على سجلاته', 'Worker archived (history preserved)'],
      ['تمت أرشفة العامل', 'Worker archived:'],
      ['تمت إعادة تفعيل العامل بنجاح', 'Worker reactivated successfully'],
      ['تمت استعادة وتفعيل العامل', 'Worker reactivated:'],
      ['تم الحذف النهائي للعامل', 'Worker permanently deleted:'],
      ['تم تعديل بيانات العامل', 'Worker data edited:'],
      ['تم إنشاء ورشة', 'Work site created:'],
      ['بمبلغ إجمالي', 'total amount:'],
      ['ورشة', 'Site'],
      ['عقد مع المقاول', 'Contract with contractor'],
      ['عقد', 'Contract'],
      ['لورشة', 'for site'],
      ['بقيمة', 'amount:'],
      ['دفعة بقيمة', 'Payment of'],
      ['دفعة', 'Payment:'],
      ['تم إلغاء دفعة', 'Payment cancelled:'],
      ['الواصل الجديد', 'New received total:'],
      ['الواصل', 'Received:'],
      ['المتبقي', 'Remaining:'],
      ['المدفوع', 'Paid:'],
      ['إضافة', 'Extra:'],
      ['السبب', 'Reason:'],
      ['أعمال إضافية', 'Extra work'],
      ['تم تسليم ورشة', 'Site delivered:'],
      ['ونقلها للأرشيف', 'and archived'],
      ['الحساب مسدد بالكامل', 'account fully settled'],
      ['سداد المتبقي', 'settle remaining'],
      ['بالكامل وتسليمها للأرشيف', 'in full and archive'],
      ['تسليم باستثناء ومتبقي غير مسدد', 'delivery with exception and unpaid balance:'],
      ['تم حذف ورشة', 'Site deleted:'],
      ['نهائياً من أرشيف الورش المسلمة', 'permanently from archives'],
      ['نهائياً', 'permanently'],
      ['تمت إعادة فتح ورشة', 'Site reopened:'],
      ['ونقلها إلى الورش النشطة', 'and moved to active sites'],
      ['تم إنهاء عقد المقاول', 'Contract finished for:'],
      ['مع بقاء رصيد غير مسدد', 'with remaining balance:'],
      ['تم تسديد كامل متبقي عقد المقاول', 'Contract settled in full for:'],
      ['وإنهاؤه', 'and finished'],
      ['تم حذف العقد المنتهي للمقاول', 'Finished contract deleted for:'],
      ['تم حذف عقد المقاول', 'Contract deleted for:'],
      ['تمت إعادة فتح عقد المقاول', 'Contract reopened for:'],
      ['تم تعديل بيانات عقد المقاول', 'Contract edited for:'],
      ['تم تصدير تقرير PDF للعامل', 'PDF report exported for'],
      ['للأسبوع', 'for week'],
      ['تم تصدير التقرير المشترك للأسبوع', 'Joint PDF report exported for week'],
      ['بمبلغ إجمالي صافي', 'net total amount:'],
      ['تم تصدير وثيقة عقد المقاول', 'Contract document exported for:'],
      ['بلغة', 'in language'],
      ['تم مسح تسجيل يوم', 'Day log cleared for:'],
      ['يعمل في', 'Working at:'],
      ['عطلة', 'Day off'],
      ['حاضر', 'Present'],
      ['عقد جزئي', 'Partial contract'],
      ['عقد كامل', 'Full contract'],
    ];
    String res = details;
    for (final pair in replacements) {
      res = res.replaceAll(pair[0], pair[1]);
    }
    return res;
  }

  return details;
}




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

String plain(String s) => s
    .replaceAll(kLrm, '')
    .replaceAll('\u200E', '')
    .replaceAll('\u200F', '')
    .replaceAll('\u202A', '')
    .replaceAll('\u202B', '')
    .replaceAll('\u202C', '')
    .replaceAll('\u202D', '')
    .replaceAll('\u202E', '')
    .replaceAll('\uFEFF', '')
    .replaceAll('\u00A0', ' ');

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
      String clean = jsonStr.trim();
      final start = clean.indexOf('{');
      final end = clean.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        clean = clean.substring(start, end + 1);
      }
      final Map<String, dynamic> data = jsonDecode(clean);
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
        logActivity('backup', 'act_backup_restore', 'تمت استعادة البيانات بنجاح من كود النسخة الاحتياطية');
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
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.copy, color: Colors.indigo),
              label: Text(t('copy_backup')),
              onPressed: () async {
                final jsonStr = AppDatabase.exportBackupJson();
                await Clipboard.setData(ClipboardData(text: jsonStr));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t('backup_copied'))),
                  );
                }
              },
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 6),
            Text(t('import_backup'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: importController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: t('paste_json'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.content_paste, color: Colors.teal),
              label: Text(t('paste_from_clipboard')),
              onPressed: () async {
                final data = await Clipboard.getData('text/plain');
                if (data != null && data.text != null && data.text!.isNotEmpty) {
                  importController.text = data.text!;
                  final ok = await AppDatabase.importBackupJson(data.text!);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (ok) {
                    onDataUpdated();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t('restore_done'))),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${t('restore_err')}: ${AppDatabase.lastError ?? ""}')),
                      );
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.download, color: Colors.white),
              label: Text(t('confirm'),
                  style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () async {
                final ok = await AppDatabase.importBackupJson(importController.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (ok) {
                  onDataUpdated();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t('restore_done'))),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${t('restore_err')}: ${AppDatabase.lastError ?? ""}')),
                    );
                  }
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
                    hintText: t('enter_daily_wage')),
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
                    hintText: t('extra_amount_reason_hint'),
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
                  hintText: t('enter_payment_amount'),
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
                validator: (val) => (val == null || val.trim().isEmpty) ? t('enter_contractor_name_err') : null,
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
                validator: (val) => (val == null || val.trim().isEmpty) ? t('enter_contract_amount_err') : null,
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
                  hintText: t('contract_notes_hint'),
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
                    hintText: t('enter_payment_amount'),
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
                              label: Text(contractTypeLabel(c.contractType), style: const TextStyle(fontSize: 11, color: Colors.indigo)),
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
                    subtitle: Text('${t('site')}: ${c.siteName} | ${t('contract_amount')}: ${fmtCurrency(c.amount)} | ${t('contract_paid')}: ${fmtCurrency(c.totalPaid)}${remaining > 0 ? " | " + t('contract_remaining') + ": " + fmtCurrency(remaining) : ""}\n${contractTypeLabel(c.contractType)} (${fmtDate(c.date)})'),
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
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(t('no_attendance_for_site')),
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
                                label: Text(contractTypeLabel(c.contractType), style: const TextStyle(fontSize: 10, color: Colors.indigo)),
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
                                child: Text(t(log.title),
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
                            child: Text(translateLogDetails(log.details, L10n.lang),
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
                pw.Text('${tr('contract_date')}: ${plain(fmtFullDate(c.date))}',
                    textDirection: td,
                    style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          pw.Text(plain('${tr('first_party')}: WookFlow Management'),
              textDirection: td,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(plain('${tr('second_party')}: ${c.contractorName} ${c.phone.isNotEmpty ? "(${c.phone})" : ""}'),
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
              child: pw.Text(plain(c.note),
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
