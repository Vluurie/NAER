import 'dart:convert';
import 'dart:io';

class ImportantIDs {
  Map<String, List<String>> ids;

  ImportantIDs(this.ids);

  Iterable<MapEntry<String, List<String>>> get entries => ids.entries;

  // Method to add an ID to a specific category
  void addId(String category, String id) {
    if (!ids.containsKey(category)) {
      ids[category] = [];
    }
    ids[category]?.add(id);
  }

  // Method to remove an ID from a specific category
  bool removeId(String category, String id) {
    return ids[category]?.remove(id) ?? false;
  }

  // Get all IDs for a category
  List<String>? getIdsForCategory(String category) {
    return ids[category];
  }

  // Check if an ID exists within a specific category
  bool idExists(String category, String id) {
    if (!ids.containsKey(category)) {
      return false;
    }
    return ids[category]?.contains(id) ?? false;
  }

  static Future<ImportantIDs> loadFromMetadata(String metadataPath) async {
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
    '0x7164ad39'
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
    '0x4647d8ff'
  ],
  "EnemyGenerator": ['0x3716b0fd']
};
