import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widget/save_editor.dart'; // Import NoteCard

class RecentlyDeletedScreen extends StatefulWidget {
  final List<Note> deletedNotes;
  final Function(Note) onRestore;
  final Function(Note) onDeletePermanent;

  const RecentlyDeletedScreen({
    super.key,
    required this.deletedNotes,
    required this.onRestore,
    required this.onDeletePermanent,
  });

  @override
  State<RecentlyDeletedScreen> createState() => _RecentlyDeletedScreenState();
}

class _RecentlyDeletedScreenState extends State<RecentlyDeletedScreen> {
  late List<Note> _localDeletedNotes;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _localDeletedNotes = List.from(widget.deletedNotes);

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

  Future<void> _showRestoreDialog(Note note) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title:
              const Text('Tùy chọn', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Bạn muốn khôi phục hay xóa vĩnh viễn ghi chú này?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Xóa vĩnh viễn',
                  style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onDeletePermanent(note);
                setState(() {
                  _localDeletedNotes.remove(note);
                });
              },
            ),
            TextButton(
              child: const Text('Khôi phục',
                  style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onRestore(note);
                setState(() {
                  _localDeletedNotes.remove(note);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách đã xóa
    final displayedNotes = _localDeletedNotes.where((note) {
      final titleMatch =
          note.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final contentMatch =
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      return titleMatch || contentMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Text(
              'Đã xóa gần đây',
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
            Expanded(
              child: displayedNotes.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Không có ghi chú nào đã xóa.'
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
                            _showRestoreDialog(note);
                          },
                          // Không có onDeletePressed -> Nút xóa tự ẩn
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}