import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class ProcessService {
  static bool isProcessRunning(String processName) {
    final processIds = calloc<Uint32>(1024);
    final cb = sizeOf<Uint32>() * 1024;
    final cbNeeded = calloc<Uint32>();

    final success = EnumProcesses(processIds, cb, cbNeeded);
    if (success == 0) {
      free(processIds);
      free(cbNeeded);
      return false;
    }

    final count = cbNeeded.value ~/ sizeOf<Uint32>();

    for (var i = 0; i < count; i++) {
      final hProcess = OpenProcess(
          PROCESS_ACCESS_RIGHTS.PROCESS_QUERY_INFORMATION |
              PROCESS_ACCESS_RIGHTS.PROCESS_VM_READ,
          FALSE,
          processIds[i]);
      if (hProcess != NULL) {
        final szExeFile = wsalloc(MAX_PATH);
        if (GetModuleBaseName(hProcess, NULL, szExeFile, MAX_PATH) > 0) {
          final currentProcessName = szExeFile.toDartString();
          // directly exit if the process was found instead of making a binary search
          // on unsorted data
          if (currentProcessName == processName) {
            CloseHandle(hProcess);
            free(szExeFile);
            free(processIds);
            free(cbNeeded);
            return true;
          }
        }
        CloseHandle(hProcess);
        free(szExeFile);
      }
    }

    free(processIds);
    free(cbNeeded);
    return false;
  }

  static Future<void> startProcess(String processPath) async {
    Process.run(processPath, []);
  }

  static bool terminateProcess(String processName) {
    final processIds = calloc<Uint32>(1024);
    final cb = sizeOf<Uint32>() * 1024;
    final cbNeeded = calloc<Uint32>();

    final success = EnumProcesses(processIds, cb, cbNeeded);
    if (success == 0) {
      free(processIds);
      free(cbNeeded);
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
            free(processIds);
            free(cbNeeded);
            return terminated;
          }
        }
        CloseHandle(hProcess);
        free(szExeFile);
      }
    }

    free(processIds);
    free(cbNeeded);
    return false;
  }
}

Future<void> startNierAutomataExecutable(String directoryPath) async {
  var parentDirectory = Directory(directoryPath).parent.path;
  var processPath = '$parentDirectory\\NierAutomata.exe';

  if (await File(processPath).exists()) {
    await ProcessService.startProcess(processPath);
  } else {
    throw Exception(
        'NierAutomata.exe not found in $parentDirectory, try to start it manually.');
  }
}

Pointer<Utf16> wsalloc(int size) => calloc<Uint16>(size).cast<Utf16>();
