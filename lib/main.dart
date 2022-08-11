import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/auth/screens/auth_screen.dart';
import 'package:surf_practice_chat_flutter/features/storage/repository/local_rep.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorage = await SharedPreferences.getInstance();
  runApp(
    MyApp(
      localStorage: localStorage,
    ),
  );
}

/// App,s main widget.
class MyApp extends StatelessWidget {
  /// Constructor for [MyApp].
  const MyApp({
    required this.localStorage,
    Key? key,
  }) : super(key: key);

  final SharedPreferences localStorage;

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: LocalRepository(
        localStorage,
      ),
      child: MaterialApp(
        home: AuthScreen(
          authRepository: AuthRepository(StudyJamClient()),
        ),
      ),
    );
  }
}
