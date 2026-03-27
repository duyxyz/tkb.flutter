import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_subject_page.dart'; // Import trang chỉnh sửa

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  Map<String, List<Map<String, String>?>> _timetableData = {
    'Thứ 2': List.filled(10, null),
    'Thứ 3': List.filled(10, null),
    'Thứ 4': List.filled(10, null),
    'Thứ 5': List.filled(10, null),
    'Thứ 6': List.filled(10, null),
    'Thứ 7': List.filled(10, null),
  };

  final List<String> _days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('timetable_data');
    if (dataString != null) {
      final Map<String, dynamic> jsonData = jsonDecode(dataString);
      setState(() {
        _timetableData = jsonData.map((day, list) {
          return MapEntry(
            day,
            (list as List).map((item) => item != null ? Map<String, String>.from(item) : null).toList(),
          );
        });
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String dataString = jsonEncode(_timetableData);
    await prefs.setString('timetable_data', dataString);
  }

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
      _saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int initialTab = now.weekday - 1;
    if (initialTab < 0 || initialTab > 5) initialTab = 0;

    return DefaultTabController(
      length: _days.length,
      initialIndex: initialTab,
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
    
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // THẺ LỚN BUỔI SÁNG
        _buildSessionCard(day, dayData, [0, 1, 2, 3, 4], 'BUỔI SÁNG'),
        const SizedBox(height: 20),
        // THẺ LỚN BUỔI CHIỀU
        _buildSessionCard(day, dayData, [6, 7, 8, 9], 'BUỔI CHIỀU'),
        const SizedBox(height: 80), // Khoảng trống dưới cùng
      ],
    );
  }

  Widget _buildSessionCard(String day, List<Map<String, String>?> dayData, List<int> indices, String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Để các đường kẻ và màu sắc không tràn ra khỏi góc bo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),
          const Divider(height: 1),
          ..._buildPeriodBlocks(day, dayData, indices),
        ],
      ),
    );
  }

  List<Widget> _buildPeriodBlocks(String day, List<Map<String, String>?> dayData, List<int> indices) {
    List<Widget> blocks = [];
    const double slotHeight = 65.0; // Độ cao tiêu chuẩn của 1 tiết
    int i = 0;
    while (i < indices.length) {
      int currentIdx = indices[i];
      final currentInfo = dayData[currentIdx];
      int start = i;
      int end = i;

      if (currentInfo != null) {
        while (end + 1 < indices.length) {
          final nextIdx = indices[end + 1];
          final nextInfo = dayData[nextIdx];
          if (nextInfo != null &&
              currentInfo['subject'] == nextInfo['subject'] &&
              currentInfo['room'] == nextInfo['room']) {
            end++;
          } else {
            break;
          }
        }
      }

      final startP = indices[start] + 1;
      final endP = indices[end] + 1;
      final int numSlots = end - start + 1; // Số lượng tiết gộp
      final periodText = startP == endP ? '$startP' : '$startP-$endP';

      // Màu sắc cố định theo tiết bắt đầu
      Color blockColor = Colors.transparent;
      if (currentInfo != null) {
         final colors = [
          Colors.green.withOpacity(0.35),
          Colors.blue.withOpacity(0.35),
          Colors.orange.withOpacity(0.35),
          Colors.purple.withOpacity(0.35),
          Colors.red.withOpacity(0.35),
          Colors.teal.withOpacity(0.35),
          Colors.indigo.withOpacity(0.35),
          Colors.pink.withOpacity(0.35),
          Colors.amber.withOpacity(0.35),
        ];
        int colorIndex = (startP <= 5) ? (startP - 1) : (startP - 2);
        blockColor = colors[colorIndex % colors.length];
      }

      blocks.add(
        InkWell(
          onLongPress: () => _navigateToEdit(day, startP, endP),
          child: Container(
            height: numSlots * slotHeight,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                numSlots > 1 && currentInfo != null
                    ? SizedBox(
                        width: 60,
                        height: numSlots * slotHeight,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: 60,
                                color: blockColor,
                                alignment: Alignment.center,
                                child: Text(periodText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 60,
                                alignment: Alignment.center,
                                child: Text(currentInfo['room']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: 60,
                        height: numSlots * slotHeight,
                        decoration: BoxDecoration(color: blockColor),
                        alignment: Alignment.center,
                        child: Text(
                          periodText,
                          style: TextStyle(
                            fontWeight: currentInfo != null ? FontWeight.bold : FontWeight.normal,
                            fontSize: currentInfo != null ? 16 : 14,
                            color: currentInfo != null ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                if (currentInfo != null) ...[
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: numSlots > 1
                          ? Text(
                              currentInfo['subject']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: numSlots * 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(currentInfo['subject']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                                  child: Text(currentInfo['room']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                    ),
                  ),
                ] else ...[
                  const Expanded(
                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Trống', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      i = end + 1;
    }
    return blocks;
  }
}
