import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>(
  (final ref) => DownloadNotifier(dotenv.env['DLL_DOWNLOAD_URL']!),
);

class DownloadState {
  final bool isDownloading;
  final double progress;

  DownloadState({this.isDownloading = false, this.progress = 0.0});

  DownloadState copyWith({final bool? isDownloading, final double? progress}) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  final String downloadUri;

  DownloadNotifier(this.downloadUri) : super(DownloadState());

  Future<void> downloadDll() async {
    state = state.copyWith(isDownloading: true, progress: 0.0);

    final url = Uri.parse(downloadUri);
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final filePath = path.join(exeDir, 'extract_dat_files.dll');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        state = state.copyWith(isDownloading: false, progress: 1.0);
      } else {
        throw Exception("Failed to download file");
      }
    } catch (e) {
      state = state.copyWith(isDownloading: false, progress: 0.0);
      rethrow;
    }
  }
}
