import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/auth_vm.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('로그인 화면'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authVM.login();
                Navigator.pushReplacementNamed(context, '/main');
              },
              child: Text('로그인'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
