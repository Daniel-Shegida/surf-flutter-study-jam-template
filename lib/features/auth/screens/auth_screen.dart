import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_practice_chat_flutter/features/auth/exceptions/auth_exception.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/storage/repository/local_rep.dart';
import 'package:surf_practice_chat_flutter/features/utils/dialog_controller.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Screen for authorization process.
///
/// Contains [IAuthRepository] to do so.
class AuthScreen extends StatefulWidget {
  /// Repository for auth implementation.
  final IAuthRepository authRepository;

  /// Constructor for [AuthScreen].
  const AuthScreen({
    required this.authRepository,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final TextEditingController _loginController;
  late final TextEditingController _passwordController;
  final DialogController dialogController = const DialogController();

  late final LocalRepository _localRep;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
    _localRep = context.read<LocalRepository>();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _LoginInputField(
                controller: _loginController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _PasswordInputField(
                controller: _passwordController,
              ),
            ), // _ChatTextField(onSendPressed: _onSendPressed),utt
            _LoginButton(
              onPressed: () {
                _loginToSurf(
                  _loginController.text,
                  _passwordController.text,
                  context,
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void _loginToSurf(
    String login,
    String password,
    BuildContext context,
  ) async {
    try {
      final TokenDto token = await widget.authRepository.signIn(
        login: login,
        password: password,
      );
      _localRep.saveToken(token: token);

      // ignore: use_build_context_synchronously
      _pushToChat(context, token);
    } on AuthException catch (e) {
      dialogController.showSnackBar(
        context,
        e.message,
      );
    }
    on Exception catch (_) {
      dialogController.showSnackBar(
        context,
        'wow unknown error'
      );
    }
  }

  void _pushToChat(BuildContext context, TokenDto token) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChatScreen(
            chatRepository: ChatRepository(
              StudyJamClient().getAuthorizedClient(token.token),
            ),
          );
        },
      ),
    );
  }
}

class _LoginInputField extends StatelessWidget {
  const _LoginInputField({required this.controller, Key? key})
      : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person),
        labelText: 'Пароль',
        border: OutlineInputBorder(borderSide: BorderSide()),
      ),
    );
  }
}

class _PasswordInputField extends StatelessWidget {
  const _PasswordInputField({required this.controller, Key? key})
      : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: 'Пароль',
        border: OutlineInputBorder(borderSide: BorderSide()),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onPressed, Key? key}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        color: Theme.of(context).colorScheme.secondary,
        onPressed: onPressed,
        child: const Text("Далее"));
  }
}
