import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';
import 'package:seungyo/widgets/app_title_bar.dart';

class NicknameInputView extends StatefulWidget {
  final VoidCallback onNext;

  const NicknameInputView({super.key, required this.onNext});

  @override
  State<NicknameInputView> createState() => _NicknameInputViewState();
}

class _NicknameInputViewState extends State<NicknameInputView> {
  final TextEditingController _controller = TextEditingController();
  String? errorText;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AuthViewModel>();
    final team = vm.team ?? '';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppTitleBar(
        left: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
        center: const Text(
          '정보입력',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 100),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 엠블럼 생략
                    const SizedBox(height: 15),
                    Text(
                      '$team 승요의\n닉네임을 입력해주세요.',
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
            Positioned(
              bottom: 28,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed:
                    _controller.text.trim().isNotEmpty
                        ? () async {
                          await vm.enterNickname(_controller.text.trim());
                          widget.onNext();
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('등록 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
