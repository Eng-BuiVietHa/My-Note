import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note/widget/note_editor.dart'; // Import này sẽ hết lỗi vàng
import 'models/note.dart';
import 'widget/save_editor.dart';

// ==================================================
// PHẦN NÀY ĐÚNG, GIỮ NGUYÊN
// ==================================================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Ghi Chú',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900], 
        colorScheme: ColorScheme.dark().copyWith(
          secondary: Colors.grey[800], 
          onSecondary: Colors.white,
          primary: Colors.grey[900],
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.blue,
          selectionColor: Colors.blueGrey,
          selectionHandleColor: Colors.blue,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const NoteHomePage(), // Màn hình chính
    );
  }
}
// ==================================================
// (HẾT PHẦN GIỮ NGUYÊN)
// ==================================================


class NoteHomePage extends StatefulWidget {
  const NoteHomePage({super.key});

  @override
  State<NoteHomePage> createState() => _NoteHomePageState();
}

// *** ĐẢM BẢO TOÀN BỘ CODE BÊN DƯỚI NẰM TRONG CLASS NÀY ***
class _NoteHomePageState extends State<NoteHomePage> {
  
  final List<Note> _notes = [];

  // ==================================================
  // HÀM 1: CHUYỂN ĐẾN TRÌNH SOẠN THẢO
  // ==================================================
  Future<void> _navigateToEditor({Note? note, int? index}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        // Dòng này sử dụng 'note_editor.dart' -> sẽ hết lỗi vàng
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );

    if (result != null && result is Map) {
      final String title = result['title'] as String;
      final String content = result['content'] as String;

      if (title.isEmpty && content.isEmpty) {
        if (index != null) {
          setState(() {
            _notes.removeAt(index);
          });
        }
        return; 
      }

      setState(() {
        if (index != null) {
          // CHẾ ĐỘ CHỈNH SỬA
          _notes[index].title = title;
          _notes[index].content = content;
          _notes[index].timestamp = DateTime.now();
        } else {
          // CHẾ ĐỘ TẠO MỚI
          _notes.insert(
            0,
            Note(
              title: title,
              content: content,
              timestamp: DateTime.now(),
            ),
          );
        }
      });
    }
  }

  // ==================================================
  // HÀM 2: XÓA GHI CHÚ
  // ==================================================
  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  // ==================================================
  // HÀM 3: HIỂN THỊ HỘP THOẠI XÓA
  // ==================================================
  Future<void> _showDeleteDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Bạn thật sự muốn xóa ghi chú này sao?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Không', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Có', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteNote(index); // Gọi hàm xóa
              },
            ),
          ],
        );
      },
    );
  }


  // ==================================================
  // HÀM BUILD (NƠI HIỂN THỊ GIAO DIỆN)
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Text(
              'Tất cả ghi chú',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // THANH TÌM KIẾM
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 24),

            // TIÊU ĐỀ
            if (_notes.isNotEmpty)
              Text(
                'Ghi chú',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),

            // DANH SÁCH GHI CHÚ
            Expanded(
              child: _notes.isEmpty
                  ? Center(
                      child: Text(
                        'Chưa có ghi chú nào.',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        return NoteCard(
                          note: _notes[index],
                          onTap: () {
                            // Dòng này sẽ hết lỗi đỏ
                            _navigateToEditor(
                              note: _notes[index],
                              index: index,
                            );
                          },
                          onDeletePressed: () {
                             // Dòng này sẽ hết lỗi đỏ
                            _showDeleteDialog(index);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _navigateToEditor(); // Gọi hàm tạo mới
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Tạo ghi chú mới',
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }
  
} 