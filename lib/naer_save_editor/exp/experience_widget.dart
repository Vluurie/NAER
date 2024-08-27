import 'package:NAER/naer_save_editor/exp/experience_service.dart';
import 'package:NAER/naer_save_editor/exp/experience_values.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExperienceWidget extends ConsumerStatefulWidget {
  final String filePath;

  /// Displays and allows updating of the NieR:Automata SlotData's experience and level.
  ///
  /// Requires a filePath to the SlotData.
  ///
  const ExperienceWidget({super.key, required this.filePath});

  @override
  ExperienceWidgetState createState() => ExperienceWidgetState();
}

class ExperienceWidgetState extends ConsumerState<ExperienceWidget> {
  int _experience = 0;
  int _level = 0;
  int _experienceToNextLevel = 0;

  final TextEditingController _controller = TextEditingController();

  List<DropdownMenuItem<int>> dropdownItems = [];

  @override
  void initState() {
    super.initState();
    _loadExperience().then((final _) {
      _initializeDropdownItems();
    });
  }

  /// Loads the experience from the file and updates the state.
  Future<void> _loadExperience() async {
    try {
      int experience =
          await ExperienceService.getExperienceFromFile(widget.filePath);
      setState(() {
        _experience = experience;
        _level = ExperienceService.getLevelFromExperience(experience);
        _experienceToNextLevel =
            ExperienceService.getExperienceToNextLevel(experience);
      });
    } catch (e) {
      // print('Error loading experience: $e');
    }
  }

  /// Initializes dropdown menu items based on the levels defined in experienceTable.
  void _initializeDropdownItems() {
    dropdownItems = ExpTable.experienceTable.map((final entry) {
      return DropdownMenuItem<int>(
        value: entry["Level"],
        child: Text('Level ${entry["Level"]}'),
      );
    }).toList();
  }

  /// Handles changes to the selected level from the dropdown menu, updating the experience accordingly.
  void _handleLevelChanged(final int newLevel) {
    int newExperience = ExperienceService.getExperienceForLevel(newLevel);
    setState(() {
      _level = newLevel;
      _experience = newExperience;
      _experienceToNextLevel =
          ExperienceService.getExperienceToNextLevel(_experience);
    });
    _persistExperienceChange(_experience);
  }

  /// Updates the experience based on manual input and persists the change.
  void _updateExperience() {
    final int experienceChange = int.tryParse(_controller.text) ?? 0;
    _controller.clear();

    if (experienceChange != 0) {
      int newExperience = (_experience + experienceChange).clamp(
          ExperienceService.getMinExperience(),
          ExperienceService.getMaxExperience());

      if (newExperience != _experience) {
        setState(() {
          _experience = newExperience;
          _level = ExperienceService.getLevelFromExperience(_experience);
          _experienceToNextLevel =
              ExperienceService.getExperienceToNextLevel(_experience);
        });
        _persistExperienceChange(newExperience);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
    }
  }

  /// Persists the updated experience value to the file and shows a confirmation snackbar.
  void _persistExperienceChange(final int experience) {
    ExperienceService.updateExperienceInFile(widget.filePath, experience)
        .then((final _) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AutomatoThemeColors.darkBrown(ref),
            content: Text(
              'Experience updated! New experience: $experience',
              style: TextStyle(color: AutomatoThemeColors.textColor(ref)),
            ),
          ),
        );
      }
    }).catchError((final error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error updating experience in file: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shadowColor: AutomatoThemeColors.bright(ref),
            color: AutomatoThemeColors.darkBrown(ref),
            elevation: 20.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Note: Changes are directly modified and saved.'),
                  Row(
                    children: [
                      const SizedBox(
                        child: Text(
                          'Current: ',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      DropdownMenu(
                        dropdownMenuEntries: dropdownItems,
                        onLevelChanged: _handleLevelChanged,
                        selectedLevel: _level,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: _calculateExperienceProgress(),
                    backgroundColor: AutomatoThemeColors.textColor(ref),
                    color: AutomatoThemeColors.saveZone(ref),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Experience to Next Level: $_experienceToNextLevel',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 30),
                  // Input field for manually adding experience
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Add Experience manually',
                      labelStyle:
                          TextStyle(color: AutomatoThemeColors.textColor(ref)),
                      suffixIcon: IconButton(
                        color: AutomatoThemeColors.primaryColor(ref),
                        icon: const Icon(Icons.send),
                        onPressed: _updateExperience,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Calculates the progress towards the next level as a fraction.
  double _calculateExperienceProgress() {
    int totalExperienceForCurrentLevel = _experienceToNextLevel + _experience;
    if (totalExperienceForCurrentLevel == 0) {
      return 0.0;
    }
    return _experience / totalExperienceForCurrentLevel.toDouble();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A StatelessWidget that provides a dropdown menu for selecting a level.
///
/// Takes a list of dropdown menu items, a callback for when the level changes,
/// and the currently selected level as parameters.
class DropdownMenu extends ConsumerWidget {
  final List<DropdownMenuItem<int>> dropdownMenuEntries;
  final Function(int) onLevelChanged;
  final int selectedLevel;

  const DropdownMenu({
    super.key,
    required this.dropdownMenuEntries,
    required this.onLevelChanged,
    required this.selectedLevel,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return DropdownButton<int>(
      value: selectedLevel,
      items: dropdownMenuEntries,
      dropdownColor: AutomatoThemeColors.darkBrown(ref),
      onChanged: (final value) {
        if (value != null) {
          onLevelChanged(value);
        }
      },
      focusColor: AutomatoThemeColors.transparentColor(ref),
      style: TextStyle(color: AutomatoThemeColors.textColor(ref), fontSize: 20),
    );
  }
}
