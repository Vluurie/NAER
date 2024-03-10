import 'package:flutter/foundation.dart';

class LogState extends ChangeNotifier {
  final List<String> _logs = [];
  String? _lastLog;
  final Map<String, int> _logCounts = {};

  List<String> get logs => List.unmodifiable(_logs);
  Map<String, int> get logCounts => Map.unmodifiable(_logCounts);

  void addLog(String log) {
    String modifiedLog = processLog(log);

    _logCounts.update(modifiedLog, (count) => count + 1, ifAbsent: () => 1);

    if (_lastLog != modifiedLog) {
      _logs.add(modifiedLog);
      _lastLog = modifiedLog;
      notifyListeners();
    }
  }

  void clearLogs() {
    _logs.clear();
    _logCounts.clear();
    _lastLog = null;
    notifyListeners();
  }

  String processLog(String log) {
    String? stageIdentifier;
    if (log.startsWith("Repacking DAT file")) {
      stageIdentifier = 'repacking_dat';
    } else if (log.contains("Converting YAX to XML")) {
      stageIdentifier = 'converting_yax_to_xml';
    } else if (log.contains("Converting XML to YAX")) {
      stageIdentifier = 'converting_xml_to_yax';
    } else if (log.startsWith("Extracting CPK")) {
      stageIdentifier = 'extracting_cpk';
    } else if (log.contains('Processing entity:')) {
      stageIdentifier = 'processing_entity';
    } else if (log.contains('Replaced objId')) {
      stageIdentifier = 'replacing_objid';
    } else if (log.contains("Randomizing complete")) {
      stageIdentifier = 'randomizing_complete';
    } else if (log.contains("Decompressing")) {
      stageIdentifier = 'decompressing';
    } else if (log.contains("Skipping")) {
      stageIdentifier = 'skipping';
    } else if (log.contains("Object ID")) {
      stageIdentifier = 'id';
    } else if (log.contains("Folder created")) {
      stageIdentifier = 'folder';
    } else if (log.contains("Export path")) {
      stageIdentifier = 'export';
    } else if (log.contains("Deleted")) {
      stageIdentifier = 'deleted';
    } else if (log.contains("Reading")) {
      stageIdentifier = 'read';
    } else if (log.contains("r5a5.dat")) {
      stageIdentifier = 'write';
    } else if (log.contains("Bad state")) {
      stageIdentifier = 'skip';
    }

    if (stageIdentifier != null) {
      switch (stageIdentifier) {
        case 'repacking_dat':
          return "Repacking DAT files initiated.";
        case 'converting_yax_to_xml':
          return "Conversion from YAX to XML in progress...";
        case 'converting_xml_to_yax':
          return "Conversion from XML to YAX in progress...";
        case 'extracting_cpk':
          return "CPK Extraction started.";
        case 'processing_entity':
          return "Searching and replacing Enemies...";
        case 'replacing_objid':
          return "Replaced Enemies.";
        case 'randomizing_complete':
          return "Randomizing process completed.";
        case 'decompressing':
          return "Decompressing DAT files in progress.";
        case 'skipping':
          return "Skipping unnecessary DAT files.";
        case 'id':
          return "Replacing Enemies in process.";
        case 'folder':
          return "Processing files.. copy to output path.";
        case 'export':
          return "Exporting dat files to output directory started.";
        case 'deleted':
          return "Deleting extracted CPK files in output directory...";
        case 'read':
          return "Reading extracted files in process.";
        case 'write':
          return "I'm the issue that can be ignored.";
        case 'skip':
          return "I had an issue, but this issue is not an issue.";
        default:
          return log;
      }
    }
    return log;
  }
}
