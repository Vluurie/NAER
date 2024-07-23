import 'dart:convert';
import 'dart:io';

/// Handles Important Ids that should not be randomized to not get into an soft lock in the game or if they where used by mods to be ignored.
class ImportantIDs {
  Map<String, List<String>> ids;

  ImportantIDs(this.ids);

  /// Returns an iterable of the entries in the [ids] map.
  Iterable<MapEntry<String, List<String>>> get entries => ids.entries;

  /// Adds an ID to a specific category.
  ///
  /// If the category does not exist, it will be created.
  ///
  /// Parameters:
  /// - [category]: The category to which the ID should be added.
  /// - [id]: The ID to add to the category.
  void addId(String category, String id) {
    if (!ids.containsKey(category)) {
      ids[category] = [];
    }
    ids[category]?.add(id);
  }

  /// Removes an ID from a specific category.
  ///
  /// Parameters:
  /// - [category]: The category from which the ID should be removed.
  /// - [id]: The ID to remove from the category.
  ///
  /// Returns true if the ID was removed, false otherwise.
  bool removeId(String category, String id) {
    return ids[category]?.remove(id) ?? false;
  }

  /// Gets all IDs for a category.
  ///
  /// Parameters:
  /// - [category]: The category for which to retrieve the IDs.
  ///
  /// Returns a list of IDs for the specified category, or null if the category does not exist.
  List<String>? getIdsForCategory(String category) {
    return ids[category];
  }

  /// Checks if an ID exists within a specific category.
  ///
  /// Parameters:
  /// - [category]: The category to check.
  /// - [id]: The ID to check for existence.
  ///
  /// Returns true if the ID exists in the category, false otherwise.
  bool idExists(String category, String id) {
    if (!ids.containsKey(category)) {
      return false;
    }
    return ids[category]?.contains(id) ?? false;
  }

  /// Loads important IDs from the metadata file.
  ///
  /// This method reads the metadata file, parses its content, and loads the important IDs.
  /// If the metadata file does not exist or an error occurs, it returns a new instance
  /// of [ImportantIDs] with default important IDs.
  ///
  /// Parameters:
  /// - [metadataPath]: The path to the metadata file.
  ///
  /// Returns a Future that completes with an instance of [ImportantIDs] loaded from the metadata file.
  static Future<ImportantIDs> loadIdsFromMetadata(String metadataPath) async {
    try {
      final File metadataFile = File(metadataPath);
      if (await metadataFile.exists()) {
        final String metadataContent = await metadataFile.readAsString();
        final Map<String, dynamic> decoded = jsonDecode(metadataContent);
        final Map<String, List<String>> loadedIds = {
          ...ImportantIDMap.importantIds
        };

        for (var mod in (decoded['mods'] as List? ?? [])) {
          Map<String, dynamic>? modImportantIDs = (mod
              as Map<String, dynamic>)['importantIDs'] as Map<String, dynamic>?;

          if (modImportantIDs != null) {
            modImportantIDs.forEach((category, ids) {
              var newIds = List<String>.from(ids as List? ?? []);
              if (loadedIds.containsKey(category)) {
                loadedIds[category] = [
                  ...loadedIds[category]!,
                  ...newIds.where((id) => !loadedIds[category]!.contains(id))
                ];
              } else {
                loadedIds[category] = newIds;
              }
            });
          }
        }

        return ImportantIDs(loadedIds);
      } else {
        print("Metadata file does not exist.");
      }
    } catch (e) {
      print("Failed to load IDs from metadata: $e");
    }
    return ImportantIDs({...ImportantIDMap.importantIds});
  }
}

/// Important Ids that should not be randomized to not get into an soft lock
///
///

class ImportantIDMap {
  static Map<String, List<String>> importantIds = {
    "EnemySetAction": [
      '0x864ec3e4', // Desert House Complex Main Quest Run Away Enemy
      '0x82f0aad8', // Desert House Complex Main Quest Run Away Enemy
      '0xfcb31941', // Desert House Complex Main Quest Run Away Enemy
      '0xc28c49c8', // Flight Units in free shooting
      '0xa85d4ceb', // Ground Zako Battle A2 enemies
      '0xa0f02852', // Ground Zako Battle A2 enemies
      '0x4337e41b', // Ground Zako Battle A2 enemies
      '0x1bd59060', // Ground Zako Battle A2 enemies
      '0xfc9f8dd9', // ??? custom Mod related
      '0x851d3816', // Opera Boss
      '0x9621fd68', // ?? custom Mod related
      '0x93d9f22b', // ?? custom Mod related
      '0xfdbf3011', // ?? custom Mod related
      '0xd668539d', // ?? custom Mod related
      '0x9694a602', // ?? custom Mod related
      '0xaf899d63', // ?? custom Mod related
      '0xaf6ec127', // ?? custom Mod related
      '0x8aa4e5a2', // ?? custom Mod related
      '0x7164ad39', // ?? custom Mod related
      '0xa1b007a4', // A2 fight castle
      '0x9478baf7', // A2 before 2B die
      '0x41767365', // 2B's from Tower with 9S
      '0x884e9675', // Operator fight with 9S
      '0xd6bda69e', // Big ball before Eve fight
      '0x7d5e581d', // Big ball and Snake befor Eve fight
      '0xd716220a', // Masamune set action
      '0x312571f1', // Resource Recovery Unit survived machine 9S top
      '0xdb7601d5', // Opera Boss battle androids that do nothing
      '0x9f0ac707', // Opera Boss battle androids that do nothing
      '0x67f8d83d', // Opera Boss battle androids that do nothing
      '0x93e648a6', // Opera Boss battle androids that do nothing
      '0x86a14e87', // Pascal village chain machine
      '0xe47cdd6b', // Pascal village chain machine
      '0xc51b834e' // Enemy Set - Evacuation Room Raid
    ],
    "EnemySetArea": [
      '0x47e03801', // Complex City front enemies before house complex entry
      '0xae1b61f4', // special attack explo enemies route A
      '0x8db48f87', // Enemy Set Area_Shopping Mall Special Enemy - Target Hacking respawn
      '0x443b60c9', // 9S hacking flyer before war
      '0x94089242', // 9s hacking explo before war
      '0x7a04704b', // 9s hacking normal machine before war
      '0x34276727', // 9s hacking biped machine before war
      '0xa6083e2c', // 9s hacking stubby machine before war
      '0xe9153989', // meele hacking EMP enforcement enemies attacking yorha
      '0x85e6cf89', // meele hacking EMP enforcement enemies attacking yorha
      '0xf7955e', // meele hacking EMP enforcement enemies attacking yorha
      '0xb1a014a6', // meele hacking EMP enforcement enemies attacking yorha
      '0x192e569f', // // meele hacking EMP enforcement enemies attacking yorha
      '0xd884a356', // 9S resource recovery unit  floor 1 machines
      '0x27ccf96b', // 9S resource recovery unit  floor 1 machines
      '0x367d2a26', // 9S resource recovery unit  floor 1 machines
      '0x97e2183a', // 9S resource recovery unit  floor 1 machines
      '0xd11568ec', // 9S resource recovery unit  floor 2 drill machine
      '0xdab3f76e', // 9S resource recovery unit  floor 1 machines
      '0x4647d8ff', // 9S resource recovery unit  floor 2 drill machine
      '0x5a9d0ee6', // Desert Tanks duo near house complex
      '0x6b63498', // Amusement Park Tank
      '0xd7397939', // Tank battle route D with A2 before factory
      '0x46452e8a', // Quest Yorha deserter enemy
      '0xb49a4554', // Deserted YoRHa Captain
      '0x9292cc3e', // Deserted YoRHa Captain
      '0xebfa1784', // Escaped YoRHa Subordinate A
      '0x936d169a', // deserted YoRHa men duo
      '0x655d4023', // deserted YoRHa men duo
      '0xc1a4a8f', // deserted YoRHa men duo
      '0xfff25741', // Gravekeeper's Mechanical Lifeform - The Enemy Beyond the Door
      '0xa332fdfb', // Herd Leader Robot Animal
      '0x1122d8a7', // Godzilla in forest
      '0x48d420a6', // Big ball before eve fight
      '0xef31395a', // Blooded murder machine
      '0xfafb8523' // Small Stubby Cowboys
    ],
    "EnemyGenerator": [
      '0x3716b0fd', // Enemy Generator_Hacking Personnel on the war
      '0x9a62b308' // Enemy Generator_Godzilla _ forest
    ],
    "EnemyLayoutAction": [
      '0xa99c6914'
    ] // Object placement_Enemy 9S _ final battle
  };
}
