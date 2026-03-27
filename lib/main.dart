import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thời Khóa Biểu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      home: const TimetablePage(),
    );
  }
}

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final Map<String, List<Map<String, String>?>> _timetableData = {
    'Thứ 2': List.filled(10, null),
    'Thứ 3': List.filled(10, null),
    'Thứ 4': List.filled(10, null),
    'Thứ 5': List.filled(10, null),
    'Thứ 6': List.filled(10, null),
    'Thứ 7': List.filled(10, null),
  };

  final List<String> _days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];

  // Hàm chuyển hướng sang trang chỉnh sửa
  Future<void> _navigateToEdit(String initialDay, int startP, int endP) async {
    final existing = _timetableData[initialDay]![startP - 1];
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSubjectPage(
          days: _days,
          initialDay: initialDay,
          initialStart: startP,
          initialEnd: endP,
          initialSubject: existing?['subject'] ?? '',
          initialRoom: existing?['room'] ?? '',
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // 1. Xóa vị trí cũ
        for (int i = startP - 1; i < endP; i++) {
          _timetableData[initialDay]![i] = null;
        }
        // 2. Lưu vị trí mới (nếu có tên môn)
        final String newDay = result['day'];
        final int newStart = result['start'];
        final int newEnd = result['end'];
        final String? newSubject = result['subject'];
        final String? newRoom = result['room'];

        if (newSubject != null && newSubject.isNotEmpty) {
          for (int i = newStart - 1; i < newEnd; i++) {
            _timetableData[newDay]![i] = {
              'subject': newSubject,
              'room': newRoom ?? '',
            };
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _days.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: SafeArea(
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _days.map((day) => Tab(text: day)).toList(),
            ),
          ),
        ),
        body: TabBarView(
          children: _days.map((day) => _buildDayPage(day)).toList(),
        ),
      ),
    );
  }

  Widget _buildDayPage(String day) {
    final dayData = _timetableData[day]!;
    List<Widget> widgets = [];
    int i = 0;
    while (i < 10) {
      final currentInfo = dayData[i];
      int start = i;
      int end = i;

      if (currentInfo != null) {
        while (end + 1 < 10) {
          final nextInfo = dayData[end + 1];
          if (nextInfo != null &&
              currentInfo['subject'] == nextInfo['subject'] &&
              currentInfo['room'] == nextInfo['room']) {
            end++;
          } else {
            break;
          }
        }
      }

      final startP = start + 1;
      final endP = end + 1;
      final periodText = startP == endP ? '$startP' : '$startP-$endP';

      widgets.add(
        InkWell(
          onTap: () => _navigateToEdit(day, startP, endP),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: currentInfo == null ? Colors.transparent : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: currentInfo == null ? Border.all(color: Colors.grey.withOpacity(0.1)) : null,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      periodText,
                      style: TextStyle(
                        fontWeight: currentInfo != null ? FontWeight.bold : FontWeight.normal,
                        fontSize: currentInfo != null ? 16 : 14,
                        color: currentInfo != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  if (currentInfo != null) ...[
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(currentInfo['subject']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(currentInfo['room']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const Expanded(
                      child: Padding(padding: EdgeInsets.all(12), child: Text('Trống', style: TextStyle(color: Colors.grey, fontSize: 12))),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
      i = end + 1;
    }

    return ListView(padding: const EdgeInsets.only(top: 16, bottom: 80), children: widgets);
  }
}

// TRANG CHỈNH SỬA MỚI
class EditSubjectPage extends StatefulWidget {
  final List<String> days;
  final String initialDay;
  final int initialStart;
  final int initialEnd;
  final String initialSubject;
  final String initialRoom;

  const EditSubjectPage({
    super.key,
    required this.days,
    required this.initialDay,
    required this.initialStart,
    required this.initialEnd,
    required this.initialSubject,
    required this.initialRoom,
  });

  @override
  State<EditSubjectPage> createState() => _EditSubjectPageState();
}

class _EditSubjectPageState extends State<EditSubjectPage> {
  late String selectedDay;
  late int startPeriod;
  late int endPeriod;
  late TextEditingController subjectController;
  late TextEditingController roomController;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDay;
    startPeriod = widget.initialStart;
    endPeriod = widget.initialEnd;
    subjectController = TextEditingController(text: widget.initialSubject);
    roomController = TextEditingController(text: widget.initialRoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa tiết học'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              decoration: const InputDecoration(labelText: 'Ngày', border: OutlineInputBorder()),
              items: widget.days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
              onChanged: (val) => setState(() => selectedDay = val!),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: startPeriod,
                    decoration: const InputDecoration(labelText: 'Từ tiết', border: OutlineInputBorder()),
                    items: List.generate(10, (i) => i + 1).map((p) => DropdownMenuItem(value: p, child: Text('$p'))).toList(),
                    onChanged: (val) {
                      setState(() {
                        startPeriod = val!;
                        if (endPeriod < startPeriod) endPeriod = startPeriod;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: endPeriod,
                    decoration: const InputDecoration(labelText: 'Đến tiết', border: OutlineInputBorder()),
                    items: List.generate(10, (i) => i + 1).where((p) => p >= startPeriod).map((p) => DropdownMenuItem(value: p, child: Text('$p'))).toList(),
                    onChanged: (val) => setState(() => endPeriod = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Tên môn học',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book_outlined, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: 'Phòng học',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.meeting_room_outlined, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận lưu'),
                      content: const Text('Cập nhật thay đổi vào bảng?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Thoát')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context, {
                              'day': selectedDay,
                              'start': startPeriod,
                              'end': endPeriod,
                              'subject': subjectController.text,
                              'room': roomController.text,
                            });
                          },
                          child: const Text('Lưu'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('LƯU THAY ĐỔI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
