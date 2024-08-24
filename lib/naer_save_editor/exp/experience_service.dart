import 'dart:io';
import 'dart:typed_data';
import 'package:NAER/naer_save_editor/exp/experience_values.dart';

/// A service class for managing experience data within NieR: Automata's SlotData save files.
///
/// This class includes methods for reading, updating, and calculating experience
/// points and levels directly within the game's save files.
class ExperienceService {
  /// The file position where experience data starts within the save file.
  static const int startExperiencePosition = 0x3871C;

  /// The length (in bytes) of the experience data to read from the save file.
  static const int experienceLength = 4;

  static Future<int> readExperienceFromPosition(
      String filePath, int position, int length) async {
    var file = File(filePath);
    RandomAccessFile raf = await file.open(mode: FileMode.read);

    await raf.setPosition(position);
    Uint8List bytes = await raf.read(length);
    int experience = ByteData.view(bytes.buffer).getInt32(0, Endian.little);

    await raf.close();
    return experience;
  }

  static int getMinExperience() {
    return ExpTable.experienceTable.first["Experience"] ?? 0;
  }

  static int getMaxExperience() {
    return ExpTable.experienceTable.last["Experience"] ?? 0;
  }

  static Future<void> updateExperienceInFile(
      String filePath, int newExperience) async {
    if (newExperience < 0) {
      throw ArgumentError("Experience cannot be negative.");
    }

    final maxExperience = getMaxExperience();
    if (newExperience > maxExperience) {
      newExperience = maxExperience;
    }

    var byteData = ByteData(4);
    byteData.setInt32(0, newExperience, Endian.little);
    Uint8List bytes = byteData.buffer.asUint8List();

    var file = File(filePath);
    RandomAccessFile raf = await file.open(mode: FileMode.append);
    await raf.setPosition(startExperiencePosition);
    await raf.writeFrom(bytes);
    await raf.close();
  }

  static Future<int> getExperienceFromFile(String filePath) async {
    return await readExperienceFromPosition(
        filePath, startExperiencePosition, experienceLength);
  }

  static int getLevelFromExperience(int experience) {
    if (experience < 0) {
      throw ArgumentError("experience cannot be a negative integer.");
    }

    for (var i = ExpTable.experienceTable.length - 1; i >= 0; i--) {
      if (experience >= ExpTable.experienceTable[i]["Experience"]!) {
        return ExpTable.experienceTable[i]["Level"]!;
      }
    }
    return 1; // Defaults to level 1 if no matching level is found.
  }

  static int getExperienceForLevel(int level) {
    int experienceForLevel = 0;
    for (var entry in ExpTable.experienceTable) {
      if (entry["Level"] == level) {
        experienceForLevel = entry["Experience"]!;
        break;
      }
    }
    return experienceForLevel;
  }

  static int getExperienceToNextLevel(int experience) {
    if (experience < 0) {
      throw ArgumentError("experience cannot be a negative integer.");
    }

    for (var entry in ExpTable.experienceTable) {
      if (experience < entry["Experience"]!) {
        return entry["Experience"]! - experience;
      }
    }
    return 0; // Returns 0 if the current experience reaches or exceeds the maximum level.
  }
}
