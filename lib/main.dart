import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const WookFlowApp());
}

class WookFlowApp extends StatefulWidget {
  const WookFlowApp({super.key});

  @override
  State<WookFlowApp> createState() => _WookFlowAppState();
}

class _WookFlowAppState extends State<WookFlowApp> {
  Locale _locale = const Locale('ar');

  void _changeLanguage(String langCode) {
    setState(() {
      _locale = Locale(langCode);
    });
  }

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
      home: DailyCheckInWrapper(onLanguageChanged: _changeLanguage, currentLocale: _locale),
    );
  }
}

class Worker {
  String id;
  String name;
  double dailyRate;
  String phone;
  bool isActiveToday;
  String currentSite;
  String note;
  double overtimeHours;
  double transportAllowance;

  Worker({
    required this.id,
    required this.name,
    required this.dailyRate,
    this.phone = '',
    this.isActiveToday = true,
    this.currentSite = '',
    this.note = '',
    this.overtimeHours = 0.0,
    this.transportAllowance = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'dailyRate': dailyRate, 'phone': phone,
    'isActiveToday': isActiveToday, 'currentSite': currentSite,
    'note': note, 'overtimeHours': overtimeHours, 'transportAllowance': transportAllowance,
  };

  factory Worker.fromJson(Map<String, dynamic> json) => Worker(
    id: json['id'], name: json['name'], dailyRate: json['dailyRate'],
    phone: json['phone'] ?? '', isActiveToday: json['isActiveToday'] ?? true,
    currentSite: json['currentSite'] ?? '', note: json['note'] ?? '',
    overtimeHours: json['overtimeHours'] ?? 0.0, transportAllowance: json['transportAllowance'] ?? 0.0,
  );
}

class WorkSite {
  String id;
  String name;
  String location;
  double totalContractAmount;
  double totalPaid;
  bool isDelivered; // هل تم تسليم الورشة؟

  WorkSite({
    required this.id,
    required this.name,
    required this.location,
    required this.totalContractAmount,
    this.totalPaid = 0.0,
    this.isDelivered = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'location': location,
    'totalContractAmount': totalContractAmount, 'totalPaid': totalPaid, 'isDelivered': isDelivered,
  };

  factory WorkSite.fromJson(Map<String, dynamic> json) => WorkSite(
    id: json['id'], name: json['name'], location: json['location'],
    totalContractAmount: json['totalContractAmount'], totalPaid: json['totalPaid'] ?? 0.0,
    isDelivered: json['isDelivered'] ?? false,
  );
}

// إدارة الذاكرة المحلية
class AppDatabase {
  static List<Worker> workers = [];
  static List<WorkSite> sites = [];

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? workersStr = prefs.getString('workers_data');
    String? sitesStr = prefs.getString('sites_data');

    if (workersStr != null) {
      List decoded = jsonDecode(workersStr);
      workers = decoded.map((e) => Worker.fromJson(e)).toList();
    }
    if (sitesStr != null) {
      List decoded = jsonDecode(sitesStr);
      sites = decoded.map((e) => WorkSite.fromJson(e)).toList();
    }
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('workers_data', jsonEncode(workers.map((e) => e.toJson()).toList()));
    prefs.setString('sites_data', jsonEncode(sites.map((e) => e.toJson()).toList()));
  }
}

class DailyCheckInWrapper extends StatefulWidget {
  final Function(String) onLanguageChanged;
  final Locale currentLocale;

  const DailyCheckInWrapper({super.key, required this.onLanguageChanged, required this.currentLocale});

  @override
  State<DailyCheckInWrapper> createState() => _DailyCheckInWrapperState();
}

class _DailyCheckInWrapperState extends State<DailyCheckInWrapper> {
  bool _isLoading = true;
  bool _showDailyPopup = false;

  @override
  void initState() {
    super.initState();
    AppDatabase.loadData().then((_) {
      setState(() {
        _isLoading = false;
        // يظهر فقط إذا كان هناك عمال وورش مسجلة
        if (AppDatabase.workers.isNotEmpty) {
          _showDailyPopup = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          MainDashboard(onLanguageChanged: widget.onLanguageChanged, onDataUpdated: () => setState(() {})),
          if (_showDailyPopup && AppDatabase.workers.isNotEmpty)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            const Text('تسجيل الحضور اليومي (كل 24 ساعة)', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _showDailyPopup = false),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: AppDatabase.workers.length,
                          itemBuilder: (context, index) {
                            final worker = AppDatabase.workers[index];
                            final activeSites = AppDatabase.sites.where((s) => !s.isDelivered).toList();
                            return StatefulBuilder(
                              builder: (context, setStateItem) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.between,
                                          children: [
                                            Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Row(
                                              children: [
                                                const Text('يعمل؟'),
                                                Switch(
                                                  value: worker.isActiveToday,
                                                  onChanged: (val) {
                                                    setStateItem(() => worker.isActiveToday = val);
                                                    setState(() {});
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: activeSites.any((s) => s.name == worker.currentSite) ? worker.currentSite : (activeSites.isNotEmpty ? activeSites.first.name : null),
                                                items: activeSites.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                                                onChanged: worker.isActiveToday ? (val) => setStateItem(() => worker.currentSite = val!) : null,
                                                decoration: const InputDecoration(labelText: 'الورشة'),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextField(
                                                enabled: worker.isActiveToday,
                                                decoration: const InputDecoration(labelText: 'ساعات إضافية'),
                                                keyboardType: TextInputType.number,
                                                onChanged: (val) => worker.overtimeHours = double.tryParse(val) ?? 0.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                enabled: worker.isActiveToday,
                                                decoration: const InputDecoration(labelText: 'أجور النقل (XOF)'),
                                                keyboardType: TextInputType.number,
                                                onChanged: (val) => worker.transportAllowance = double.tryParse(val) ?? 0.0,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextField(
                                                enabled: worker.isActiveToday,
                                                decoration: const InputDecoration(labelText: 'ملاحظة'),
                                                onChanged: (val) => worker.note = val,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: const Size(double.infinity, 50)),
                          onPressed: () {
                            AppDatabase.saveData();
                            setState(() => _showDailyPopup = false);
                          },
                          child: const Text('حفظ وإغلاق التقرير اليومي', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MainDashboard extends StatelessWidget {
  final Function(String) onLanguageChanged;
  final VoidCallback onDataUpdated;
  const MainDashboard({super.key, required this.onLanguageChanged, required this.onDataUpdated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WookFlow - إدارة الورش والعمال', style: TextStyle(color: Colors.white)),
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
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.engineering, size: 40, color: Colors.indigo)),
              decoration: BoxDecoration(color: Colors.indigo),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('1. إضافة عامل جديد'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWorkerScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('2. تغيير اللغة'),
              onTap: () => _showLanguageDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_remove),
              title: const Text('3. حذف عامل'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteWorkerScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('4. اسماء مواقع العمل'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const SitesScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt),
              title: const Text('4. م. الورش المسلمة والمنتهية'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveredSitesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('5. دفعة جديدة (حسابات الورش)'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const NewPaymentScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('6. قائمة العمال وتعديلهم'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkersListScreen()));
                onDataUpdated();
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('7. ملخص الأسبوع والتقارير'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WeeklySummaryScreen()));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(context, 'العمال النشطون', '${AppDatabase.workers.where((w) => w.isActiveToday).length}', Icons.people, Colors.blue),
            _buildDashboardCard(context, 'الورش النشطة', '${AppDatabase.sites.where((s) => !s.isDelivered).length}', Icons.apartment, Colors.orange),
            _buildDashboardCard(context, 'سعر ساعة العمل', '1000 XOF', Icons.money, Colors.green),
            _buildDashboardCard(context, 'ملخص الأسبوع', 'عرض التقارير', Icons.bar_chart, Colors.purple, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WeeklySummaryScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
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
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 5),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('العربية'), onTap: () { onLanguageChanged('ar'); Navigator.pop(context); }),
            ListTile(title: const Text('Français'), onTap: () { onLanguageChanged('fr'); Navigator.pop(context); }),
            ListTile(title: const Text('English'), onTap: () { onLanguageChanged('en'); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }
}

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rateController = TextEditingController(text: '8000');
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عامل جديد'), backgroundColor: Colors.indigo, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم العامل (إجباري)'),
                validator: (value) => value!.isEmpty ? 'يرجى إدخال اسم العامل' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(labelText: 'اليومية أو الأجر (إجباري) - (الساعة 1000 XOF)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'يرجى إدخال اليومية' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف (اختياري)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final activeSites = AppDatabase.sites.where((s) => !s.isDelivered).toList();
                    AppDatabase.workers.add(Worker(
                      id: DateTime.now().toString(),
                      name: _nameController.text,
                      dailyRate: double.parse(_rateController.text),
                      phone: _phoneController.text,
                      currentSite: activeSites.isNotEmpty ? activeSites.first.name : '',
                    ));
                    AppDatabase.saveData();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة العامل بنجاح وحفظه')));
                  }
                },
                child: const Text('حفظ العامل', style: TextStyle(color: Colors.white, fontSize: 16)),
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
            onPressed: () {
              setState(() {
                AppDatabase.workers.removeWhere((w) => _selectedWorkers[w.id] == true);
                AppDatabase.saveData();
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف العمال المحددين بنجاح')));
            },
          ),
        ],
      ),
      body: AppDatabase.workers.isEmpty
          ? const Center(child: Text('لا يوجد عمال مضافون حالياً'))
          : Column(
              children: [
                CheckboxListTile(
                  title: const Text('اختيار الجميع', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        subtitle: Text('اليومية: ${worker.dailyRate} XOF | الهاتف: ${worker.phone}'),
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

class SitesScreen extends StatefulWidget {
  const SitesScreen({super.key});

  @override
  State<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _amountController = TextEditingController();

  void _showAddSiteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة موقع عمل جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'اسم الموقع')),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'الموقع (العنوان)')),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'الأجر الكامل للورشة (Total)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                AppDatabase.sites.add(WorkSite(
                  id: DateTime.now().toString(),
                  name: _nameController.text,
                  location: _locationController.text,
                  totalContractAmount: double.tryParse(_amountController.text) ?? 0.0,
                ));
                AppDatabase.saveData();
                _nameController.clear();
                _locationController.clear();
                _amountController.clear();
                Navigator.pop(context);
                setState(() {});
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
      appBar: AppBar(title: const Text('مواقع العمل النشطة'), backgroundColor: Colors.indigo, iconTheme: const IconThemeData(color: Colors.white)),
      body: activeSites.isEmpty
          ? const Center(child: Text('لا توجد ورش نشطة حالياً'))
          : ListView.builder(
              itemCount: activeSites.length,
              itemBuilder: (context, index) {
                final site = activeSites[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(site.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('العنوان: ${site.location} | الإجمالي: ${site.totalContractAmount} XOF'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () {
                        setState(() {
                          site.isDelivered = true;
                          AppDatabase.saveData();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسليم الورشة ونقلها للأرشيف')));
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

// شاشة الورش المسلمة والمنتهية
class DeliveredSitesScreen extends StatelessWidget {
  const DeliveredSitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveredSites = AppDatabase.sites.where((s) => s.isDelivered).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('الورش المسلمة والمنتهية'), backgroundColor: Colors.indigo, iconTheme: const IconThemeData(color: Colors.white)),
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
                    title: Text(site.name, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
                    subtitle: Text('العنوان: ${site.location} | الأجر الإجمالي: ${site.totalContractAmount} XOF\nالواصل: ${site.totalPaid} XOF (تم التسليم)'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}

class NewPaymentScreen extends StatelessWidget {
  const NewPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activeSites = AppDatabase.sites.where((s) => !s.isDelivered).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الدفعات والواصل'), backgroundColor: Colors.indigo, iconTheme: const IconThemeData(color: Colors.white)),
      body: activeSites.isEmpty
          ? const Center(child: Text('لا توجد ورش نشطة لإضافة دفعات'))
          : ListView.builder(
              itemCount: activeSites.length,
              itemBuilder: (context, index) {
                final site = activeSites[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(site.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('الإجمالي: ${site.totalContractAmount} | الواصل: ${site.totalPaid} | الباقي: ${site.totalContractAmount - site.totalPaid} XOF'),
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
      builder: (context) => AlertDialog(
        title: Text('إضافة دفعة لـ ${site.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أجار الورشة الإجمالي: ${site.totalContractAmount} XOF'),
            Text('مجموع الدفعات (الواصل): ${site.totalPaid} XOF'),
            Text('الباقي: ${site.totalContractAmount - site.totalPaid} XOF', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: paymentController,
              decoration: const InputDecoration(labelText: 'قيمة الدفعة الجديدة (XOF)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              double payment = double.tryParse(paymentController.text) ?? 0.0;
              site.totalPaid += payment;
              AppDatabase.saveData();
              Navigator.pop(context);
              (context as Element).markNeedsBuild();
            },
            child: const Text('حفظ'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة العمال وتعديل بياناتهم'), backgroundColor: Colors.indigo, iconTheme: const IconThemeData(color: Colors.white)),
      body: AppDatabase.workers.isEmpty
          ? const Center(child: Text('لا يوجد عمال مضافون'))
          : ListView.builder(
              itemCount: AppDatabase.workers.length,
              itemBuilder: (context, index) {
                final worker = AppDatabase.workers[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('اليومية: ${worker.dailyRate} XOF | الورشة: ${worker.currentSite}'),
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
    final rateController = TextEditingController(text: worker.dailyRate.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات العامل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم العامل')),
            TextField(controller: rateController, decoration: const InputDecoration(labelText: 'اليومية (XOF)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                worker.name = nameController.text;
                worker.dailyRate = double.tryParse(rateController.text) ?? worker.dailyRate;
                AppDatabase.saveData();
              });
              Navigator.pop(context);
            },
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }
}

class WeeklySummaryScreen extends StatelessWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملخص الأسبوع والرواتب'), backgroundColor: Colors.indigo, iconTheme: const IconThemeData(color: Colors.white)),
      body: AppDatabase.workers.isEmpty
          ? const Center(child: Text('لا توجد بيانات لعرض الملخص'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Colors.indigo.shade50,
                  child: ListTile(
                    title: const Text('1. المجموع الكلي لجميع العمال', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text('اضغط هنا لعرض تفاصيل يوميات جميع العمال والأجور والإضافي'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllWorkersDailyLogScreen())),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('2. تفاصيل كل عامل على حدة:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...AppDatabase.workers.map((worker) => Card(
                  child: ListTile(
                    title: Text(worker.name),
                    subtitle: Text('الورشة: ${worker.currentSite} | الإضافي: ${worker.overtimeHours} ساعة'),
                    trailing: const Icon(Icons.receipt_long, color: Colors.indigo),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerDetailReportScreen(worker: worker))),
                  ),
                )),
              ],
            ),
    );
  }
}

class AllWorkersDailyLogScreen extends StatelessWidget {
  const AllWorkersDailyLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double grandTotal = AppDatabase.workers.fold(0, (sum, w) => sum + (w.isActiveToday ? w.dailyRate + (w.overtimeHours * 1000) + w.transportAllowance : 0));

    return Scaffold(
      appBar: AppBar(title: const Text('يوميات جميع العمال والرواتب'), backgroundColor: Colors.indigo, iconTheme: const IconThemeData(color: Colors.white)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: AppDatabase.workers.length,
              itemBuilder: (context, index) {
                final w = AppDatabase.workers[index];
                double totalWorker = w.isActiveToday ? w.dailyRate + (w.overtimeHours * 1000) + w.transportAllowance : 0;
                return ListTile(
                  title: Text(w.name),
                  subtitle: Text('الحالة: ${w.isActiveToday ? "يعمل" : "عطلة"} | إضافي: ${w.overtimeHours} س | مواصلات: ${w.transportAllowance} XOF'),
                  trailing: Text('$totalWorker XOF', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.indigo.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المجموع الكلي لجميع العمال:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$grandTotal XOF', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerDetailReportScreen extends StatelessWidget {
  final Worker worker;
  const WorkerDetailReportScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    double totalEarned = worker.isActiveToday ? worker.dailyRate + (worker.overtimeHours * 1000) + worker.transportAllowance : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('تقرير: ${worker.name}'),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تنزيل ملف PDF بنجاح')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاهز للمشاركة عبر الواتساب')));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اسم العامل: ${worker.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            const Text('تفاصيل اليوم الحالي:', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text('الحالة والورشة'),
              subtitle: Text(worker.isActiveToday ? "عمل في: ${worker.currentSite}" : "عطلة اليوم"),
              trailing: Text('${worker.dailyRate} XOF'),
            ),
            ListTile(
              title: const Text('الساعات الإضافية'),
              subtitle: Text('${worker.overtimeHours} ساعة (سعر الساعة 1000 XOF)'),
              trailing: Text('${worker.overtimeHours * 1000} XOF'),
            ),
            ListTile(
              title: const Text('بدل المواصلات'),
              subtitle: const Text('أجار الطريق والنقل'),
              trailing: Text('${worker.transportAllowance} XOF'),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المجموع الكامل:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('$totalEarned XOF', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
