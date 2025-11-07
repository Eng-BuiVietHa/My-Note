import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart'; // Import class Note

// WIDGET CHO MỖI CARD GHI CHÚ
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onDeletePressed; // Callback khi bấm nút XÓA

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bọc Column cũ bằng Expanded
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  if (note.title.isNotEmpty)
                    Text(
                      note.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Nội dung
                  if (note.content.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: note.title.isNotEmpty ? 8.0 : 0),
                      child: Text(
                        note.content,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Nếu không có tiêu đề, chỉ hiển thị nội dung
                  if (note.title.isEmpty && note.content.isNotEmpty)
                    Text(
                      note.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  // Chỉ hiển thị ngày giờ nếu có 1 trong 2
                  if (note.title.isNotEmpty || note.content.isNotEmpty)
                    const SizedBox(height: 16),
                    
                  Text(
                    DateFormat('HH:mm dd/MM/yyyy').format(note.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Chỉ hiển thị IconButton NẾU onDeletePressed không phải là null
            if (onDeletePressed != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.grey[600],
                ),
                onPressed: onDeletePressed,
                splashRadius: 24,
              ),
          ],
        ),
      ),
    );
  }
}