import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note/widget/note_editor.dart';
import 'models/note.dart';
import 'package:note/widget/all_note.dart';
import 'package:note/widget/recently_deleted_screen.dart';
import 'package:note/widget/folder_notes_screen.dart';
import 'package:note/widget/note_home_page.dart';

// ==================================================
// PHẦN 1: MAIN (KHỞI ĐỘNG HIVE)
// ==================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notes_box');
  await Hive.openBox<Note>('deleted_notes_box');
  await Hive.openBox<String>('folders_box');
  runApp(const MyApp());
}

// ==================================================
// PHẦN 2: MYAPP (BỘ NÃO CỦA ỨNG DỤNG)
// ==================================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // DỮ LIỆU CỦA ỨNG DỤNG
  late List<Note> _notes;
  late List<Note> _deletedNotes;
  late List<String> _folderNames;

  late Box<Note> notesBox;
  late Box<Note> deletedNotesBox;
  late Box<String> foldersBox;

  @override
  void initState() {
    super.initState();
    notesBox = Hive.box<Note>('notes_box');
    deletedNotesBox = Hive.box<Note>('deleted_notes_box');
    foldersBox = Hive.box<String>('folders_box');

    _notes = notesBox.values.toList();
    _deletedNotes = deletedNotesBox.values.toList();
    _folderNames = foldersBox.values.toList();
  }

  // --- HÀM 1: MỞ TRÌNH SOẠN THẢO ---
  Future<Map?> _openNoteEditor(BuildContext context, {Note? note}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );
    if (result != null && result is Map) {
      final String title = (result['title'] as String).trim();
      final String content = (result['content'] as String).trim();
      if (title.isEmpty && content.isEmpty) {
        if (note != null) {
          return {'action': 'delete', 'note': note};
        }
        return null;
      }
      return {'action': 'save', 'title': title, 'content': content};
    }
    return null;
  }

  // ==================================================
  // (SỬA LỖI) CÁC HÀM XÓA/KHÔI PHỤC GHI CHÚ
  // ==================================================

  // --- SỬA HÀM 2: XÓA GHI CHÚ ---
  void _deleteNote(Note note) {
    // 1. Tạo một bản sao (copy) của ghi chú
    final deletedNote = Note(
      title: note.title,
      content: note.content,
      timestamp: note.timestamp,
      folderName: note.folderName,
    );

    setState(() {
      _notes.remove(note); // 2. Xóa khỏi danh sách _notes
      _deletedNotes.insert(0, deletedNote); // 3. Thêm bản sao vào _deletedNotes

      // 4. Cập nhật Hive
      deletedNotesBox.add(deletedNote); // 5. Thêm BẢN SAO vào deletedNotesBox
      note.delete(); // 6. Xóa BẢN GỐC khỏi notesBox
    });
  }

  // --- SỬA HÀM 3: KHÔI PHỤC GHI CHÚ ---
  void _restoreNote(Note note) {
    // 1. Tạo một bản sao (copy)
    final restoredNote = Note(
      title: note.title,
      content: note.content,
      timestamp: note.timestamp,
      folderName: note.folderName,
    );

    setState(() {
      _deletedNotes.remove(note); // 2. Xóa khỏi danh sách _deletedNotes
      _notes.insert(0, restoredNote); // 3. Thêm bản sao vào _notes

      // 4. Cập nhật Hive
      notesBox.add(restoredNote); // 5. Thêm BẢN SAO vào notesBox
      note.delete(); // 6. Xóa BẢN GỐC khỏi deletedNotesBox
    });
  }

  // --- HÀM 4: XÓA VĨNH VIỄN ---
  void _deleteNotePermanently(Note note) {
    setState(() {
      _deletedNotes.remove(note);
      note.delete(); // Xóa khỏi 'deletedNotesBox'
    });
  }

  // ==================================================
  // (MỚI) CÁC HÀM QUẢN LÝ THƯ MỤC
  // ==================================================

  // --- HÀM 5: TẠO THƯ MỤC ---
  void _createFolder(String name) {
    if (name.isNotEmpty && !_folderNames.contains(name)) {
      setState(() {
        _folderNames.add(name);
        foldersBox.add(name);
      });
    }
  }

  // --- (MỚI) HÀM 6: XÓA THƯ MỤC ---
  void _deleteFolder(String folderName) {
    setState(() {
      // 1. Tìm tất cả ghi chú thuộc thư mục này
      final notesInFolder = _notes.where((note) => note.folderName == folderName);

      // 2. Chuyển chúng về "Không có tiêu đề"
      for (final note in notesInFolder) {
        note.folderName = null;
        note.save(); // Lưu thay đổi
      }

      // 3. Xóa tên thư mục khỏi danh sách
      _folderNames.remove(folderName);
      
      // 4. Xóa tên thư mục khỏi Hive
      // (Vì Hive box không thể xóa bằng giá trị, ta phải tìm key)
      final keyMap = foldersBox.toMap();
      for (final key in keyMap.keys) {
        if (keyMap[key] == folderName) {
          foldersBox.delete(key);
          break;
        }
      }
    });
  }

  // --- (MỚI) HÀM 7: ĐỔI TÊN THƯ MỤC ---
  void _renameFolder(String oldName, String newName) {
    if (newName.isEmpty || newName == oldName || _folderNames.contains(newName)) {
      return; // Bỏ qua nếu tên mới không hợp lệ
    }
    
    setState(() {
      // 1. Cập nhật tất cả ghi chú
      final notesInFolder = _notes.where((note) => note.folderName == oldName);
      for (final note in notesInFolder) {
        note.folderName = newName;
        note.save();
      }

      // 2. Cập nhật danh sách _folderNames
      final index = _folderNames.indexOf(oldName);
      if (index != -1) {
        _folderNames[index] = newName;
      }
      
      // 3. Cập nhật Hive foldersBox
      final keyMap = foldersBox.toMap();
      for (final key in keyMap.keys) {
        if (keyMap[key] == oldName) {
          foldersBox.put(key, newName); // Ghi đè tên mới
          break;
        }
      }
    });
  }


  // ==================================================
  // CÁC HÀM ĐIỀU HƯỚNG
  // ==================================================

  // --- SỬA HÀM 8a: Mở màn hình Thư mục (all_note.dart) ---
  void _navigateToFolderScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => FolderScreen(
          allNotes: _notes,
          folderNames: _folderNames,
          onCreateFolder: _createFolder,
          // (MỚI) Truyền các hàm mới
          onDeleteFolder: _deleteFolder,
          onRenameFolder: _renameFolder,
          //
          onNavigateToAllNotes: () {
            Navigator.of(ctx).pop();
          },
          onNavigateToDeleted: () {
            Navigator.of(ctx).pop();
            _navigateToRecentlyDeletedScreen(ctx);
          },
          onNavigateToFolder: (String? folderName) {
            Navigator.of(ctx).pop();
            _navigateToFolderNotesScreen(ctx, folderName);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  // --- HÀM 8b: Mở màn hình Đã xóa ---
  void _navigateToRecentlyDeletedScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => RecentlyDeletedScreen(
          deletedNotes: _deletedNotes,
          onRestore: _restoreNote,
          onDeletePermanent: _deleteNotePermanently,
        ),
      ),
    );
  }

  // --- HÀM 8c: Mở màn hình Ghi chú trong Thư mục ---
  void _navigateToFolderNotesScreen(BuildContext context, String? folderName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => FolderNotesScreen(
          folderName: folderName,
          allNotes: _notes,
          onDeleteNote: _deleteNote,
          onOpenEditor: (Note? note) => _openNoteEditor(ctx, note: note),
          onCreateNote: (String title, String content, String? folder) {
            final newNote = Note(
              title: title,
              content: content,
              timestamp: DateTime.now(),
              folderName: folder,
            );
            setState(() {
              _notes.insert(0, newNote);
              notesBox.add(newNote); // Thêm vào Hive
            });
          },
          onEditNote: (Note note, String title, String content) {
            setState(() {
              note.title = title;
              note.content = content;
              note.timestamp = DateTime.now();
              note.save(); // Lưu thay đổi vào Hive
            });
          },
        ),
      ),
    );
  }

  // --- HÀM BUILD CỦA MYAPP ---
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Ghi Chú',
      theme: ThemeData.dark().copyWith(
        // ... (Theme giữ nguyên) ...
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ColorScheme.dark().copyWith(
          secondary: Colors.grey[800],
          onSecondary: Colors.white,
          primary: Colors.grey[900],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Builder(builder: (BuildContext context) {
        return NoteHomePage(
          notes: _notes,
          onNavigateToFolders: () => _navigateToFolderScreen(context),
          onOpenEditor: (Note? note) => _openNoteEditor(context, note: note),
          onCreateNote: (String title, String content) {
            final newNote = Note(
              title: title,
              content: content,
              timestamp: DateTime.now(),
              folderName: null,
            );
            setState(() {
              _notes.insert(0, newNote);
              notesBox.add(newNote); // Thêm vào Hive
            });
          },
          onEditNote: (Note note, String title, String content) {
            setState(() {
              note.title = title;
              note.content = content;
              note.timestamp = DateTime.now();
              note.save(); // Lưu thay đổi vào Hive
            });
          },
          onDeleteNote: _deleteNote,
        );
      }),
    );
  }
}