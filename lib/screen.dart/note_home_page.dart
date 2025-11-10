import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widget/save_editor.dart';

// ĐÂY LÀ MÀN HÌNH CHÍNH (TẤT CẢ GHI CHÚ)
class NoteHomePage extends StatefulWidget {
  // Nhận dữ liệu và hàm từ MyApp
  final List<Note> notes;
  final VoidCallback onNavigateToFolders;
  final Future<Map?> Function(Note?) onOpenEditor;
  final Function(String, String) onCreateNote; // Hàm tạo cho màn hình chính
  final Function(Note, String, String) onEditNote;
  final Function(Note) onDeleteNote;

  const NoteHomePage({
    super.key,
    required this.notes,
    required this.onNavigateToFolders,
    required this.onOpenEditor,
    required this.onCreateNote,
    required this.onEditNote,
    required this.onDeleteNote,
  });

  @override
  State<NoteHomePage> createState() => _NoteHomePageState();
}

class _NoteHomePageState extends State<NoteHomePage> {
  // State cho tìm kiếm
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm mở trình soạn thảo cục bộ
  Future<void> _handleEdit(BuildContext context, Note? note) async {
    final result = await widget.onOpenEditor(note); // Gọi hàm từ MyApp
    if (result == null) return;
    if (result['action'] == 'delete') {
      widget.onDeleteNote(result['note']);
      return;
    }
    if (result['action'] == 'save') {
      final title = result['title'];
      final content = result['content'];
      if (note == null) {
        widget.onCreateNote(title, content);
      } else {
        widget.onEditNote(note, title, content);
      }
    }
  }

  // Hàm hiển thị dialog xóa
  Future<void> _showDeleteDialog(BuildContext context, Note note) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title:
              const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
          content: const Text(
              'Bạn thật sự muốn xóa ghi chú này sao? (Sẽ được chuyển vào thùng rác)',
              style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Không', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Có', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onDeleteNote(note); // Gọi hàm xóa
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách ghi chú
    final displayedNotes = widget.notes.where((note) {
      final titleMatch =
          note.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final contentMatch =
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      return titleMatch || contentMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: widget.onNavigateToFolders, // Bấm để mở thư mục
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Tất cả ghi chú',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            if (displayedNotes.isNotEmpty)
              Text(
                'Ghi chú',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: displayedNotes.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Chưa có ghi chú nào.'
                            : 'Không tìm thấy kết quả.',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: displayedNotes.length,
                      itemBuilder: (context, index) {
                        final note = displayedNotes[index];
                        return NoteCard(
                          note: note,
                          onTap: () {
                            _handleEdit(context, note); // Sửa
                          },
                          onDeletePressed: () {
                            _showDeleteDialog(context, note); // Xóa
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
          _handleEdit(context, null); // Tạo mới
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Tạo ghi chú mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}