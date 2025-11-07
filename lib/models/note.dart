import 'package:hive/hive.dart';

// THÊM: Dòng này sẽ báo lỗi, đừng lo, chúng ta sẽ sửa ở Bước 3
part 'note.g.dart';

// THÊM: Báo cho Hive đây là 1 đối tượng có thể lưu
@HiveType(typeId: 0)
class Note extends HiveObject { // SỬA: extends HiveObject
  
  // THÊM: Gắn ID cho từng trường
  @HiveField(0)
  String title;
  
  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String? folderName;

  Note({
    required this.title,
    required this.content,
    required this.timestamp,
    this.folderName,
  });
}