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
  final Function(String) onDeleteFolder;
  final Function(String, String) onRenameFolder;

  const FolderScreen({
    super.key,
    required this.onNavigateToAllNotes,
    required this.onNavigateToDeleted,
    required this.allNotes,
    required this.folderNames,
    required this.onCreateFolder,
    required this.onNavigateToFolder,
    required this.onDeleteFolder,
    required this.onRenameFolder,
  });

  // HÀM HIỂN THỊ BottomSheet (Tạo thư mục)
  void _showCreateFolderSheet(BuildContext context) {
    _showFolderDialog(context);
  }

  // HÀM HIỂN THỊ BottomSheet (Sửa tên)
  void _showRenameFolderSheet(BuildContext context, String oldName) {
    _showFolderDialog(context, oldName: oldName);
  }

  // HÀM HIỂN THỊ HỘP THOẠI XÓA THƯ MỤC
  void _showDeleteFolderDialog(BuildContext context, String folderName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Xóa thư mục?', style: TextStyle(color: Colors.white)),
          content: const Text(
              'Tất cả ghi chú trong thư mục này sẽ được chuyển về "Tất cả ghi chú".',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                onDeleteFolder(folderName);
                Navigator.of(context).pop();
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // HÀM CHUNG ĐỂ TẠO/SỬA TÊN THƯ MỤC
  void _showFolderDialog(BuildContext context, {String? oldName}) {
    final bool isRenaming = oldName != null;
    final TextEditingController controller = TextEditingController(text: oldName);
    controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length); // Chọn tất cả text

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
                Text(
                  isRenaming ? "Đổi tên thư mục" : "Thư mục mới",
                  style: const TextStyle(
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
                    hintText: "Tên thư mục",
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
                        if (isRenaming) {
                          onRenameFolder(oldName, newName);
                        } else {
                          onCreateFolder(newName);
                        }
                        Navigator.of(context).pop();
                      }
                    },
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
                // Không truyền hàm Sửa/Xóa -> tự động hiện mũi tên
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
                      onNavigateToFolder(folderName);
                    },
                    borderRadius: BorderRadius.circular(16.0),
                    child: FolderCard(
                      title: folderName,
                      noteCount: folderNotes.length,
                      // (MỚI) Truyền hàm Sửa
                      onRenamePressed: () {
                        _showRenameFolderSheet(context, folderName);
                      },
                      // (SỬA) Truyền hàm Xóa
                      onDeletePressed: () {
                        _showDeleteFolderDialog(context, folderName);
                      },
    
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
// (SỬA) WIDGET CHO CARD THƯ MỤC
// ==================================================
class FolderCard extends StatelessWidget {
  final String title;
  final int noteCount;
  final VoidCallback? onDeletePressed; // Nút xóa
  final VoidCallback? onRenamePressed; // (MỚI) Nút sửa

  const FolderCard({
    super.key,
    required this.title,
    required this.noteCount,
    this.onDeletePressed,
    this.onRenamePressed, // (MỚI)
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
          // Tên thư mục và số lượng
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

          // (SỬA) Hiển thị các icon
          if (onRenamePressed != null && onDeletePressed != null)
            // Nếu là thư mục tùy chỉnh -> Hiển thị 2 nút
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.grey[600], size: 22), // Icon cây bút
                  onPressed: onRenamePressed,
                  splashRadius: 24,
                  tooltip: 'Đổi tên thư mục',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                  onPressed: onDeletePressed,
                  splashRadius: 24,
                  tooltip: 'Xóa thư mục',
                ),
              ],
            )
          else
            // Nếu là "Không có tiêu đề" -> Hiển thị mũi tên
            Icon(Icons.chevron_right, color: Colors.grey[600]),
        ],
      ),
    );
  }
}