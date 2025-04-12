import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/constants/team_data.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';

class SelectTeamView extends StatelessWidget {
  final VoidCallback onNext;

  const SelectTeamView({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('정보입력'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 25, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('어느 구단을 응원하시나요?', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 25),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          TeamData.teams.map((team) {
                            final isSelected = vm.team == team.name;
                            return ChoiceChip(
                              label: Text(team.name),
                              selected: isSelected,
                              onSelected: (_) {
                                vm.selectTeam(isSelected ? null : team.name);
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          child: ElevatedButton(
            onPressed: vm.team == null ? null : onNext,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('다음'),
          ),
        ),
      ),
    );
  }
}
