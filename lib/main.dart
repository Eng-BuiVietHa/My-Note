import 'package:flutter/material.dart';
// THÊM: Các thư viện Hive
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:note/widget/note_editor.dart';
import 'models/note.dart';
import 'package:note/widget/all_note.dart';
import 'package:note/widget/recently_deleted_screen.dart';
import 'package:note/widget/folder_notes_screen.dart';
import 'package:note/widget/note_home_page.dart';

// ==================================================
// PHẦN 1: MAIN (KHỞI ĐỘNG HIVE)
// ==================================================
void main() async { // SỬA: Thêm async
  // Đảm bảo Flutter sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi động Hive
  await Hive.initFlutter();
  
  // Đăng ký Model Note
  Hive.registerAdapter(NoteAdapter());

  // Mở các "hộp" (boxes) để lưu trữ
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
  // SỬA: Chúng ta sẽ đọc dữ liệu từ Hive khi khởi động
  late List<Note> _notes;
  late List<Note> _deletedNotes;
  late List<String> _folderNames;

  // SỬA: Thêm các biến Box
  late Box<Note> notesBox;
  late Box<Note> deletedNotesBox;
  late Box<String> foldersBox;

  // (MỚI) Thêm initState để tải dữ liệu
  @override
  void initState() {
    super.initState();
    // Gán các box
    notesBox = Hive.box<Note>('notes_box');
    deletedNotesBox = Hive.box<Note>('deleted_notes_box');
    foldersBox = Hive.box<String>('folders_box');

    // Tải dữ liệu từ box vào danh sách
    _notes = notesBox.values.toList();
    _deletedNotes = deletedNotesBox.values.toList();
    _folderNames = foldersBox.values.toList();
  }

  // --- HÀM 1: MỞ TRÌNH SOẠN THẢO ---
  // (Hàm này không đổi)
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

  // --- HÀM 2: XÓA GHI CHÚ ---
  void _deleteNote(Note note) {
    setState(() {
      _notes.remove(note);
      _deletedNotes.insert(0, note);

      // SỬA: Cập nhật Hive
      deletedNotesBox.add(note);
      note.delete(); // Xóa khỏi 'notesBox' (vì nó là HiveObject)
    });
  }

  // --- HÀM 3: KHÔI PHỤC GHI CHÚ ---
  void _restoreNote(Note note) {
    setState(() {
      _deletedNotes.remove(note);
      _notes.insert(0, note);

      // SỬA: Cập nhật Hive
      notesBox.add(note);
      note.delete(); // Xóa khỏi 'deletedNotesBox'
    });
  }

  // --- HÀM 4: XÓA VĨNH VIỄN ---
  void _deleteNotePermanently(Note note) {
    setState(() {
      _deletedNotes.remove(note);

      // SỬA: Cập nhật Hive
      note.delete(); // Xóa khỏi 'deletedNotesBox'
    });
  }

  // --- HÀM 5: TẠO THƯ MỤC ---
  void _createFolder(String name) {
    if (name.isNotEmpty && !_folderNames.contains(name)) {
      setState(() {
        _folderNames.add(name);

        // SỬA: Cập nhật Hive
        foldersBox.add(name);
      });
    }
  }

  // --- CÁC HÀM ĐIỀU HƯỚNG ---
  // (Toàn bộ các hàm _navigateTo... giữ nguyên y hệt)
  void _navigateToFolderScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => FolderScreen(
          allNotes: _notes,
          folderNames: _folderNames,
          onCreateFolder: _createFolder,
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

  void _navigateToFolderNotesScreen(BuildContext context, String? folderName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => FolderNotesScreen(
          folderName: folderName,
          allNotes: _notes,
          onDeleteNote: _deleteNote,
          onOpenEditor: (Note? note) => _openNoteEditor(ctx, note: note),
          onCreateNote: (String title, String content, String? folder) {
            // SỬA: Logic tạo mới
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
            // SỬA: Logic chỉnh sửa
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
            // SỬA: Logic tạo mới (màn hình chính)
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
            // SỬA: Logic chỉnh sửa
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