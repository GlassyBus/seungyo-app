import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seungyo/services/record_service.dart';
import 'dart:io';
import '../../models/game_record_form.dart';
import '../../models/game_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/team_data.dart';
import 'widgets/date_time_picker_modal.dart';
import 'widgets/score_input_modal.dart';
import 'widgets/stadium_picker_modal.dart';
import 'widgets/team_picker_modal.dart';

class CreateRecordScreen extends StatefulWidget {
  final GameRecord? gameRecord; // 수정할 기록 (null이면 새 기록)

  const CreateRecordScreen({Key? key, this.gameRecord}) : super(key: key);

  @override
  State<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends State<CreateRecordScreen> {
  final GameRecordForm _form = GameRecordForm();
  final TextEditingController _seatController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  File? _selectedImage;
  bool _isMemorableGame = false;
  bool _isGameMinimum = false;
  bool _isImageLoading = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _seatController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(colorScheme, textTheme),
      body: _buildBody(colorScheme, textTheme),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: colorScheme.onSurface),
        onPressed: _handleBackPress,
      ),
      title: Text('직관 기록 작성', style: textTheme.titleLarge),
      actions: [
        _isSaving
            ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            )
            : IconButton(
              icon: Icon(
                Icons.check,
                color: _canSave() ? colorScheme.primary : AppColors.gray30,
              ),
              onPressed: _canSave() ? _handleSave : null,
            ),
      ],
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(colorScheme),
            const SizedBox(height: 32),
            _buildInfoSection(colorScheme, textTheme),
            const SizedBox(height: 32),
            _buildGameInfoSection(colorScheme, textTheme),
            const SizedBox(height: 32),
            _buildCommentSection(colorScheme, textTheme),
            const SizedBox(height: 32),
            _buildMemorableGameSection(colorScheme, textTheme),
            // 키보드가 표시될 때 충분한 공간 확보
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.gray10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray20),
        ),
        child:
            _isImageLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        '이미지 로딩 중...',
                        style: TextStyle(color: AppColors.gray70, fontSize: 14),
                      ),
                    ],
                  ),
                )
                : _selectedImage != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: AppColors.gray50,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '사진 추가',
                      style: TextStyle(color: AppColors.gray50, fontSize: 16),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        _buildInfoRow(
          '일정',
          _form.gameDateTime != null
              ? _formatDateTime(_form.gameDateTime!)
              : '날짜를 선택해주세요.',
          () => _showDateTimePicker(),
          textTheme,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          '위치',
          _form.stadium ?? '경기장을 선택해주세요.',
          () => _showStadiumPicker(),
          textTheme,
        ),
        const SizedBox(height: 16),
        _buildSeatInput(textTheme),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    VoidCallback onTap,
    TextTheme textTheme,
  ) {
    final isPlaceholder = value.contains('선택해주세요') || value.contains('입력해주세요');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray20)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.gray70),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: isPlaceholder ? AppColors.gray50 : null,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.gray50),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatInput(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray20)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '좌석',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.gray70),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: _seatController,
              decoration: InputDecoration(
                hintText: '좌석을 입력해주세요.',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: AppColors.gray50,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: textTheme.bodyLarge,
              onChanged: (value) {
                setState(() {
                  _form.seatInfo = value.isEmpty ? null : value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '경기 정보',
          style: textTheme.titleLarge?.copyWith(color: AppColors.gray70),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.navy5,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildTeamLabels(textTheme),
              const SizedBox(height: 16),
              _buildTeamSelection(textTheme, colorScheme),
              const SizedBox(height: 20),
              _buildGameMinimumCheckbox(textTheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamLabels(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '응원팀',
          style: textTheme.bodySmall?.copyWith(color: AppColors.gray70),
        ),
        Text(
          '상대팀',
          style: textTheme.bodySmall?.copyWith(color: AppColors.gray70),
        ),
      ],
    );
  }

  Widget _buildTeamSelection(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTeamButton(
          '응원팀',
          _form.homeTeam,
          () => _showTeamPicker(true),
          textTheme,
        ),
        GestureDetector(
          onTap:
              _form.homeTeam != null && _form.awayTeam != null
                  ? _showScoreInput
                  : null,
          child: Row(
            children: [
              Text(
                _form.homeScore != null ? '${_form.homeScore}' : '-',
                style: textTheme.displayMedium?.copyWith(
                  color:
                      _form.homeScore != null
                          ? colorScheme.onSurface
                          : AppColors.gray50,
                ),
              ),
              Text(
                ':',
                style: textTheme.displayMedium?.copyWith(
                  color: AppColors.gray50,
                ),
              ),
              Text(
                _form.awayScore != null ? '${_form.awayScore}' : '-',
                style: textTheme.displayMedium?.copyWith(
                  color:
                      _form.awayScore != null
                          ? colorScheme.onSurface
                          : AppColors.gray50,
                ),
              ),
            ],
          ),
        ),
        _buildTeamButton(
          '상대팀',
          _form.awayTeam,
          () => _showTeamPicker(false),
          textTheme,
        ),
      ],
    );
  }

  Widget _buildTeamButton(
    String label,
    String? teamName,
    VoidCallback onTap,
    TextTheme textTheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          teamName ?? '팀 선택',
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGameMinimumCheckbox(TextTheme textTheme) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isGameMinimum = !_isGameMinimum;
            });
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _isGameMinimum ? AppColors.navy : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _isGameMinimum ? AppColors.navy : AppColors.gray30,
                width: 2,
              ),
            ),
            child:
                _isGameMinimum
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '경기최소',
          style: textTheme.bodySmall?.copyWith(color: AppColors.gray70),
        ),
      ],
    );
  }

  Widget _buildCommentSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '코멘트',
          style: textTheme.titleLarge?.copyWith(color: AppColors.gray70),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          focusNode: _commentFocusNode,
          decoration: InputDecoration(
            hintText: '코멘트를 남겨주세요.',
            hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.gray50),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: textTheme.bodyLarge,
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _form.comment = value.isEmpty ? null : value;
            });
          },
          onTap: () {
            // 텍스트 필드를 탭하면 화면을 스크롤하여 키보드 위에 표시
            Future.delayed(const Duration(milliseconds: 300), () {
              Scrollable.ensureVisible(
                _commentFocusNode.context!,
                alignment: 0.5,
                duration: const Duration(milliseconds: 300),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildMemorableGameSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Text(
          '기억에 남는 경기였나요?',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.gray70),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              _isMemorableGame = !_isMemorableGame;
            });
          },
          child: AnimatedScale(
            scale: _isMemorableGame ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.favorite,
              color: _isMemorableGame ? AppColors.negative : AppColors.gray30,
              size: 80,
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('카메라로 촬영'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('갤러리에서 선택'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isImageLoading = true;
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        // 이미지 처리 시간을 시뮬레이션 (실제 앱에서는 필요 없음)
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _selectedImage = File(pickedFile.path);
          _form.imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 로딩 중 오류가 발생했습니다: $e')));
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  void _showDateTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DateTimePickerModal(
            initialDateTime: _form.gameDateTime,
            onDateTimeSelected: (dateTime) {
              setState(() {
                _form.gameDateTime = dateTime;
              });
            },
          ),
    );
  }

  void _showStadiumPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => StadiumPickerModal(
            selectedStadium: _form.stadium,
            onStadiumSelected: (stadium) {
              setState(() {
                _form.stadium = stadium;
              });
            },
          ),
    );
  }

  void _showTeamPicker(bool isHomeTeam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => TeamPickerModal(
            title: isHomeTeam ? '응원팀 선택' : '상대팀 선택',
            selectedTeam: isHomeTeam ? _form.homeTeam : _form.awayTeam,
            onTeamSelected: (team) {
              setState(() {
                if (isHomeTeam) {
                  _form.homeTeam = team;
                } else {
                  _form.awayTeam = team;
                }
              });
            },
          ),
    );
  }

  void _showScoreInput() {
    if (_form.homeTeam == null || _form.awayTeam == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => ScoreInputModal(
            homeTeam: _form.homeTeam!,
            awayTeam: _form.awayTeam!,
            initialHomeScore: _form.homeScore,
            initialAwayScore: _form.awayScore,
            onScoreSelected: (homeScore, awayScore) {
              setState(() {
                _form.homeScore = homeScore;
                _form.awayScore = awayScore;
              });
            },
          ),
    );
  }

  bool _canSave() {
    return _form.gameDateTime != null &&
        _form.stadium != null &&
        _form.homeTeam != null &&
        _form.awayTeam != null;
  }

  Future<void> _handleSave() async {
    if (!_canSave()) return;

    try {
      setState(() {
        _isSaving = true;
      });

      final recordService = RecordService();
      await recordService.addRecord(_form);

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('직관 기록이 저장되었습니다')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _handleBackPress() {
    if (_hasUnsavedChanges()) {
      _showExitConfirmDialog();
    } else {
      Navigator.pop(context);
    }
  }

  bool _hasUnsavedChanges() {
    return _form.gameDateTime != null ||
        _form.stadium != null ||
        _form.homeTeam != null ||
        _form.awayTeam != null ||
        _seatController.text.isNotEmpty ||
        _commentController.text.isNotEmpty ||
        _selectedImage != null ||
        _isMemorableGame ||
        _isGameMinimum;
  }

  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gray10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.warning_outlined,
                    color: AppColors.gray70,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('작성을 그만두시겠어요?'),
              ],
            ),
            content: const Text('지금까지 작성된 내용은 저장되지 않아요.'),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('작성 계속하기'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Close screen
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.negativeBG,
                        foregroundColor: AppColors.negative,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('삭제하고 나가기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dateTime.weekday - 1];

    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}($weekday) ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
