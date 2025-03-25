import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/model/team_data.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';
import 'package:seungyo/widgets/app_title_bar.dart';

class SelectTeamView extends StatelessWidget {
  final VoidCallback onNext;

  const SelectTeamView({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return WillPopScope(
      onWillPop: () async {
        return await vm.handleDoubleBackPress(context);
      },
      child: Scaffold(
        appBar: const AppTitleBar(
          center: Text('정보입력', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 25, 16, 100),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '어느 구단을 응원하시나요?',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 25),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            TeamData.teams.map((team) {
                              final isSelected = vm.team == team['name'];
                              return ChoiceChip(
                                label: Text(team['name']!),
                                selected: isSelected,
                                onSelected: (_) => vm.selectTeam(team['name']!),
                              );
                            }).toList(),
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
                  onPressed: vm.team == null ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('다음'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
