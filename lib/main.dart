import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note/screen.dart/MyApp.dart';
import 'models/note.dart';


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