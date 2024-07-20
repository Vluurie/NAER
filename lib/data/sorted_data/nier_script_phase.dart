class ScriptingPhase {
  final String id;
  final String description;
  final bool? dlc;

  ScriptingPhase({required this.id, required this.description, this.dlc});

  static final List<ScriptingPhase> scriptingPhases = [
    ScriptingPhase(
        id: "p100", description: "Phase before the big bang (ph1/p100.dat)"),
    ScriptingPhase(
        id: "p200", description: "Phase after big bang route C (ph2/p200.dat)"),
    ScriptingPhase(id: "p300", description: "Phase Route C (ph3/p300.dat)"),
    ScriptingPhase(
        id: "p400", description: "DLC Phase (ph4/p400.dat)", dlc: true),
    ScriptingPhase(id: "corehap", description: "Core Phase (core/corehap.dat)"),
  ];

  // Helper function to get a scripting phase by ID
  static ScriptingPhase? getScriptingPhaseById(String id) {
    try {
      return scriptingPhases.firstWhere((phase) => phase.id == id);
    } catch (e) {
      // If no scripting phase is found with the given id, return null or handle it as you see fit
      return null;
    }
  }
}
