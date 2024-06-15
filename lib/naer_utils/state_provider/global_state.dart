import 'package:NAER/custom_naer_ui/image_ui/enemy_image_grid.dart';
import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  GlobalKey setupDirectorySelectionKey = GlobalKey();
  GlobalKey setupImageGridKey = GlobalKey();
  GlobalKey setupCategorySelectionKey = GlobalKey();
  GlobalKey setupLogOutputKey = GlobalKey();
  GlobalKey<EnemyImageGridState> enemyImageGridKey = GlobalKey();
  List<String> createdFiles = [];
  List<String> createdDatFiles = [];
  List<String> ignoredModFiles = [];
  List<String> logMessages = [];
  Set<String> loggedStages = {};
  bool isLoading = false;
  bool isButtonEnabled = true;
  bool isLogIconBlinking = false;
  bool hasError = false;
  bool isProcessing = false;
  bool selectAllQuests = true;
  bool selectAllMaps = true;
  bool selectAllPhases = true;
  bool savePaths = false;
  String input = '';
  String scriptPath = '';
  String specialDatOutputPath = '';
  String? lastLogProcessed;
  int enemyLevel = 1;
  int selectedIndex = 0;
  double enemyStats = 0.0;
  Map<String, bool> stats = {"None": true, "Select All": false};
  Map<String, bool> categories = {};
  Map<String, bool> level = {
    "All Enemies": false,
    "All Enemies without Randomization": false,
    'None': true
  };
}
