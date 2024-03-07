class MapLocation {
  final String id;
  final String description;

  MapLocation({required this.id, required this.description});

  static final List<MapLocation> mapLocations = [
    MapLocation(id: "r5a0", description: "Resource Recovery Unit (Forest)"),
    MapLocation(
        id: "r5a1", description: "Resource Recovery Unit (Flooded City)"),
    MapLocation(
        id: "r5a2", description: "Resource Recovery Unit (Amusement Park)"),
    MapLocation(id: "r500", description: "White Tower Stuff?"),
    MapLocation(id: "r501", description: "Copied City"),
    MapLocation(id: "r502", description: "Big cave under crater"),
    MapLocation(id: "r503", description: "Emils/Kaines Cave"),
    MapLocation(id: "r520", description: "Underground Factory"),
    MapLocation(id: "r530", description: "Underground Amusement Park"),
    MapLocation(id: "r550", description: "Bunker"),
    MapLocation(id: "r551", description: "waves?"),
    MapLocation(id: "r200", description: "City Ruins after big bang"),
    MapLocation(id: "r110", description: "Resistance Camp"),
    MapLocation(id: "r130", description: "Amusement Park"),
    MapLocation(id: "r140", description: "Village"),
    MapLocation(id: "r150", description: "Desert"),
    MapLocation(id: "r160", description: "Forest"),
    MapLocation(id: "r170", description: "Flooded City"),
    MapLocation(id: "r100", description: "City Ruins before big bang"),
    MapLocation(id: "r120", description: "Factory"),
  ];

  // Helper function to get resource location by ID
  static MapLocation? getMapLocationById(String id) {
    try {
      return mapLocations.firstWhere((location) => location.id == id);
    } catch (e) {
      // If no resource location is found with the given id, return null or handle it as you see fit
      return null;
    }
  }
}
