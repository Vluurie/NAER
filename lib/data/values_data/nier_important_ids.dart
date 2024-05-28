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
        final Map<String, List<String>> loadedIds = {...importantIds};

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
    return ImportantIDs({...importantIds});
  }
}

/// Important Ids that should not be randomized to not get into an soft lock
Map<String, List<String>> importantIds = {
  "EnemySetAction": [
    '0x864ec3e4',
    '0x82f0aad8',
    '0xfcb31941',
    '0xc28c49c8',
    '0xa85d4ceb',
    '0xa0f02852',
    '0x4337e41b',
    '0x1bd59060',
    '0xfc9f8dd9',
    '0x851d3816',
    '0x9621fd68',
    '0x93d9f22b',
    '0xfdbf3011',
    '0xd668539d',
    '0x9694a602',
    '0xaf899d63',
    '0xaf6ec127',
    '0x8aa4e5a2',
    '0x7164ad39',
    '0xa1b007a4',
    '0x9478baf7',
    '0x41767365',
    '0x884e9675',
    '0xd6bda69e',
    '0x7d5e581d'
  ],
  "EnemySetArea": [
    '0x47e03801',
    '0xae1b61f4',
    '0x8db48f87',
    '0x443b60c9',
    '0x94089242',
    '0x7a04704b',
    '0x34276727',
    '0xa6083e2c',
    '0xe9153989',
    '0x85e6cf89',
    '0xf7955e',
    '0xb1a014a6',
    '0x192e569f',
    '0xd884a356',
    '0x27ccf96b',
    '0x367d2a26',
    '0x97e2183a',
    '0xd11568ec',
    '0xdab3f76e',
    '0x4647d8ff',
    '0x5a9d0ee6',
    '0x6b63498',
    '0xd7397939',
    '0x46452e8a',
    '0xb49a4554',
    '0x9292cc3e',
    '0xebfa1784',
    '0x936d169a',
    '0x655d4023',
    '0xc1a4a8f',
    '0xfff25741',
    '0xa332fdfb',
    '0x1122d8a7',
    '0x48d420a6',
    '0xef31395a'
  ],
  "EnemyGenerator": ['0x3716b0fd', '0x9a62b308'],
  "EnemyLayoutAction": ['0xa99c6914']
};
