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
                              '${t('daily_wage')}: ${fmtCurrency(worker.dailyRate)}
${t('card_weekly')} (${t('total_advances')}): ${fmtCurrency(weekAdv)} | ${t('total')}: ${fmtCurrency(totalAdv)}'),
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
                        '${t('total')}: ${fmtCurrency(site.totalContractAmount)}
${t('received')}: ${fmtCurrency(site.totalPaid)}
${t('remaining')}: ${fmtCurrency(remaining)}'),
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
                    subtitle: Text('${t('site')}: ${c.siteName} | ${t('contract_amount')}: ${fmtCurrency(c.amount)} | ${t('contract_paid')}: ${fmtCurrency(c.totalPaid)}${remaining > 0 ? " | " + t('contract_remaining') + ": " + fmtCurrency(remaining) : ""}
${c.contractType} (${fmtDate(c.date)})'),
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

const String _kArabicFontGzB64 = 'H4sIAAZk1WoC/5R9CUBU1f7/Oefud7Y7GzDMwMwwwLCIjCAiinLDJTUXKvcSccOlFBJ3LFwSNDU0xZWUTE3NzMxnYG4laS5tT6znU1+vpPK9yHzv2abM9X/OvQOi9X6/379xmJk7Z84953u+y+f7Pd/vCUAAgAX/oYHn4Z69evvfSpgFQNN2fLXm4bxBj1duLZ8MwA89AfB+/PDjQ3Knf/H8CwCabACweQMeGtxnVdmlmwDaxwOADgx6PDXthZ43OAC+isW/Hzpu6pji7p/3uoY/zwcA2sbNmuEBk6OyALiO+4dKYfHEqc90nDUFgK9X4favTxxTUgw4/ABNG/Bn/cSn5xZ+96+ez+C27QD4KDBpwpjxcfVfLwedAfB+v/B7/GgWfP/yYQv/F/j3D39u1gHwR5wGgBnjf+e8y54YmK7g5mQ3peFm1v4eY/C1kY4+9qNHzuB2/gT7h4P064Uq7u3u06b17/3q2C979V7a/5UXu3fsPnXgW78/t+/D2X9b8eWq7z9dse3A7+r+5/X5X65cvfFw+X296/97wKj3F49d/eW6bavL/vXxW79+vvz3/pM2LH120cLH49Z88+mS7a+1z583f8Vrs3u89/7ilS/m/qV2X8V7X6xfuGv1m+tffu4vLy187pWls1/b+drqffNWv/B/D6z880vzFi359rW/PLfy9WV/fLbnwsXPPzd/3oL5/5Wz4M0Vry7+w6+vLp33hxfmvvfV/O9Xv7Tki8Wvvz39tT8tXPjcsm+/Xv70+l9W//HPL7244rUlL7z+2uJ5z/3b2gVf7H7v6V/9bv7rq/50aO3rn7647PlXfrFswevvLVn0/C+Wz5v33tqFn/372rWvrH7/6/dWPvf80ud+sfzZ15e98O6yVxctfWnR1z++u/C55X/85YpFz73+2or/98v5r7/5wrvfLFz49muf/XvhwuWvrfrDkmeff37Z/2v9e8W3K5fP+f1Ly97+ZOGC55b94fefL57z7IsL/vf5389f/s2rr72y4tVff7741ddef/Wll1b/x9uvvfba8gVvvfz2ymWv/Gv58uXLV3z68tKlS5e/8+H/A1/b2YvYPAAA';

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
