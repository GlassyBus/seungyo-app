import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seungyo/theme/app_colors.dart';
import 'home_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    const HomeTab(),
    const Center(child: Text('기록 탭 준비 중...')),
    const Center(child: Text('일정 탭 준비 중...')),
  ];

  final List<String> _svgIcons = [
    'assets/icons/home-25px.svg',
    'assets/icons/ball-25px.svg',
    'assets/icons/calender-25px.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 44,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        height: 44,
        width: screenWidth,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: AppColors.gray10, width: 1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: List.generate(_svgIcons.length, (index) {
            return Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                child: Center(child: _buildIcon(_svgIcons[index], index)),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildIcon(String assetPath, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = _currentIndex == index;
    final color = isSelected ? colorScheme.primary : AppColors.gray60;

    return SvgPicture.asset(
      assetPath,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      height: 25,
      width: 25,
    );
  }
}
