import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/auth_vm.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 구단 선택 UI는 추후 GridView 등으로 확장 가능
            Text('구단 선택 (예시)'),
            SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(labelText: '닉네임'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await authVM.signup(_nicknameController.text);
                // (3,2,3)초의 애니메이션 딜레이 예시 (총 8초)
                await Future.delayed(Duration(seconds: 8));
                Navigator.pushReplacementNamed(context, '/main');
              },
              child: Text('회원가입 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
