import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

// ======================= ثوابت ودوال مساعدة =======================

const List<String> kDayNames = [
  'الأحد',
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت'
];
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

String fmtDate(DateTime d) => '${d.day}/${d.month}';

String fmtMoney(double v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

String fmtNum(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WookFlow - Chantier Manager',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      home: const MainDashboardWrapper(),
    );
  }
}

// ======================= النماذج =======================

// سجل يوم واحد لعامل
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
      lastError = 'خطأ في التحميل: $e';
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
        lastError = 'فشل الحفظ في الذاكرة';
      } else {
        lastError = null;
      }
      return ok1 && ok2 && ok3;
    } catch (e) {
      lastError = 'خطأ في الحفظ: $e';
      return false;
    }
  }

  // هل نعرض نافذة التقرير اليومي تلقائيًا؟ (مرة واحدة كل يوم)
  static bool shouldShowDailyPopup() {
    return workers.isNotEmpty && lastPopupDate != dateKey(DateTime.now());
  }

  static Future<void> markPopupShown() async {
    lastPopupDate = dateKey(DateTime.now());
    await saveData();
  }

  // يرجع سجل اليوم للعامل، وينشئه إن لم يكن موجودًا
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
    // يظهر تلقائيًا مرة واحدة فقط في اليوم
    _showDailyPopup = AppDatabase.shouldShowDailyPopup();
  }

  Future<void> _closePopup() async {
    await AppDatabase.saveData();
    await AppDatabase.markPopupShown();
    if (mounted) setState(() => _showDailyPopup = false);
  }

  void _openPopup() {
    if (AppDatabase.workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أضف عمالًا أولًا من القائمة الجانبية')));
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
                const Text('يعمل؟'),
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
                    decoration: const InputDecoration(labelText: 'الورشة'),
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
                        log.overtimeHours == 0 ? '' : fmtNum(log.overtimeHours),
                    enabled: log.worked,
                    decoration:
                        const InputDecoration(labelText: 'ساعات إضافية'),
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
                    initialValue: log.transport == 0 ? '' : fmtNum(log.transport),
                    enabled: log.worked,
                    decoration:
                        const InputDecoration(labelText: 'أجور النقل (XOF)'),
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
                    decoration: const InputDecoration(labelText: 'ملاحظة'),
                    onChanged: (val) {
                      log.note = val;
                      AppDatabase.saveData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('إجمالي اليوم: ${fmtMoney(log.total(worker.dailyRate))} XOF',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayName = kDayNames[_today.weekday % 7];
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
                          'التقرير اليومي - $dayName ${fmtDate(_today)}',
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
                  child: const Text('حفظ وإغلاق التقرير اليومي',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
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
      {super.key, required this.onDataUpdated, required this.onOpenDailyReport});

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final workingToday = AppDatabase.workers
        .where((w) => w.logFor(today)?.worked ?? false)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WookFlow - إدارة الورش والعمال',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('مدير الورشة (Abidjan)'),
              accountEmail: Text('نظام إدارة المشاريع v1.0.0'),
              currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child:
                      Icon(Icons.engineering, size: 40, color: Colors.indigo)),
              decoration: BoxDecoration(color: Colors.indigo),
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('التقرير اليومي (حضور اليوم)'),
              onTap: () {
                Navigator.pop(context);
                onOpenDailyReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('1. إضافة عامل جديد'),
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
              title: const Text('3. حذف عامل'),
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
              title: const Text('4. اسماء مواقع العمل'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SitesScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt),
              title: const Text('الورش المسلمة والمنتهية'),
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
              title: const Text('5. دفعة جديدة (حسابات الورش)'),
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
              title: const Text('6. قائمة العمال وتعديلهم'),
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
              title: const Text('7. ملخص الأسبوع والتقارير'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WeeklySummaryScreen()));
                onDataUpdated();
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
              label: const Text('التقرير اليومي (تسجيل حضور اليوم)',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(context, 'العمال اليوم', '$workingToday',
                      Icons.people, Colors.blue),
                  _buildDashboardCard(
                      context,
                      'الورش النشطة',
                      '${AppDatabase.sites.where((s) => !s.isDelivered).length}',
                      Icons.apartment,
                      Colors.orange),
                  _buildDashboardCard(context, 'سعر ساعة العمل', '1000 XOF',
                      Icons.money, Colors.green),
                  _buildDashboardCard(context, 'ملخص الأسبوع', 'عرض التقارير',
                      Icons.bar_chart, Colors.purple, onTap: () async {
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
          title: const Text('إضافة عامل جديد'),
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
                decoration:
                    const InputDecoration(labelText: 'اسم العامل (إجباري)'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'يرجى إدخال اسم العامل'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                    labelText: 'اليومية أو الأجر (إجباري) - (الساعة 1000 XOF)'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'يرجى إدخال اليومية'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'رقم الهاتف (اختياري)'),
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
                            ? 'تم إضافة العامل وحفظه'
                            : 'فشل الحفظ: ${AppDatabase.lastError}')));
                  }
                },
                child: const Text('حفظ العامل',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
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
        title: const Text('حذف العمال'),
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
                      ? 'تم حذف العمال المحددين بنجاح'
                      : 'فشل الحفظ: ${AppDatabase.lastError}')));
            },
          ),
        ],
      ),
      body: AppDatabase.workers.isEmpty
          ? const Center(child: Text('لا يوجد عمال مضافون حالياً'))
          : Column(
              children: [
                CheckboxListTile(
                  title: const Text('اختيار الجميع',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                            'اليومية: ${fmtMoney(worker.dailyRate)} XOF | الهاتف: ${worker.phone}'),
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
        title: const Text('إضافة موقع عمل جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم الموقع')),
            TextField(
                controller: _locationController,
                decoration:
                    const InputDecoration(labelText: 'الموقع (العنوان)')),
            TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                    labelText: 'الأجر الكامل للورشة (Total)'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء')),
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
            child: const Text('حفظ'),
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
          title: const Text('مواقع العمل النشطة'),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: activeSites.isEmpty
          ? const Center(child: Text('لا توجد ورش نشطة حالياً'))
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
                        'العنوان: ${site.location} | الإجمالي: ${fmtMoney(site.totalContractAmount)} XOF'),
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
                        messenger.showSnackBar(const SnackBar(
                            content: Text('تم تسليم الورشة ونقلها للأرشيف')));
                      },
                      child: const Text('تسليم الورشة'),
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
          title: const Text('الورش المسلمة والمنتهية'),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: deliveredSites.isEmpty
          ? const Center(child: Text('لا توجد ورش مسلمة حتى الآن'))
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
                        'العنوان: ${site.location} | الأجر الإجمالي: ${fmtMoney(site.totalContractAmount)} XOF\nالواصل: ${fmtMoney(site.totalPaid)} XOF (تم التسليم)'),
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
          title: const Text('إدارة الدفعات والواصل'),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: activeSites.isEmpty
          ? const Center(child: Text('لا توجد ورش نشطة لإضافة دفعات'))
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
                        'الإجمالي: ${fmtMoney(site.totalContractAmount)} | الواصل: ${fmtMoney(site.totalPaid)} | الباقي: ${fmtMoney(site.totalContractAmount - site.totalPaid)} XOF'),
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
        title: Text('إضافة دفعة لـ ${site.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'أجار الورشة الإجمالي: ${fmtMoney(site.totalContractAmount)} XOF'),
            Text('مجموع الدفعات (الواصل): ${fmtMoney(site.totalPaid)} XOF'),
            Text(
                'الباقي: ${fmtMoney(site.totalContractAmount - site.totalPaid)} XOF',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: paymentController,
              decoration:
                  const InputDecoration(labelText: 'قيمة الدفعة الجديدة (XOF)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء')),
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
            child: const Text('حفظ'),
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
          title: const Text('قائمة العمال وتعديل بياناتهم'),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: AppDatabase.workers.isEmpty
          ? const Center(child: Text('لا يوجد عمال مضافون'))
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
                        'اليومية: ${fmtMoney(worker.dailyRate)} XOF | الهاتف: ${worker.phone}'),
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
        TextEditingController(text: fmtNum(worker.dailyRate));
    final phoneController = TextEditingController(text: worker.phone);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل بيانات العامل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم العامل')),
            TextField(
                controller: rateController,
                decoration: const InputDecoration(labelText: 'اليومية (XOF)'),
                keyboardType: TextInputType.number),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء')),
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
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }
}

// ======================= التقارير الأسبوعية =======================

// شريط التنقل بين الأسابيع
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.indigo),
              onPressed: onPrev),
          Text(
              'الأسبوع: ${fmtDate(weekStart)}/${weekStart.year}  ←  ${fmtDate(end)}/${end.year}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.indigo),
              onPressed: onNext),
        ],
      ),
    );
  }
}

String _dayCellText(DayLog? log, double rate) {
  if (log == null) return '';
  if (!log.worked) return 'عطلة';
  return fmtMoney(log.total(rate));
}

String buildWorkerWeekText(Worker w, DateTime ws) {
  final sb = StringBuffer();
  sb.writeln('📊 تقرير العامل: ${w.name}');
  sb.writeln('📅 الأسبوع: ${fmtDate(ws)} → ${fmtDate(addDays(ws, 6))}');
  sb.writeln('');
  double total = 0;
  for (int i = 0; i < 7; i++) {
    final d = addDays(ws, i);
    final log = w.logFor(d);
    final label = '${kDayNames[i]} ${fmtDate(d)}';
    if (log == null) {
      sb.writeln('$label: —');
    } else if (!log.worked) {
      sb.writeln('$label: عطلة');
    } else {
      final t = log.total(w.dailyRate);
      total += t;
      sb.writeln(
          '$label: ${log.site.isEmpty ? "" : "${log.site} | "}إضافي ${fmtNum(log.overtimeHours)}س | نقل ${fmtMoney(log.transport)} = ${fmtMoney(t)}');
    }
  }
  sb.writeln('');
  sb.writeln('💰 المجموع الأسبوعي: ${fmtMoney(total)} XOF');
  return sb.toString();
}

String buildAllWeekText(DateTime ws) {
  final sb = StringBuffer();
  sb.writeln('📊 التقرير الأسبوعي لجميع العمال');
  sb.writeln('📅 ${fmtDate(ws)} → ${fmtDate(addDays(ws, 6))}');
  sb.writeln('');
  double grand = 0;
  for (final w in AppDatabase.workers) {
    final t = w.weekTotal(ws);
    grand += t;
    sb.writeln('👷 ${w.name}: ${fmtMoney(t)} XOF');
  }
  sb.writeln('');
  sb.writeln('💰 المجموع الكلي: ${fmtMoney(grand)} XOF');
  return sb.toString();
}

pw.Widget _pdfCell(String t, {bool bold = false}) => pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(t,
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );

Future<void> shareWorkerWeekPdf(Worker w, DateTime ws) async {
  final pdf = pw.Document();
  final rows = <pw.TableRow>[
    pw.TableRow(children: [
      _pdfCell('اليوم', bold: true),
      _pdfCell('الورشة', bold: true),
      _pdfCell('إضافي', bold: true),
      _pdfCell('نقل', bold: true),
      _pdfCell('المبلغ', bold: true),
    ]),
  ];
  for (int i = 0; i < 7; i++) {
    final d = addDays(ws, i);
    final log = w.logFor(d);
    rows.add(pw.TableRow(children: [
      _pdfCell('${kDayNames[i]} ${fmtDate(d)}'),
      _pdfCell(log == null ? '-' : (log.worked ? log.site : 'عطلة')),
      _pdfCell(log != null && log.worked ? fmtNum(log.overtimeHours) : '-'),
      _pdfCell(log != null && log.worked ? fmtMoney(log.transport) : '-'),
      _pdfCell(log == null ? '-' : fmtMoney(log.total(w.dailyRate))),
    ]));
  }
  pdf.addPage(
    pw.Page(
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('${w.name} - ${fmtDate(ws)} / ${fmtDate(addDays(ws, 6))}',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 14),
          pw.Table(border: pw.TableBorder.all(), children: rows),
          pw.SizedBox(height: 14),
          pw.Text('TOTAL: ${fmtMoney(w.weekTotal(ws))} XOF',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ),
  );
  await Printing.sharePdf(
      bytes: await pdf.save(), filename: 'report_${w.name}.pdf');
}

Future<void> shareAllWeekPdf(DateTime ws) async {
  final pdf = pw.Document();
  final header = <pw.Widget>[_pdfCell('Worker', bold: true)];
  for (int i = 0; i < 7; i++) {
    header.add(_pdfCell('${kDayNames[i]}\n${fmtDate(addDays(ws, i))}',
        bold: true));
  }
  header.add(_pdfCell('TOTAL', bold: true));

  final rows = <pw.TableRow>[pw.TableRow(children: header)];
  double grand = 0;
  for (final w in AppDatabase.workers) {
    final cells = <pw.Widget>[_pdfCell(w.name)];
    for (int i = 0; i < 7; i++) {
      final log = w.logFor(addDays(ws, i));
      cells.add(_pdfCell(_dayCellText(log, w.dailyRate)));
    }
    final t = w.weekTotal(ws);
    grand += t;
    cells.add(_pdfCell(fmtMoney(t), bold: true));
    rows.add(pw.TableRow(children: cells));
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('${fmtDate(ws)} / ${fmtDate(addDays(ws, 6))}',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table(border: pw.TableBorder.all(), children: rows),
          pw.SizedBox(height: 12),
          pw.Text('GRAND TOTAL: ${fmtMoney(grand)} XOF',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ),
  );
  await Printing.sharePdf(bytes: await pdf.save(), filename: 'weekly_all.pdf');
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
    double grand = 0;
    for (final w in AppDatabase.workers) {
      grand += w.weekTotal(_weekStart);
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text('ملخص الأسبوع والرواتب'),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: AppDatabase.workers.isEmpty
          ? const Center(child: Text('لا توجد بيانات لعرض الملخص'))
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
                          title: const Text('1. التقرير المشترك لجميع العمال',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text(
                              'كل أيام الأسبوع (الأحد → السبت) | المجموع: ${fmtMoney(grand)} XOF'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AllWorkersWeekScreen(
                                            weekStart: _weekStart)));
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('2. تقرير كل عامل على حدة:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...AppDatabase.workers.map((worker) {
                        final logs = worker.weekLogs(_weekStart);
                        final days =
                            logs.where((l) => l != null && l.worked).length;
                        return Card(
                          child: ListTile(
                            title: Text(worker.name),
                            subtitle: Text('أيام العمل: $days'),
                            trailing: Text(
                                '${fmtMoney(worker.weekTotal(_weekStart))} XOF',
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
        title: const Text('التقرير المشترك لجميع العمال'),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF',
            onPressed: () => shareAllWeekPdf(_weekStart),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة كرسالة',
            onPressed: () => Share.share(buildAllWeekText(_weekStart)),
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
                    const DataColumn(label: Text('العامل')),
                    for (int i = 0; i < 7; i++)
                      DataColumn(
                        label: Text(
                            '${kDayNames[i]}\n${fmtDate(addDays(_weekStart, i))}',
                            textAlign: TextAlign.center),
                      ),
                    const DataColumn(label: Text('المجموع')),
                  ],
                  rows: [
                    ...workers.map((w) => DataRow(cells: [
                          DataCell(Text(w.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                          for (int i = 0; i < 7; i++)
                            DataCell(Text(_dayCellText(
                                w.logFor(addDays(_weekStart, i)),
                                w.dailyRate))),
                          DataCell(Text(fmtMoney(w.weekTotal(_weekStart)),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo))),
                        ])),
                    DataRow(cells: [
                      const DataCell(Text('المجموع',
                          style: TextStyle(fontWeight: FontWeight.bold))),
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
                const Text('المجموع الكلي لجميع العمال:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${fmtMoney(grand)} XOF',
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
    if (log == null) return 'لم يُسجَّل (اضغط للتعديل)';
    if (!log.worked) return 'عطلة';
    return 'الورشة: ${log.site.isEmpty ? "—" : log.site}\nإضافي: ${fmtNum(log.overtimeHours)} س | نقل: ${fmtMoney(log.transport)} XOF';
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
            : fmtNum(existing.overtimeHours));
    final trCtrl = TextEditingController(
        text: (existing == null || existing.transport == 0)
            ? ''
            : fmtNum(existing.transport));
    final noteCtrl = TextEditingController(text: existing?.note ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text('${kDayNames[day.weekday % 7]} ${fmtDate(day)} - ${w.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('يعمل؟'),
                    Switch(
                        value: worked,
                        onChanged: (v) => setD(() => worked = v)),
                  ],
                ),
                if (names.isNotEmpty)
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'الورشة'),
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
                  decoration: const InputDecoration(labelText: 'ساعات إضافية'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: trCtrl,
                  enabled: worked,
                  decoration:
                      const InputDecoration(labelText: 'أجور النقل (XOF)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: noteCtrl,
                  enabled: worked,
                  decoration: const InputDecoration(labelText: 'ملاحظة'),
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
                child:
                    const Text('مسح اليوم', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء')),
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
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

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
        title: Text('تقرير: ${w.name}'),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => shareWorkerWeekPdf(w, _weekStart),
            tooltip: 'تنزيل ومشاركة PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(buildWorkerWeekText(w, _weekStart)),
            tooltip: 'مشاركة كرسالة عبر واتساب',
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
                        title: Text('${kDayNames[i]}  ${fmtDate(d)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(_describe(log)),
                        trailing: Text(
                            log == null
                                ? '—'
                                : '${fmtMoney(log.total(w.dailyRate))} XOF',
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
                        _sumRow('أيام العمل', '$daysWorked يوم'),
                        _sumRow('مجموع اليوميات',
                            '${fmtMoney(baseTotal)} XOF'),
                        _sumRow('مجموع الإضافي',
                            '${fmtMoney(overtimeTotal)} XOF'),
                        _sumRow('مجموع المواصلات',
                            '${fmtMoney(transportTotal)} XOF'),
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
                const Text('المجموع الأسبوعي:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${fmtMoney(total)} XOF',
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

  Widget _sumRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value)],
        ),
      );
}
