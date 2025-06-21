import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 앱 하단 탐색 바 위젯
///
/// 홈, 기록, 일정 탭 간 이동을 위한 하단 탐색 바를 제공합니다.
class FooterComponent extends StatelessWidget {
  /// 현재 선택된 탭 인덱스
  final int currentIndex;

  /// 탭 선택 변경 콜백
  final Function(int)? onTabChanged;

  /// 탭 아이콘 경로 목록
  static const List<String> _tabIcons = [
    'assets/icons/home-25px.svg',
    'assets/icons/ball-25px.svg',
    'assets/icons/calender-25px.svg',
  ];

  /// 생성자
  const FooterComponent({Key? key, this.currentIndex = 0, this.onTabChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE6EAF2), width: 1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_buildTabBar(), _buildIndicator()],
      ),
    );
  }

  /// 탭 버튼 목록을 포함한 탭 바를 빌드합니다.
  Widget _buildTabBar() {
    return SizedBox(
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _tabIcons.length,
          (index) => _buildTabItem(
            _tabIcons[index],
            index: index,
            isSelected: currentIndex == index,
          ),
        ),
      ),
    );
  }

  /// 현재 선택된 탭을 나타내는 하단 인디케이터를 빌드합니다.
  Widget _buildIndicator() {
    return Container(
      width: 134,
      height: 5,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  /// 개별 탭 버튼을 빌드합니다.
  Widget _buildTabItem(
    String iconPath, {
    required int index,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: () {
        if (onTabChanged != null) {
          onTabChanged!(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            isSelected ? Colors.black : Colors.grey,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
