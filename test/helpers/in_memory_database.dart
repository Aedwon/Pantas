import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/native.dart';

AppDatabase inMemoryDatabase() => AppDatabase(NativeDatabase.memory());
