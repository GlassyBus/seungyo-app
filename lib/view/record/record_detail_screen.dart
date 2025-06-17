import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seungyo/theme/theme.dart';

import '../../models/game_record.dart';
import '../../services/record_service.dart';
import 'create_record_screen.dart';
import 'widgets/action_modal.dart';

class RecordDetailPage extends StatefulWidget {
  final GameRecord game;

  const RecordDetailPage({Key? key, required this.game}) : super(key: key);

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late final bool isGameMinimum;
  late bool isFavorite;
  bool _hasChanges = false; // 변경사항 추적

  @override
  void initState() {
    super.initState();
    isGameMinimum = widget.game.canceled;
    isFavorite = widget.game.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () async {
        // 변경사항이 있으면 true를 반환하여 이전 화면에 알림
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(),
        body: _buildBody(colorScheme, textTheme),
        bottomNavigationBar: _buildBottomNavigationBar(colorScheme),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('직관 기록 상세'),
      actions: [
        IconButton(icon: const Icon(Icons.edit), onPressed: _handleEdit),
        IconButton(icon: const Icon(Icons.download), onPressed: _handleDownload),
        IconButton(icon: const Icon(Icons.more_horiz), onPressed: _showActionModal),
      ],
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainImage(),
          _buildGameInfo(textTheme),
          const SizedBox(height: 32),
          _buildGameResultSection(colorScheme, textTheme),
          const SizedBox(height: 32),
          _buildCommentSection(colorScheme, textTheme),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
    return Container(
      width: double.infinity,
      height: 300,
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            widget.game.photos.isNotEmpty
                ? Stack(
                  children: [
                    PageView.builder(
                      itemCount: widget.game.photos.length,
                      itemBuilder: (context, index) {
                        return Image.file(
                          File(widget.game.photos[index]),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: AppColors.gray20,
                                child: const Center(child: Icon(Icons.image, size: 80, color: AppColors.gray50)),
                              ),
                        );
                      },
                    ),
                    if (widget.game.photos.length > 1)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.game.photos.length}장',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                )
                : Container(
                  color: AppColors.gray20,
                  child: const Center(child: Icon(Icons.image, size: 80, color: AppColors.gray50)),
                ),
      ),
    );
  }

  Widget _buildGameInfo(TextTheme textTheme) {
    final dateFormat = DateFormat('yyyy.MM.dd(E) HH:mm', 'ko_KR');
    final formattedDate = dateFormat.format(widget.game.dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildInfoRow('일정', formattedDate, textTheme),
          const SizedBox(height: 16),
          _buildInfoRow('위치', widget.game.stadium.name, textTheme),
          const SizedBox(height: 16),
          _buildInfoRow('좌석', widget.game.seatInfo ?? '', textTheme),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 60, child: Text(label, style: textTheme.bodyMedium?.copyWith(color: AppColors.gray70))),
        const SizedBox(width: 20),
        Expanded(child: Text(value, style: textTheme.bodyLarge)),
      ],
    );
  }

  Widget _buildGameResultSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('경기 정보', style: textTheme.titleLarge?.copyWith(color: AppColors.gray70)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.navy5, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildTeamLabels(textTheme),
                const SizedBox(height: 16),
                _buildScoreDisplay(textTheme),
                const SizedBox(height: 20),
                _buildGameMinimumCheckbox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLabels(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('홈팀', style: textTheme.bodySmall?.copyWith(color: AppColors.gray70)),
        Text('상대팀', style: textTheme.bodySmall?.copyWith(color: AppColors.gray70)),
      ],
    );
  }

  Widget _buildScoreDisplay(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTeamInfo(
          widget.game.homeTeam.name,
          widget.game.homeTeam.primaryColor,
          widget.game.homeTeam.logo ?? '',
          textTheme,
        ),
        Text('${widget.game.homeScore}', style: textTheme.displayLarge),
        Text(':', style: textTheme.displayLarge?.copyWith(color: AppColors.gray50)),
        Text('${widget.game.awayScore}', style: textTheme.displayLarge),
        _buildTeamInfo(
          widget.game.awayTeam.name,
          widget.game.awayTeam.primaryColor,
          widget.game.awayTeam.logo ?? '',
          textTheme,
        ),
      ],
    );
  }

  Widget _buildTeamInfo(String teamName, Color color, String logoPath, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gray30, width: 1),
          ),
          child: Center(
            child:
                logoPath.isNotEmpty && logoPath.startsWith('assets/')
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        logoPath,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) => Text(
                              _getTeamShortText(teamName),
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.navy,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                      ),
                    )
                    : Text(
                      _getTeamShortText(teamName),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
          ),
        ),
        const SizedBox(width: 8),
        Text(teamName, style: textTheme.titleMedium),
      ],
    );
  }

  /// 팀명을 간단한 텍스트 로고로 변환
  String _getTeamShortText(String teamName) {
    if (teamName.contains('KIA') || teamName.contains('타이거즈')) return 'KIA';
    if (teamName.contains('KT') || teamName.contains('위즈')) return 'KT';
    if (teamName.contains('LG') || teamName.contains('트윈스')) return 'LG';
    if (teamName.contains('NC') || teamName.contains('다이노스')) return 'NC';
    if (teamName.contains('SSG') || teamName.contains('랜더스')) return 'SSG';
    if (teamName.contains('두산') || teamName.contains('베어스')) return '두산';
    if (teamName.contains('롯데') || teamName.contains('자이언츠')) return '롯데';
    if (teamName.contains('삼성') || teamName.contains('라이온즈')) return '삼성';
    if (teamName.contains('키움') || teamName.contains('히어로즈')) return '키움';
    if (teamName.contains('한화') || teamName.contains('이글스')) return '한화';
    return '⚾';
  }

  Widget _buildGameMinimumCheckbox() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isGameMinimum ? Theme.of(context).colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isGameMinimum ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
            child: isGameMinimum ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
          const SizedBox(width: 8),
          Text(
            '경기최소',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('코멘트', style: textTheme.titleLarge?.copyWith(color: AppColors.gray70)),
          const SizedBox(height: 16),
          Text(widget.game.memo, style: textTheme.bodyLarge),
          const SizedBox(height: 24),
          Center(child: Text('기억에 남는 경기였나요?', style: textTheme.bodyMedium?.copyWith(color: AppColors.gray70))),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: AnimatedScale(
                scale: isFavorite ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.favorite, color: isFavorite ? AppColors.negative : AppColors.gray30, size: 80),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.gray10, width: 1))),
      child: BottomNavigationBar(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.onSurface,
        unselectedItemColor: AppColors.gray50,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.sports_baseball_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: ''),
        ],
      ),
    );
  }

  void _handleDownload() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('다운로드 기능을 구현해주세요')));
  }

  void _showActionModal() {
    RecordActionModal.show(context, onEdit: _handleEdit, onDelete: _handleDelete);
  }

  void _handleEdit() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRecordScreen(gameRecord: widget.game))).then((
      result,
    ) {
      if (result == true) {
        // 수정 성공 시 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록이 수정되었습니다.'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
        );

        Navigator.pop(context, true); // 수정이 완료되면 true 반환
      }
    });
  }

  void _handleDelete() {
    _showDeleteConfirmDialog();
  }

  Future<void> _toggleFavorite() async {
    try {
      // UI 즉시 업데이트
      setState(() {
        isFavorite = !isFavorite;
      });

      // RecordService를 사용하여 DB 업데이트
      final recordService = RecordService();
      final success = await recordService.toggleFavorite(widget.game.id);

      if (!success) {
        // DB 업데이트 실패 시 UI 롤백
        setState(() {
          isFavorite = !isFavorite;
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('즐겨찾기 업데이트에 실패했습니다.'), backgroundColor: Colors.red));
        }
      } else {
        // 성공 시 - 뒤로 갈 때 리스트 새로고침을 위해 플래그 설정
        _hasChanges = true;

        // 성공 피드백
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFavorite ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 제거되었습니다.'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      // 에러 발생 시 UI 롤백
      setState(() {
        isFavorite = !isFavorite;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showDeleteConfirmDialog() {
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('기록 삭제', style: textTheme.titleLarge),
            content: Text('이 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.', style: textTheme.bodyMedium),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('취소', style: textTheme.bodyMedium)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  _performDelete(); // 실제 삭제 수행
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.negative),
                child: Text('삭제', style: textTheme.bodyMedium),
              ),
            ],
          ),
    );
  }

  Future<void> _performDelete() async {
    try {
      print('RecordDetailScreen: Starting delete process for record ID: ${widget.game.id}');

      // 로딩 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                SizedBox(width: 16),
                Text('기록을 삭제하는 중...'),
              ],
            ),
            duration: Duration(seconds: 30), // 충분한 시간
          ),
        );
      }

      // RecordService를 사용하여 DB에서 삭제
      final recordService = RecordService();
      final success = await recordService.deleteRecord(widget.game.id);

      // 로딩 스낵바 제거
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (success) {
        print('RecordDetailScreen: Record deleted successfully');

        if (mounted) {
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('기록이 삭제되었습니다.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // 상세 화면 닫고 리스트 새로고침을 위해 true 반환
          Navigator.pop(context, true);
        }
      } else {
        print('RecordDetailScreen: Failed to delete record');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('기록 삭제에 실패했습니다.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('RecordDetailScreen: Error during delete: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
