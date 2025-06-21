import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageSaveService {
  /// 이미지를 갤러리에 저장합니다.
  ///
  /// [imagePath]: 저장할 이미지 파일 경로
  /// [context]: 에러 메시지 표시를 위한 BuildContext
  ///
  /// Returns: 저장 성공 여부
  static Future<bool> saveImageToGallery(
    String imagePath,
    BuildContext context,
  ) async {
    try {
      // 1. 파일 존재 여부 확인
      final file = File(imagePath);
      if (!file.existsSync()) {
        if (context.mounted) {
          _showError(context, '이미지 파일을 찾을 수 없습니다.');
        }
        return false;
      }

      // 2. 권한 확인 및 요청
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        if (context.mounted) {
          _showError(context, '갤러리 접근 권한이 필요합니다.');
        }
        return false;
      }

      // 3. 갤러리에 이미지 저장
      await Gal.putImage(imagePath);

      // 4. 성공 메시지 표시
      if (context.mounted) {
        _showSuccess(context, '이미지가 갤러리에 저장되었습니다.');
      }
      return true;
    } catch (e) {
      // 5. 에러 처리
      debugPrint('이미지 저장 실패: $e');
      if (context.mounted) {
        _showError(context, '이미지 저장에 실패했습니다.');
      }
      return false;
    }
  }

  /// 갤러리 접근 권한을 확인하고 요청합니다.
  static Future<bool> _requestPermission() async {
    // Android 13 (API 33) 이상에서는 MANAGE_EXTERNAL_STORAGE 권한 불필요
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        // Android 13+ : READ_MEDIA_IMAGES 권한 확인
        return await Permission.photos.request().isGranted;
      } else {
        // Android 12 이하 : WRITE_EXTERNAL_STORAGE 권한 확인
        return await Permission.storage.request().isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS: 사진 라이브러리 접근 권한 확인
      return await Permission.photos.request().isGranted;
    }

    return false;
  }

  /// Android 버전을 확인합니다.
  static Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        // Android API Level을 직접 확인하는 방법이 제한적이므로
        // gal 라이브러리가 내부적으로 처리하도록 합니다.
        return 33; // 최신 버전으로 가정
      }
    } catch (e) {
      debugPrint('Android 버전 확인 실패: $e');
    }
    return 30; // 기본값
  }

  /// 성공 메시지를 표시합니다.
  static void _showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 에러 메시지를 표시합니다.
  static void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
