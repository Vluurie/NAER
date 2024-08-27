import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

Future<T> runProcessServiceInZone<T>(Future<T> Function() body) {
  final completer = Completer<T>();
  runZonedGuarded(() async {
    completer.complete(await body());
  }, (error, stackTrace) {
    globalLog("Unhandled error: $error\n$stackTrace");
    completer.completeError(error, stackTrace);
  });
  return completer.future;
}

Future<bool> startNierAutomataExecutable(
    String directoryPath, VoidCallback onProcessStopped) {
  return runProcessServiceInZone(() async {
    var parentDirectory = Directory(directoryPath).parent.path;
    var processPath = '$parentDirectory\\NierAutomata.exe';

    if (await File(processPath).exists()) {
      try {
        await ProcessService.startProcess(processPath);

        //  60-second listener to check if the process starts
        bool processStarted =
            await ProcessService.checkProcessStartedWithinTime(
                'NierAutomata.exe', const Duration(seconds: 60));

        if (processStarted) {
          unawaited(ProcessService.monitorProcessByName(
              'NierAutomata.exe', onProcessStopped));
          return true; // Process started successfully
        } else {
          globalLog(
              "Nier Automata did not start within the expected time frame.");
          return false; // Process failed to start within the time limit
        }
      } catch (e) {
        globalLog("Error while starting Nier Automata: $e");
        return false; // Failed to start the process
      }
    } else {
      globalLog(
          'NierAutomata.exe not found in $parentDirectory. Please start it manually.');
      return false; // Process not found
    }
  });
}

class ProcessService {
  static bool isProcessRunning(String processName) {
    final processIds = calloc<Uint32>(1024);
    final cb = sizeOf<Uint32>() * 1024;
    final cbNeeded = calloc<Uint32>();

    try {
      final success = EnumProcesses(processIds, cb, cbNeeded);
      if (success == 0) {
        return false;
      }

      final count = cbNeeded.value ~/ sizeOf<Uint32>();
      final lowerCaseProcessName = processName.toLowerCase();

      for (var i = 0; i < count; i++) {
        final hProcess = OpenProcess(
            PROCESS_ACCESS_RIGHTS.PROCESS_QUERY_INFORMATION |
                PROCESS_ACCESS_RIGHTS.PROCESS_VM_READ,
            FALSE,
            processIds[i]);
        if (hProcess != NULL) {
          final szExeFile = wsalloc(MAX_PATH);
          if (GetModuleBaseName(hProcess, NULL, szExeFile, MAX_PATH) > 0) {
            final currentProcessName = szExeFile.toDartString().toLowerCase();
            if (currentProcessName.contains(lowerCaseProcessName)) {
              CloseHandle(hProcess);
              free(szExeFile);
              return true;
            }
          }
          CloseHandle(hProcess);
          free(szExeFile);
        }
      }
    } catch (e) {
      globalLog("Error during process enumeration: $e");
    } finally {
      free(processIds);
      free(cbNeeded);
    }

    return false;
  }

  static Future<bool> checkProcessStartedWithinTime(
      String processName, Duration timeout) async {
    final completer = Completer<bool>();
    Timer? checkTimer;
    Timer? timeoutTimer;

    checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isProcessRunning(processName)) {
        timer.cancel();
        timeoutTimer?.cancel();
        completer.complete(true); // Process started
      }
    });

    // timeout to stop the check after duration
    timeoutTimer = Timer(timeout, () {
      checkTimer?.cancel();
      if (!completer.isCompleted) {
        completer
            .complete(false); // Process did not start within the time frame
      }
    });

    return completer.future;
  }

  static Future<void> monitorProcessByName(
      String processName, VoidCallback onProcessStopped) async {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!isProcessRunning(processName)) {
        await Future.delayed(const Duration(seconds: 2));

        if (!isProcessRunning(processName)) {
          timer.cancel();
          onProcessStopped();
        }
      }
    });
  }

  static Future<Process> startProcess(String processPath) async {
    try {
      Process process = await Process.start(processPath, []);
      return process;
    } catch (e) {
      globalLog("Failed to start process $processPath: $e");
      rethrow;
    }
  }

  static bool terminateProcess(String processName) {
    final processIds = calloc<Uint32>(1024);
    final cb = sizeOf<Uint32>() * 1024;
    final cbNeeded = calloc<Uint32>();

    try {
      final success = EnumProcesses(processIds, cb, cbNeeded);
      if (success == 0) {
        return false;
      }

      final count = cbNeeded.value ~/ sizeOf<Uint32>();
      final exeName = processName.toLowerCase();

      for (var i = 0; i < count; i++) {
        final hProcess = OpenProcess(
            PROCESS_ACCESS_RIGHTS.PROCESS_QUERY_INFORMATION |
                PROCESS_ACCESS_RIGHTS.PROCESS_VM_READ |
                PROCESS_ACCESS_RIGHTS.PROCESS_TERMINATE,
            FALSE,
            processIds[i]);
        if (hProcess != NULL) {
          final szExeFile = wsalloc(MAX_PATH);
          if (GetModuleBaseName(hProcess, NULL, szExeFile, MAX_PATH) > 0) {
            final processExeName = szExeFile.toDartString().toLowerCase();
            if (processExeName == exeName) {
              final terminated = TerminateProcess(hProcess, 0) != 0;
              CloseHandle(hProcess);
              free(szExeFile);
              return terminated;
            }
          }
          CloseHandle(hProcess);
          free(szExeFile);
        }
      }
    } catch (e) {
      globalLog("Error during process termination: $e");
    } finally {
      free(processIds);
      free(cbNeeded);
    }

    return false;
  }
}

Pointer<Utf16> wsalloc(int size) => calloc<Uint16>(size).cast<Utf16>();
