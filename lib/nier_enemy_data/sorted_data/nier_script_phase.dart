class ScriptingPhase {
  final String id;
  final String description;

  ScriptingPhase({required this.id, required this.description});

  static final List<ScriptingPhase> scriptingPhases = [
    ScriptingPhase(id: "p100", description: "Phase before the big bang"),
    ScriptingPhase(id: "p200", description: "Phase after big bang route C"),
    ScriptingPhase(id: "p300", description: "Phase Route C"),
    ScriptingPhase(id: "p400", description: "DLC Phase"),
    ScriptingPhase(id: "corehap", description: "Core Phase"),
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
