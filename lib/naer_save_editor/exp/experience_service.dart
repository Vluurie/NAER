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

  /// Reads the experience points from a specified position in a save file.
  ///
  /// Parameters:
  /// - `filePath`: The path to the save file.
  /// - `position`: The byte position in the file from which to start reading.
  /// - `length`: The number of bytes to read for the experience data.
  ///
  /// Returns a future that completes with the integer value of the experience points.
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

  /// Retrieves the minimum experience value from the experience table.
  ///
  /// Returns the minimum experience required for any level, defaulting to 0.
  static int getMinExperience() {
    return ExpTable.experienceTable.first["Experience"] ?? 0;
  }

  /// Retrieves the maximum experience value from the experience table.
  ///
  /// Returns the maximum experience obtainable, according to the table.
  static int getMaxExperience() {
    return ExpTable.experienceTable.last["Experience"] ?? 0;
  }

  /// Updates the experience points in a save file to a new value.
  ///
  /// Parameters:
  /// - `filePath`: The path to the save file.
  /// - `newExperience`: The new experience value to write to the file.
  ///
  /// Validates the new experience value before writing and ensures it doesn't exceed the maximum allowed.
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

  /// Retrieves the current experience points from a save file.
  ///
  /// Parameters:
  /// - `filePath`: The path to the save file.
  ///
  /// Utilizes `readExperienceFromPosition` to read the experience points from the default start position.
  static Future<int> getExperienceFromFile(String filePath) async {
    return await readExperienceFromPosition(
        filePath, startExperiencePosition, experienceLength);
  }

  /// Calculates the level based on the current experience points.
  ///
  /// Parameters:
  /// - `experience`: The current experience points.
  ///
  /// Returns the level corresponding to the provided experience points according to the experience table.
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

  /// Retrieves the required experience points for a specified level.
  ///
  /// Parameters:
  /// - `level`: The level for which to find the required experience points.
  ///
  /// Returns the experience points needed to achieve the given level.
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

  /// Calculates the experience points needed to reach the next level from the current experience.
  ///
  /// Parameters:
  /// - `experience`: The current experience points.
  ///
  /// Returns the difference in experience points between the next level and the current experience points.
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
