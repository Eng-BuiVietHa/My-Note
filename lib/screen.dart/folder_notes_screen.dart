import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widget/save_editor.dart';

// Màn hình hiển thị ghi chú BÊN TRONG một thư mục (Stateful để tìm kiếm)
class FolderNotesScreen extends StatefulWidget {
  final String? folderName;
  final List<Note> allNotes;
  final Future<Map?> Function(Note?) onOpenEditor;
  final Function(String, String, String?) onCreateNote;
  final Function(Note, String, String) onEditNote;
  final Function(Note) onDeleteNote;

  const FolderNotesScreen({
    super.key,
    required this.folderName,
    required this.allNotes,
    required this.onOpenEditor,
    required this.onCreateNote,
    required this.onEditNote,
    required this.onDeleteNote,
  });

  @override
  State<FolderNotesScreen> createState() => _FolderNotesScreenState();
}

class _FolderNotesScreenState extends State<FolderNotesScreen> {
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
  Future<void> _handleEdit(Note? note) async {
    final result = await widget.onOpenEditor(note);
    if (result == null) return;
    if (result['action'] == 'delete') {
      widget.onDeleteNote(result['note']);
      return;
    }
    if (result['action'] == 'save') {
      final title = result['title'];
      final content = result['content'];
      if (note == null) {
        widget.onCreateNote(title, content, widget.folderName);
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
    // Lọc 2 lần: 1 lần cho thư mục, 1 lần cho tìm kiếm
    final folderNotes = widget.allNotes
        .where((note) => note.folderName == widget.folderName)
        .toList();

    final displayedNotes = folderNotes.where((note) {
      final titleMatch =
          note.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final contentMatch =
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      return titleMatch || contentMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folderName ?? "Không có tiêu đề", // Tên thư mục
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                            ? 'Chưa có ghi chú nào trong thư mục này.'
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
                            _handleEdit(note); // Sửa
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
          _handleEdit(null); // Tạo mới
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Tạo ghi chú mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}