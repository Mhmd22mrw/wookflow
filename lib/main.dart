import 'package:flutter/material.dart';
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
      'مدير الورشة (Abidjan)',
      'Chef de chantier (Abidjan)',
      'Site manager (Abidjan)'
    ],
    'version': [
      'نظام إدارة المشاريع v1.0.0',
      'Gestion de projets v1.0.0',
      'Project management v1.0.0'
    ],
    'language': ['اللغة', 'Langue', 'Language'],
    'report_lang': ['لغة التقرير', 'Langue du rapport', 'Report language'],
    'm_daily': [
      'التقرير اليومي (حضور اليوم)',
      'Rapport journalier (présence)',
      'Daily report (attendance)'
    ],
    'm_add_worker': ['إضافة عامل جديد', 'Ajouter un ouvrier', 'Add worker'],
    'm_delete_worker': ['حذف عامل', 'Supprimer un ouvrier', 'Delete worker'],
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
    'card_hour_rate': ['سعر ساعة العمل', 'Taux horaire', 'Hourly rate'],
    'card_weekly': ['ملخص الأسبوع', 'Résumé de la semaine', 'Weekly summary'],
    'view_reports': ['عرض التقارير', 'Voir les rapports', 'View reports'],
    'daily_title': ['التقرير اليومي', 'Rapport journalier', 'Daily report'],
    'works': ['يعمل؟', 'Présent ?', 'Working?'],
    'site': ['الورشة', 'Chantier', 'Site'],
    'overtime': ['ساعات إضافية', 'Heures supp.', 'Overtime hours'],
    'transport': ['أجور النقل (XOF)', 'Transport (XOF)', 'Transport (XOF)'],
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
      'اليومية (إجباري) - الساعة الإضافية 1000 XOF',
      'Salaire journalier (obligatoire) - heure supp. 1000 XOF',
      'Daily wage (required) - overtime hour 1000 XOF'
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
      'تم إضافة العامل وحفظه',
      'Ouvrier ajouté et enregistré',
      'Worker added and saved'
    ],
    'save_failed': [
      'فشل الحفظ',
      "Échec de l'enregistrement",
      'Save failed'
    ],
    'delete_title': ['حذف العمال', 'Supprimer des ouvriers', 'Delete workers'],
    'deleted_ok': [
      'تم حذف العمال المحددين بنجاح',
      'Ouvriers supprimés avec succès',
      'Selected workers deleted'
    ],
    'no_workers_now': [
      'لا يوجد عمال مضافون حالياً',
      "Aucun ouvrier pour le moment",
      'No workers yet'
    ],
    'select_all': ['اختيار الجميع', 'Tout sélectionner', 'Select all'],
    'daily_wage': ['اليومية', 'Salaire/jour', 'Daily wage'],
    'phone': ['الهاتف', 'Tél.', 'Phone'],
    'add_site_title': [
      'إضافة موقع عمل جديد',
      'Nouveau chantier',
      'New work site'
    ],
    'site_name': ['اسم الموقع', 'Nom du chantier', 'Site name'],
    'site_address': ['العنوان', 'Adresse', 'Address'],
    'site_total': [
      'الأجر الكامل للورشة',
      'Montant total du chantier',
      'Total contract amount'
    ],
    'cancel': ['إلغاء', 'Annuler', 'Cancel'],
    'save': ['حفظ', 'Enregistrer', 'Save'],
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
      'قيمة الدفعة الجديدة (XOF)',
      'Nouveau paiement (XOF)',
      'New payment (XOF)'
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
    'daily_xof': [
      'اليومية (XOF)',
      'Salaire/jour (XOF)',
      'Daily wage (XOF)'
    ],
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
    'pdf_font_err': [
      'تعذّر تحميل الخط العربي (يلزم إنترنت)، قد لا تظهر الحروف العربية في PDF',
      'Police arabe indisponible (internet requis)',
      'Arabic font unavailable (internet required)'
    ],
  };
}

String t(String key) => L10n.t(key);

// ======================= دوال مساعدة =======================

const String kLrm = '\u200E'; // علامة تثبّت اتجاه الأرقام من اليسار لليمين
const String kNbsp = '\u00A0'; // مسافة لا تفصل الرقم
const double kOvertimeRate = 1000;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// بداية الأسبوع = الأحد
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
String fmtXof(double v) => ltr('${_grouped(v)}${kNbsp}XOF');
String fmtNum(double v) => ltr(numStr(v));
String fmtDate(DateTime d) => ltr('${d.day}/${d.month}');
String fmtFullDate(DateTime d) => ltr('${d.day}/${d.month}/${d.year}');

// تنظيف النص قبل وضعه في PDF
String plain(String s) => s.replaceAll(kLrm, '').replaceAll(kNbsp, ' ');

// ======================= نافذتا اختيار اللغة =======================

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
          // اتجاه ثابت حسب اللغة: عربي = من اليمين، فرنسي/إنجليزي = من اليسار
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

// ======================= النماذج =======================

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

  double total(double dailyRate) =>
      worked ? dailyRate + overtimeHours * kOvertimeRate + transport : 0.0;

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
  Map<String, DayLog> logs;

  Worker({
    required this.id,
    required this.name,
    required this.dailyRate,
    this.phone = '',
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
      dailyRate: ((json['dailyRate'] ?? 8000.0) as num).toDouble(),
      phone: (json['phone'] ?? '').toString(),
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

  WorkSite({
    required this.id,
    required this.name,
    required this.location,
    required this.totalContractAmount,
    this.totalPaid = 0.0,
    this.isDelivered = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'totalContractAmount': totalContractAmount,
        'totalPaid': totalPaid,
        'isDelivered': isDelivered,
      };

  factory WorkSite.fromJson(Map<String, dynamic> json) => WorkSite(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        location: (json['location'] ?? '').toString(),
        totalContractAmount:
            ((json['totalContractAmount'] ?? 0.0) as num).toDouble(),
        totalPaid: ((json['totalPaid'] ?? 0.0) as num).toDouble(),
        isDelivered: json['isDelivered'] ?? false,
      );
}

// ======================= قاعدة البيانات =======================

class AppDatabase {
  static List<Worker> workers = [];
  static List<WorkSite> sites = [];
  static String lastPopupDate = '';
  static String? lastError;

  static Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final workersStr = prefs.getString('workers_data');
      final sitesStr = prefs.getString('sites_data');
      lastPopupDate = prefs.getString('last_popup_date') ?? '';
      final savedLang = prefs.getString('app_lang');
      if (savedLang != null && L10n.codes.contains(savedLang)) {
        L10n.lang = savedLang;
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

  static Future<void> saveLang() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_lang', L10n.lang);
    } catch (e) {
      lastError = 'Save error: $e';
    }
  }

  static bool shouldShowDailyPopup() {
    return workers.isNotEmpty && lastPopupDate != dateKey(DateTime.now());
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
    if (AppDatabase.workers.isEmpty) {
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
          if (_showDailyPopup && AppDatabase.workers.isNotEmpty)
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
    for (final w in AppDatabase.workers) {
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
                    decoration: InputDecoration(labelText: t('transport')),
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
            Text('${t('day_total')}: ${fmtXof(log.total(worker.dailyRate))}',
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
                  itemCount: AppDatabase.workers.length,
                  itemBuilder: (context, index) =>
                      _workerCard(AppDatabase.workers[index]),
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
    final workingToday = AppDatabase.workers
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
              leading: const Icon(Icons.person_remove),
              title: Text(t('m_delete_worker')),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DeleteWorkerScreen()));
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
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DeliveredSitesScreen()));
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
            const Divider(),
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
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(context, t('card_workers_today'),
                      ltr('$workingToday'), Icons.people, Colors.blue),
                  _buildDashboardCard(
                      context,
                      t('card_active_sites'),
                      ltr('${AppDatabase.sites.where((s) => !s.isDelivered).length}'),
                      Icons.apartment,
                      Colors.orange),
                  _buildDashboardCard(context, t('card_hour_rate'),
                      fmtXof(kOvertimeRate), Icons.money, Colors.green),
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
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 5),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= إضافة وحذف العمال =======================

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rateController =
      TextEditingController(text: '8000');
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
                validator: (value) => (value == null || value.isEmpty)
                    ? t('enter_name')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateController,
                decoration: InputDecoration(labelText: t('rate_req')),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
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
                    AppDatabase.workers.add(Worker(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      dailyRate:
                          double.tryParse(_rateController.text) ?? 8000.0,
                      phone: _phoneController.text,
                    ));
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

class DeleteWorkerScreen extends StatefulWidget {
  const DeleteWorkerScreen({super.key});

  @override
  State<DeleteWorkerScreen> createState() => _DeleteWorkerScreenState();
}

class _DeleteWorkerScreenState extends State<DeleteWorkerScreen> {
  final Map<String, bool> _selectedWorkers = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    for (var w in AppDatabase.workers) {
      _selectedWorkers[w.id] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('delete_title')),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              setState(() {
                AppDatabase.workers
                    .removeWhere((w) => _selectedWorkers[w.id] == true);
              });
              final ok = await AppDatabase.saveData();
              messenger.showSnackBar(SnackBar(
                  content: Text(ok
                      ? t('deleted_ok')
                      : '${t('save_failed')}: ${AppDatabase.lastError}')));
            },
          ),
        ],
      ),
      body: AppDatabase.workers.isEmpty
          ? Center(child: Text(t('no_workers_now')))
          : Column(
              children: [
                CheckboxListTile(
                  title: Text(t('select_all'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  value: _selectAll,
                  onChanged: (val) {
                    setState(() {
                      _selectAll = val ?? false;
                      _selectedWorkers.updateAll((key, value) => _selectAll);
                    });
                  },
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: AppDatabase.workers.length,
                    itemBuilder: (context, index) {
                      final worker = AppDatabase.workers[index];
                      return CheckboxListTile(
                        title: Text(worker.name),
                        subtitle: Text(
                            '${t('daily_wage')}: ${fmtXof(worker.dailyRate)} | ${t('phone')}: ${ltr(worker.phone)}'),
                        value: _selectedWorkers[worker.id] ?? false,
                        onChanged: (val) {
                          setState(() {
                            _selectedWorkers[worker.id] = val ?? false;
                          });
                        },
                      );
                    },
                  ),
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
                decoration: InputDecoration(labelText: t('site_total')),
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
                AppDatabase.sites.add(WorkSite(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  location: _locationController.text,
                  totalContractAmount:
                      double.tryParse(_amountController.text) ?? 0.0,
                ));
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
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(site.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${t('site_address')}: ${site.location} | ${t('total')}: ${fmtXof(site.totalContractAmount)}'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() {
                          site.isDelivered = true;
                        });
                        await AppDatabase.saveData();
                        messenger.showSnackBar(
                            SnackBar(content: Text(t('delivered_msg'))));
                      },
                      child: Text(t('deliver')),
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

class DeliveredSitesScreen extends StatelessWidget {
  const DeliveredSitesScreen({super.key});

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
                return Card(
                  margin: const EdgeInsets.all(8),
                  color: Colors.grey.shade100,
                  child: ListTile(
                    title: Text(site.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough)),
                    subtitle: Text(
                        '${t('site_address')}: ${site.location} | ${t('contract_total')}: ${fmtXof(site.totalContractAmount)}\n${t('received')}: ${fmtXof(site.totalPaid)} (${t('delivered_flag')})'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}

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
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(site.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${t('total')}: ${fmtXof(site.totalContractAmount)}\n${t('received')}: ${fmtXof(site.totalPaid)}\n${t('remaining')}: ${fmtXof(site.totalContractAmount - site.totalPaid)}'),
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
    final paymentController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${t('add_payment_for')} ${site.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t('contract_total')}: ${fmtXof(site.totalContractAmount)}'),
            Text('${t('payments_sum')}: ${fmtXof(site.totalPaid)}'),
            Text(
                '${t('remaining')}: ${fmtXof(site.totalContractAmount - site.totalPaid)}',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: paymentController,
              decoration: InputDecoration(labelText: t('new_payment')),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              final payment = double.tryParse(paymentController.text) ?? 0.0;
              if (payment > 0) {
                site.totalPaid += payment;
              }
              Navigator.pop(dialogContext);
              if (mounted) setState(() {});
              await AppDatabase.saveData();
            },
            child: Text(t('save')),
          ),
        ],
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
    return Scaffold(
      appBar: AppBar(
          title: Text(t('workers_list_title')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: AppDatabase.workers.isEmpty
          ? Center(child: Text(t('no_workers')))
          : ListView.builder(
              itemCount: AppDatabase.workers.length,
              itemBuilder: (context, index) {
                final worker = AppDatabase.workers[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(worker.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${t('daily_wage')}: ${fmtXof(worker.dailyRate)} | ${t('phone')}: ${ltr(worker.phone)}'),
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
                decoration: InputDecoration(labelText: t('daily_xof')),
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
                worker.name = nameController.text;
                worker.dailyRate =
                    double.tryParse(rateController.text) ?? worker.dailyRate;
                worker.phone = phoneController.text;
              });
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
      // ترتيب الأزرار ثابت (يسار = أسبوع سابق، يمين = أسبوع لاحق) مهما كانت اللغة
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
      ot += log.overtimeHours * kOvertimeRate;
      trans += log.transport;
      days++;
      sb.writeln(
          '$label: ${log.site.isEmpty ? "" : "${log.site} | "}${tr('overtime_short')} ${fmtNum(log.overtimeHours)}${tr('hour_short')} | ${tr('transport_short')} ${fmtMoney(log.transport)} = ${fmtXof(dayTotal)}${log.note.isEmpty ? "" : " | ${log.note}"}');
    }
  }
  sb.writeln('');
  sb.writeln('${tr('work_days')}: ${ltr('$days')}');
  sb.writeln('${tr('sum_days')}: ${fmtXof(base)}');
  sb.writeln('${tr('sum_overtime')}: ${fmtXof(ot)}');
  sb.writeln('${tr('sum_transport')}: ${fmtXof(trans)}');
  sb.writeln('💰 ${tr('weekly_total')}: ${fmtXof(total)}');
  return sb.toString();
}

String buildAllWeekText(DateTime ws, String lang) {
  String tr(String k) => L10n.tr(k, lang);
  final sb = StringBuffer();
  sb.writeln('📊 ${tr('all_report')}');
  sb.writeln('📅 ${fmtDate(ws)} - ${fmtDate(addDays(ws, 6))}');
  sb.writeln('');
  double grand = 0;
  for (final w in AppDatabase.workers) {
    final tot = w.weekTotal(ws);
    grand += tot;
    sb.writeln('👷 ${w.name}: ${fmtXof(tot)}');
  }
  sb.writeln('');
  sb.writeln('💰 ${tr('grand_total')}: ${fmtXof(grand)}');
  return sb.toString();
}

// ---------- PDF ----------

bool gPdfFontFailed = false;

Future<pw.Document> _newPdf() async {
  gPdfFontFailed = false;
  try {
    final regular = await PdfGoogleFonts.cairoRegular();
    final bold = await PdfGoogleFonts.cairoBold();
    return pw.Document(
        theme: pw.ThemeData.withFont(base: regular, bold: bold));
  } catch (_) {
    gPdfFontFailed = true;
    return pw.Document();
  }
}

pw.Widget _pdfCell(String text,
    {bool bold = false, bool rtl = false, bool numeric = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      plain(text),
      textDirection:
          (rtl && !numeric) ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
    ),
  );
}

// سطر "عنوان: قيمة" مع إبقاء الرقم دائمًا من اليسار لليمين
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
      ot += log.overtimeHours * kOvertimeRate;
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
              textDirection: td,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _pdfLine(tr('week'), '${fmtDate(ws)} - ${fmtDate(addDays(ws, 6))}',
              rtl: rtl),
          pw.SizedBox(height: 14),
          pw.Table(border: pw.TableBorder.all(), children: rows),
          pw.SizedBox(height: 14),
          _pdfLine(tr('work_days'), '$days', rtl: rtl),
          _pdfLine(tr('sum_days'), fmtXof(base), rtl: rtl),
          _pdfLine(tr('sum_overtime'), fmtXof(ot), rtl: rtl),
          _pdfLine(tr('sum_transport'), fmtXof(trans), rtl: rtl),
          pw.SizedBox(height: 8),
          _pdfLine(tr('weekly_total'), fmtXof(total), rtl: rtl, big: true),
        ],
      ),
    ),
  );

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
  for (final w in AppDatabase.workers) {
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
          _pdfLine(tr('grand_total'), fmtXof(grand), rtl: rtl, big: true),
        ],
      ),
    ),
  );

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
    double grand = 0;
    for (final w in AppDatabase.workers) {
      grand += w.weekTotal(_weekStart);
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(t('weekly_title')),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: AppDatabase.workers.isEmpty
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
                              '${t('joint_sub')}\n${t('total_word')}: ${fmtXof(grand)}'),
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
                      ...AppDatabase.workers.map((worker) {
                        final logs = worker.weekLogs(_weekStart);
                        final days =
                            logs.where((l) => l != null && l.worked).length;
                        return Card(
                          child: ListTile(
                            title: Text(worker.name),
                            subtitle:
                                Text('${t('work_days')}: ${ltr('$days')}'),
                            trailing: Text(fmtXof(worker.weekTotal(_weekStart)),
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

// التقرير المشترك: جدول كل العمال × أيام الأسبوع
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
    final workers = AppDatabase.workers;
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
                Text(fmtXof(grand),
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

// تقرير عامل واحد: كل أيام الأسبوع
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
    return '${t('site')}: $siteText\n${t('overtime_short')}: ${fmtNum(log.overtimeHours)} ${t('hour_short')} | ${t('transport_short')}: ${fmtXof(log.transport)}${log.note.isEmpty ? "" : "\n${log.note}"}';
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
                  decoration: InputDecoration(labelText: t('transport')),
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
                  note: noteCtrl.text,
                );
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
        overtimeTotal += l.overtimeHours * kOvertimeRate;
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
                            log == null ? '—' : fmtXof(log.total(w.dailyRate)),
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
                        _sumRow(t('sum_days'), fmtXof(baseTotal)),
                        _sumRow(t('sum_overtime'), fmtXof(overtimeTotal)),
                        _sumRow(t('sum_transport'), fmtXof(transportTotal)),
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
                Text(fmtXof(total),
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
