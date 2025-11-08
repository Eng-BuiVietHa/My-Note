import 'package:flutter/material.dart';
import '../models/note.dart';

// ĐÂY LÀ MÀN HÌNH SAU KHI ẤN DẤU '+'
class NoteEditorScreen extends StatefulWidget {
  // Biến để nhận ghi chú cần chỉnh sửa
  final Note? note;

  const NoteEditorScreen({super.key, this.note}); // Cập nhật constructor

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // initState để điền dữ liệu cũ vào
  @override
  void initState() {
    super.initState();
    // Nếu là chỉnh sửa (note != null), hãy điền text cũ
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Hàm để pop và trả dữ liệu
  void _saveAndExit() {
    Navigator.of(context).pop({
      'title': _titleController.text,
      'content': _contentController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // Nút quay lại
          icon: const Icon(Icons.arrow_back),
          onPressed: _saveAndExit, // GỌI HÀM LƯU VÀ THOÁT
        ),
        title: Text(
          widget.note == null ? 'Ghi chú mới' : 'Sửa ghi chú',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check), // Icon dấu tick
            onPressed: _saveAndExit, // GỌI HÀM LƯU VÀ THOÁT
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField cho TIÊU ĐỀ
            TextField(
              controller: _titleController,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Tiêu đề',
                hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16), // Khoảng cách
            // TextField cho NỘI DUNG GHI CHÚ
            Expanded(
              child: TextField(
                controller: _contentController,
                autofocus: true, // Tự động mở bàn phím
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Ghi chú',
                  hintStyle: TextStyle(color: Colors.grey[700], fontSize: 18),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
                maxLines: null, // Cho phép nhiều dòng
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}