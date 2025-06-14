import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seungyo/models/game_record_form.dart';
import 'package:seungyo/services/database_service.dart';
import 'package:seungyo/services/record_service.dart';

import '../../models/game_record.dart';
import '../../models/stadium.dart' as app_models;
import '../../models/team.dart' as app_models;
import '../../theme/app_colors.dart';
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
  final _formKey = GlobalKey<FormState>();
  late RecordService _recordService;
  late GameRecordForm _form;
  final TextEditingController _seatController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  File? _selectedImage;
  bool _isMemorableGame = false;
  bool _isGameMinimum = false;
  bool _isLoading = false;
  bool _isImageLoading = false;
  bool _isSaving = false;
  List<app_models.Stadium> _stadiums = [];
  List<app_models.Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _recordService = RecordService();
    _form = GameRecordForm();
    _loadStadiums();
    _loadTeams();
  }

  Future<void> _loadStadiums() async {
    try {
      final stadiums = await DatabaseService().getStadiumsAsAppModels();
      setState(() {
        _stadiums = stadiums;
      });
    } catch (e) {
      print('Error loading stadiums: $e');
    }
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await DatabaseService().getTeamsAsAppModels();
      setState(() {
        _teams = teams;
      });
    } catch (e) {
      print('Error loading teams: $e');
    }
  }

  String _getStadiumNameById(String stadiumId) {
    final stadium = _stadiums.firstWhereOrNull((s) => s.id == stadiumId);
    if (stadium != null) {
      return stadium.name;
    }
    return stadiumId; // fallback to ID if stadium not found
  }

  String _getTeamNameById(String teamId) {
    final team = _teams.firstWhereOrNull((t) => t.id == teamId);
    if (team != null) {
      return team.name;
    }
    return teamId; // fallback to ID if team not found
  }

  @override
  void dispose() {
    _seatController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackPress();
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
        onPressed: _handleBackPress,
      ),
      title: Text('직관 기록 작성', style: Theme.of(context).textTheme.titleLarge),
      actions: [
        _isSaving
            ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
              ),
            )
            : IconButton(
              icon: Icon(
                Icons.check,
                color: _canSave() ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
              ),
              onPressed: _canSave() ? _handleSave : null,
            ),
      ],
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 32),
              _buildInfoSection(),
              const SizedBox(height: 32),
              _buildGameInfoSection(),
              const SizedBox(height: 32),
              _buildCommentSection(),
              const SizedBox(height: 32),
              _buildMemorableGameSection(),
              // 키보드가 표시될 때 충분한 공간 확보
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child:
            _isImageLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('이미지 로딩 중...', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 14)),
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
                    Icon(Icons.add_photo_alternate_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 8),
                    Text('사진 추가', style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 16)),
                  ],
                ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoRow(
          '일정',
          _form.gameDateTime != null ? _formatDateTime(_form.gameDateTime!) : '날짜를 선택해주세요.',
          () => _showDateTimePicker(),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          '위치',
          _form.stadiumId != null ? _getStadiumNameById(_form.stadiumId!) : '경기장을 선택해주세요.',
          () => _showStadiumPicker(),
        ),
        const SizedBox(height: 16),
        _buildSeatInput(),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPlaceholder = value.contains('선택해주세요') || value.contains('입력해주세요');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colorScheme.outlineVariant))),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.outline)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: isPlaceholder ? colorScheme.outline : null),
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatInput() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colorScheme.outlineVariant))),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text('좌석', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.outline)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: _seatController,
              decoration: InputDecoration(
                hintText: '좌석을 입력해주세요.',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (value) {
                setState(() {
                  _form = _form.copyWith(seatInfo: value.isEmpty ? null : value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '경기 정보',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildTeamLabels(),
              const SizedBox(height: 16),
              _buildTeamSelection(),
              const SizedBox(height: 20),
              _buildGameMinimumCheckbox(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamLabels() {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('응원팀', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline)),
        Text('상대팀', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline)),
      ],
    );
  }

  Widget _buildTeamSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTeamButton('응원팀', _form.homeTeamId, () => _showTeamPicker(true)),
        GestureDetector(
          onTap: _form.homeTeamId != null && _form.awayTeamId != null ? _showScoreInput : null,
          child: Row(
            children: [
              Text(
                _form.homeScore != null ? '${_form.homeScore}' : '-',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color:
                      _form.homeScore != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                ':',
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
              Text(
                _form.awayScore != null ? '${_form.awayScore}' : '-',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color:
                      _form.awayScore != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        _buildTeamButton('상대팀', _form.awayTeamId, () => _showTeamPicker(false)),
      ],
    );
  }

  Widget _buildTeamButton(String label, String? teamId, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(8)),
        child: Text(
          teamId != null ? _getTeamNameById(teamId) : '팀 선택',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildGameMinimumCheckbox() {
    final colorScheme = Theme.of(context).colorScheme;

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
              color: _isGameMinimum ? colorScheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _isGameMinimum ? colorScheme.primary : colorScheme.outline, width: 2),
            ),
            child: _isGameMinimum ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text('경기최소', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline)),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '코멘트',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          focusNode: _commentFocusNode,
          decoration: InputDecoration(
            hintText: '코멘트를 남겨주세요.',
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _form = _form.copyWith(comment: value.isEmpty ? null : value);
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

  Widget _buildMemorableGameSection() {
    return Column(
      children: [
        Text(
          '기억에 남는 경기였나요?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
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
            child: Icon(Icons.favorite, color: _isMemorableGame ? AppColors.negative : AppColors.gray30, size: 80),
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
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.gray30, borderRadius: BorderRadius.circular(2)),
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
          _form = _form.copyWith(imagePath: pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 로딩 중 오류가 발생했습니다: $e')));
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
                _form = _form.copyWith(gameDateTime: dateTime);
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
            selectedStadium: _form.stadiumId,
            onStadiumSelected: (stadiumId) {
              setState(() {
                _form = _form.copyWith(stadiumId: stadiumId);
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
            selectedTeam: isHomeTeam ? _form.homeTeamId : _form.awayTeamId,
            onTeamSelected: (teamId) {
              setState(() {
                if (isHomeTeam) {
                  _form = _form.copyWith(homeTeamId: teamId);
                } else {
                  _form = _form.copyWith(awayTeamId: teamId);
                }
              });
            },
          ),
    );
  }

  void _showScoreInput() {
    if (_form.homeTeamId == null || _form.awayTeamId == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => ScoreInputModal(
            homeTeam: _form.homeTeamId!,
            awayTeam: _form.awayTeamId!,
            initialHomeScore: _form.homeScore,
            initialAwayScore: _form.awayScore,
            onScoreSelected: (homeScore, awayScore) {
              setState(() {
                _form = _form.copyWith(homeScore: homeScore, awayScore: awayScore);
              });
            },
          ),
    );
  }

  bool _canSave() {
    return _form.gameDateTime != null &&
        _form.stadiumId != null &&
        _form.homeTeamId != null &&
        _form.awayTeamId != null;
  }

  Future<void> _handleSave() async {
    if (!_canSave()) return;

    try {
      setState(() {
        _isSaving = true;
      });

      // 폼 데이터 업데이트
      _form = _form.copyWith(
        seatInfo: _seatController.text.isEmpty ? null : _seatController.text,
        comment: _commentController.text.isEmpty ? null : _commentController.text,
        isFavorite: _isMemorableGame, // 기억에 남는 경기는 자동으로 즐겨찾기에 추가
        canceled: _isGameMinimum, // 경기최소는 취소된 경기로 처리
      );

      await _submitForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    if (!_form.isValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('경기 날짜, 구장, 홈팀, 원정팀 정보를 모두 입력해주세요.'), backgroundColor: Colors.red));
      return;
    }

    try {
      setState(() => _isSaving = true);
      await _recordService.addRecord(_form);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('기록 저장 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _handleBackPress() {
    if (_isSaving) return;
    Navigator.of(context).pop();
  }

  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[dateTime.weekday - 1];

    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}($weekday) ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
