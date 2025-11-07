import 'package:flutter/material.dart';
import '../models/note.dart';

// Màn hình Thư mục (Stateless)
class FolderScreen extends StatelessWidget {
  final VoidCallback onNavigateToAllNotes;
  final VoidCallback onNavigateToDeleted;
  final List<Note> allNotes;
  final List<String> folderNames;
  final Function(String) onCreateFolder;
  final Function(String?) onNavigateToFolder;

  const FolderScreen({
    super.key,
    required this.onNavigateToAllNotes,
    required this.onNavigateToDeleted,
    required this.allNotes,
    required this.folderNames,
    required this.onCreateFolder,
    required this.onNavigateToFolder,
  });

  // HÀM HIỂN THỊ BottomSheet
  void _showCreateFolderSheet(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Thư mục mới",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Thư mục chưa đặt tên",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      final newName = controller.text.trim();
                      if (newName.isNotEmpty) {
                        onCreateFolder(newName);
                        Navigator.of(context).pop();
                      }
                    },
                    // Style nút này lấy từ Theme trong main.dart
                    child: const Text("Đã hoàn thành"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lọc ra các ghi chú "Không có tiêu đề" (folderName = null)
    final uncategorizedNotes =
        allNotes.where((note) => note.folderName == null).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: InkWell(
          onTap: onNavigateToAllNotes,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Thư mục',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_up),
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Box 1: Các mục tĩnh
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.notes_rounded, color: Colors.white70),
                    title: const Text('Tất cả ghi chú',
                        style: TextStyle(color: Colors.white)),
                    onTap: onNavigateToAllNotes,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white70),
                    title: const Text('Đã xóa gần đây',
                        style: TextStyle(color: Colors.white)),
                    onTap: onNavigateToDeleted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Box 2: Thư mục "Không có tiêu đề"
            InkWell(
              onTap: () {
                onNavigateToFolder(null); // Điều hướng đến thư mục 'null'
              },
              borderRadius: BorderRadius.circular(16.0),
              child: FolderCard(
                title: "Không có tiêu đề",
                noteCount: uncategorizedNotes.length,
              ),
            ),

            // Box 3: Danh sách các thư mục tùy chỉnh
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: folderNames.length,
                itemBuilder: (context, index) {
                  final folderName = folderNames[index];
                  final folderNotes = allNotes
                      .where((note) => note.folderName == folderName)
                      .toList();

                  return InkWell(
                    onTap: () {
                      onNavigateToFolder(folderName); // Điều hướng đến thư mục có tên
                    },
                    borderRadius: BorderRadius.circular(16.0),
                    child: FolderCard(
                      title: folderName,
                      noteCount: folderNotes.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                _showCreateFolderSheet(context);
              },
              style: ElevatedButton.styleFrom(
                // Padding để sửa lỗi căn chỉnh chữ
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 46.0),
              ),
              child: const Text('Thư mục mới'),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================
// WIDGET CHO CARD THƯ MỤC (Tái sử dụng)
// ==================================================
class FolderCard extends StatelessWidget {
  final String title;
  final int noteCount;

  const FolderCard({
    super.key,
    required this.title,
    required this.noteCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                noteCount.toString(),
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            ],
          ),
          Icon(Icons.chevron_right, color: Colors.grey[600]),
        ],
      ),
    );
  }
}