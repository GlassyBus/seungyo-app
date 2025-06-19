import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/models/team.dart' as app_models;
import 'package:seungyo/services/database_service.dart';
import 'package:seungyo/theme/app_colors.dart';
import 'package:seungyo/theme/app_text_styles.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';

class NicknameInputView extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const NicknameInputView({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<NicknameInputView> createState() => _NicknameInputViewState();
}

class _NicknameInputViewState extends State<NicknameInputView> {
  final TextEditingController _controller = TextEditingController();
  bool isTextFieldFocused = false;
  FocusNode focusNode = FocusNode();

  // 팀 데이터 관련
  List<app_models.Team> _teams = [];
  app_models.Team? _selectedTeam;
  bool _isLoadingTeams = true;

  // 닉네임 최소/최대 길이 제한
  static const int _minLength = 1;
  static const int _maxLength = 10;

  // 닉네임 유효성 상태
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    focusNode.addListener(() {
      setState(() {
        isTextFieldFocused = focusNode.hasFocus;
      });
    });
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      print('NicknameInputView: Loading teams from database...');
      final teams = await DatabaseService().getTeamsAsAppModels();
      print('NicknameInputView: Loaded ${teams.length} teams');

      setState(() {
        _teams = teams;
        _isLoadingTeams = false;
      });

      // 선택된 팀 찾기
      final vm = context.read<AuthViewModel>();
      if (vm.team != null && _teams.isNotEmpty) {
        final selectedTeam =
            _teams.where((team) => team.id == vm.team).firstOrNull;
        setState(() {
          _selectedTeam = selectedTeam;
        });
        print('NicknameInputView: Selected team - ${selectedTeam?.name}');
      }
    } catch (e) {
      print('NicknameInputView: Error loading teams: $e');
      setState(() {
        _isLoadingTeams = false;
      });
    }
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    final length = text.length;

    setState(() {
      // 닉네임 유효성 검사 - 1글자 이상이면 유효
      _isValid = length >= _minLength && length <= _maxLength;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final teamName = _selectedTeam?.name ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          FocusScope.of(context).unfocus();
          widget.onBack();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // 키보드에 맞춰 화면 크기 조정
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('정보 입력', style: AppTextStyles.subtitle1),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              widget.onBack();
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 상단 컨텐츠 영역 (스크롤 가능)
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 팀 로고 이미지 (원형 프레임 안에)
                      if (_selectedTeam != null)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.navy5,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gray30,
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: _buildTeamLogo(_selectedTeam!),
                            ),
                          ),
                        )
                      else if (_isLoadingTeams)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.navy5,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gray30,
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),

                      // 타이틀 텍스트
                      Text(
                        teamName.isNotEmpty
                            ? '$teamName 승요의\n닉네임을 입력해주세요.'
                            : '닉네임을 입력해주세요.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h3.copyWith(color: AppColors.navy),
                      ),
                      const SizedBox(height: 30),

                      // 닉네임 입력 필드
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.navy5,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isTextFieldFocused
                                    ? AppColors.navy
                                    : AppColors.gray30,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _controller,
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body2,
                            maxLength: _maxLength,
                            buildCounter:
                                (
                                  context, {
                                  required currentLength,
                                  required isFocused,
                                  maxLength,
                                }) => null,
                            decoration: InputDecoration(
                              hintText:
                                  _selectedTeam != null
                                      ? 'ex. ${_selectedTeam!.shortName}승리요정'
                                      : 'ex. 두산승리요정',
                              hintStyle: AppTextStyles.body2.copyWith(
                                color: AppColors.gray50,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 키보드가 올라올 때 충분한 여백 제공
                      SizedBox(
                        height:
                            MediaQuery.of(context).viewInsets.bottom > 0
                                ? 40
                                : 20,
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼 영역 (고정 위치, 키보드 위에 표시)
              Container(
                color: Colors.white, // 배경색 설정으로 깔끔한 분리
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom +
                          10 // 키보드 위에 여백과 함께 표시
                      : 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 등록 완료 버튼
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: TextButton(
                        onPressed:
                            _controller.text.trim().length >= _minLength &&
                                    _controller.text.trim().length <= _maxLength
                                ? () async {
                                  FocusScope.of(context).unfocus();
                                  vm.setNickname(_controller.text.trim());
                                  await vm.saveUserInfo();
                                  widget.onNext();
                                }
                                : null,
                        style: TextButton.styleFrom(
                          backgroundColor:
                              _isValid ? AppColors.navy : AppColors.navy5,
                          foregroundColor:
                              _isValid ? Colors.white : AppColors.navy30,
                          disabledForegroundColor: AppColors.navy30,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text('등록 완료', style: AppTextStyles.subtitle2),
                      ),
                    ),

                    // iOS 홈 인디케이터 (키보드가 올라올 때는 숨김)
                    if (MediaQuery.of(context).viewInsets.bottom == 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 134,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamLogo(app_models.Team team) {
    if (team.logo != null && team.logo!.isNotEmpty) {
      if (team.logo!.startsWith('assets/')) {
        return Image.asset(
          team.logo!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackLogo(team);
          },
        );
      } else {
        // 이모지나 다른 텍스트
        return Center(
          child: Text(team.logo!, style: const TextStyle(fontSize: 40)),
        );
      }
    } else {
      return _buildFallbackLogo(team);
    }
  }

  Widget _buildFallbackLogo(app_models.Team team) {
    return Center(
      child: Text(
        team.shortName.isNotEmpty ? team.shortName.substring(0, 1) : '⚾',
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
      ),
    );
  }
}
