class MapLocation {
  final String id;
  final String description;

  MapLocation({required this.id, required this.description});

  static final List<MapLocation> mapLocations = [
    MapLocation(
        id: "r5a0",
        description: "Resource Recovery Unit (Forest) (st5/r5a0.dat)"),
    MapLocation(
        id: "r5a1",
        description: "Resource Recovery Unit (Flooded City) (st5/r5a1.dat)"),
    MapLocation(
        id: "r5a2",
        description: "Resource Recovery Unit (Amusement Park) (st5/r5a2.dat)"),
    MapLocation(id: "r500", description: "White Tower Stuff? (st5/r500.dat)"),
    MapLocation(id: "r501", description: "Copied City (st5/r501.dat)"),
    MapLocation(
        id: "r502", description: "Big cave under crater (st5/r502.dat)"),
    MapLocation(id: "r503", description: "Emils/Kaines Cave (st5/r503.dat)"),
    MapLocation(id: "r520", description: "Underground Factory (st5/r520.dat)"),
    MapLocation(
        id: "r530", description: "Underground Amusement Park (st5/r530.dat)"),
    MapLocation(id: "r550", description: "Bunker (st5/r550.dat)"),
    MapLocation(id: "r551", description: "waves? (st5/r551.dat)"),
    MapLocation(
        id: "r200", description: "City Ruins after big bang (st2/r200.dat)"),
    MapLocation(id: "r110", description: "Resistance Camp (st1/r110.dat)"),
    MapLocation(id: "r130", description: "Amusement Park (st1/r130.dat)"),
    MapLocation(id: "r140", description: "Village (st1/r140.dat)"),
    MapLocation(id: "r150", description: "Desert (st1/r150.dat)"),
    MapLocation(id: "r160", description: "Forest (st1/r160.dat)"),
    MapLocation(id: "r170", description: "Flooded City (st1/r170.dat)"),
    MapLocation(
        id: "r100", description: "City Ruins before big bang (st1/r100.dat)"),
    MapLocation(id: "r120", description: "Factory (st1/r120.dat)"),
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
