import 'dart:async';
import 'dart:collection';

///TODO: UNUSED STILL IN WIP AND TESTING FOR PARALLEL EXTRACT COMPUTING

class GlobalRunTimeExtractedFiles {
  /// Global Runtime file lists when extracting
  static List<String> extractedCpkFiles = [];
  static List<String> extractedDatFiles = [];
  static List<String> extractedPakFiles = [];
  static List<String> extractedYaxFiles = [];

  static final Queue<Completer<void>> _datUpdateQueue = Queue();
  static final Queue<Completer<void>> _pakUpdateQueue = Queue();
  static final Queue<Completer<void>> _yaxUpdateQueue = Queue();

  // Helper function to get all .dat files
  static List<String> getDatFiles(List<String> extractedFiles) {
    return extractedFiles.where((file) => file.endsWith('.dat')).toList();
  }

  // Helper function to get all .pak files
  static List<String> getPakFiles(List<String> extractedFiles) {
    return extractedFiles.where((file) => file.endsWith('.pak')).toList();
  }

  // Helper function to get all .yax files
  static List<String> getYaxFiles(List<String> extractedFiles) {
    return extractedFiles.where((file) => file.endsWith('.yax')).toList();
  }

  // Thread-safe method to add .dat files to the global list
  static Future<void> addDatFiles(List<String> files) async {
    final completer = Completer<void>();
    _datUpdateQueue.addLast(completer);
    if (_datUpdateQueue.length == 1) {
      await _processDatQueue(files);
    }
    return completer.future;
  }

  static Future<void> _processDatQueue(List<String> files) async {
    while (_datUpdateQueue.isNotEmpty) {
      extractedDatFiles.addAll(files);
      _datUpdateQueue.removeFirst().complete();
      if (_datUpdateQueue.isNotEmpty) {
        await Future.delayed(Duration.zero);
      }
    }
  }

  // Thread-safe method to add .pak files to the global list
  static Future<void> addPakFiles(List<String> files) async {
    final completer = Completer<void>();
    _pakUpdateQueue.addLast(completer);
    if (_pakUpdateQueue.length == 1) {
      await _processPakQueue(files);
    }
    return completer.future;
  }

  static Future<void> _processPakQueue(List<String> files) async {
    while (_pakUpdateQueue.isNotEmpty) {
      extractedPakFiles.addAll(files);
      _pakUpdateQueue.removeFirst().complete();
      if (_pakUpdateQueue.isNotEmpty) {
        await Future.delayed(Duration.zero);
      }
    }
  }

  // Thread-safe method to add .yax files to the global list
  static Future<void> addYaxFiles(List<String> files) async {
    final completer = Completer<void>();
    _yaxUpdateQueue.addLast(completer);
    if (_yaxUpdateQueue.length == 1) {
      await _processYaxQueue(files);
    }
    return completer.future;
  }

  static Future<void> _processYaxQueue(List<String> files) async {
    while (_yaxUpdateQueue.isNotEmpty) {
      extractedYaxFiles.addAll(files);
      _yaxUpdateQueue.removeFirst().complete();
      if (_yaxUpdateQueue.isNotEmpty) {
        await Future.delayed(Duration.zero);
      }
    }
  }
}
