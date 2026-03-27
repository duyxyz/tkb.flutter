import 'package:flutter/material.dart';

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
        automaticallyImplyLeading: false, // Bỏ mũi tên quay lại mặc định
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
                    items: [1, 2, 3, 4, 5, 7, 8, 9, 10].map((p) => DropdownMenuItem(value: p, child: Text('$p'))).toList(),
                    onChanged: (val) {
                      setState(() {
                        startPeriod = val!;
                        // Nếu đổi buổi (như từ 4 lên 7), cần cập nhật endPeriod cho đúng dải
                        if (startPeriod <= 5 && endPeriod > 5) {
                          endPeriod = startPeriod;
                        } else if (startPeriod >= 7 && (endPeriod < 7 || endPeriod < startPeriod)) {
                          endPeriod = startPeriod;
                        } else if (endPeriod < startPeriod) {
                          endPeriod = startPeriod;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: endPeriod,
                    decoration: const InputDecoration(labelText: 'Đến tiết', border: OutlineInputBorder()),
                    items: [1, 2, 3, 4, 5, 7, 8, 9, 10]
                        .where((p) => p >= startPeriod && (startPeriod <= 5 ? p <= 5 : p >= 7))
                        .map((p) => DropdownMenuItem(value: p, child: Text('$p')))
                        .toList(),
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
            // Cặp nút bấm Mới (Thoát và Lưu)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('THOÁT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
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
                      child: const Text('LƯU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
