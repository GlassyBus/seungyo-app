import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';

class NicknameInputView extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const NicknameInputView({super.key, required this.onNext, required this.onBack});

  @override
  State<NicknameInputView> createState() => _NicknameInputViewState();
}

class _NicknameInputViewState extends State<NicknameInputView> {
  final TextEditingController _controller = TextEditingController();
  String? errorText;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final team = vm.team ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          FocusScope.of(context).unfocus();
          widget.onBack();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('정보입력'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              widget.onBack();
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                Text(
                  team.isNotEmpty ? '$team 승요의\n닉네임을 입력해주세요.' : '닉네임을 입력해주세요.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '닉네임 입력',
                    border: const OutlineInputBorder(),
                    errorText: errorText,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          child: ElevatedButton(
            onPressed:
                _controller.text.trim().isNotEmpty
                    ? () async {
                      FocusScope.of(context).unfocus();
                      vm.setNickname(_controller.text.trim());
                      await vm.saveUserInfo();
                      widget.onNext();
                    }
                    : null,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('등록 완료'),
          ),
        ),
      ),
    );
  }
}
