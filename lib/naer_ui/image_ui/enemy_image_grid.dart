import 'package:NAER/data/image_data/nier_enemy_descriptions.dart';
import 'package:NAER/data/image_data/nier_enemy_image_names.dart';
import 'package:NAER/naer_ui/image_ui/levitating_image.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnemyImageGrid extends ConsumerStatefulWidget {
  const EnemyImageGrid({super.key});

  @override
  EnemyImageGridState createState() => EnemyImageGridState();
}

class EnemyImageGridState extends ConsumerState<EnemyImageGrid> {
  String clickedImage = '';
  bool isImageClicked = false;

  @override
  Widget build(final BuildContext context) {
    final globalStateNotifer = ref.read(globalStateProvider.notifier);
    Map<String, bool> levelMap = globalStateNotifer.readLevelMap();
    if (levelMap['All Enemies without Randomization'] == false) {
      return setupImageGrid(context);
    }
    return Container();
  }

  Widget setupImageGrid(final BuildContext context) {
    const folderPath = 'assets/nier_image_folders/nier_enemy_images/';
    final imageWidgets = populateImageGrid(folderPath);

    double gridHeight;
    int crossAxisCount;

    if (MediaQuery.of(context).size.width < 750) {
      crossAxisCount = 3;
      gridHeight = 350.0;
    } else if (MediaQuery.of(context).size.width < 950) {
      crossAxisCount = 4;
      gridHeight = 450.0;
    } else if (MediaQuery.of(context).size.width < 1400) {
      crossAxisCount = 6;
      gridHeight = 500.0;
    } else {
      crossAxisCount = 8;
      gridHeight = 800.0;
    }

    Widget headerSection = Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Select the Enemies you want to have.",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AutomatoThemeColors.textColor(ref),
            ),
          ),
          IconButton(
            icon: Icon(Icons.info_outline,
                color: AutomatoThemeColors.darkBrown(ref)),
            onPressed: () {
              showEnemyInformation(context, ref);
            },
          ),
        ],
      ),
    );

    Widget gridSection = Container(
      height: gridHeight,
      decoration: BoxDecoration(
        color: AutomatoThemeColors.darkBrown(ref),
        border:
            Border.all(color: AutomatoThemeColors.primaryColor(ref), width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 300.0,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: imageWidgets.length,
            itemBuilder: (final BuildContext context, final int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: AutomatoThemeColors.hoverBrown(ref),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: imageWidgets[index],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    return Center(
      child: Column(
        children: [
          headerSection,
          gridSection,
        ],
      ),
    );
  }

  List<Widget> populateImageGrid(final String folderPath) {
    return NierEnemyImageNames.getDLCFilteredNames(ref).map((final imageName) {
      return createClickableImage('$folderPath$imageName');
    }).toList();
  }

  Widget createClickableImage(final String imagePath) {
    final globalState = ref.read(globalStateProvider.notifier);
    final baseName = Uri.parse(imagePath).pathSegments.last;
    bool isSelected = globalState.readSelectedImages().contains(baseName);
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return ValueListenableBuilder(
      valueListenable: isHovered,
      builder: (final context, final value, final child) {
        return MouseRegion(
          onEnter: (final _) => isHovered.value = true,
          onExit: (final _) => isHovered.value = false,
          child: InkWell(
            onTap: () {
              onImageClick(baseName);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    transform: Matrix4.identity()
                      ..scale(isHovered.value ? 1.05 : 1.0),
                    decoration: BoxDecoration(
                      color: AutomatoThemeColors.transparentColor(ref),
                      borderRadius: BorderRadius.circular(20),
                      // Remove logic for isBuggyEnemy and isSpecialEnemy
                      boxShadow: isHovered.value
                          ? [
                              BoxShadow(
                                color: AutomatoThemeColors.primaryColor(ref)
                                    .withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 50,
                                offset: const Offset(0, 10),
                              ),
                            ]
                          : [],
                      border: Border.all(
                        color: isSelected || isHovered.value
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : AutomatoThemeColors.transparentColor(ref),
                        width: 3,
                      ),
                    ),
                    child: Opacity(
                      opacity: isSelected ? 0.7 : 1.0,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    onPressed: () {
                      showImageInformation(baseName);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void onImageClick(final String imageName) {
    final globalState = ref.read(globalStateProvider.notifier);
    if (globalState.readSelectedImages().contains(imageName)) {
      globalState.removeSelectedImage(imageName);
    } else {
      globalState.addSelectedImage(imageName);
    }
  }

  void selectAllImages() {
    final globalState = ref.read(globalStateProvider.notifier);
    final allImageNames = NierEnemyImageNames.getDLCFilteredNames(ref);
    globalState.selectAllImages(allImageNames);
  }

  void unselectAllImages() {
    final globalState = ref.read(globalStateProvider.notifier);
    globalState.unselectAllImages();
  }

  void showImageInformation(final String imageName) {
    setState(() {
      clickedImage = imageName;
      isImageClicked = true;
    });

    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    String mapKey =
        'PAUSE_ENEMY_${imageName.replaceAll(RegExp(r'(_?[eE][mM])|(\.PNG)', caseSensitive: false), '').toUpperCase()}';

    String description = enemyDescriptions[mapKey] ?? '....';

    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Stack(
                  children: [
                    AutomatoBackground(
                      showBackgroundSVG: false,
                      showRepeatingBorders: false,
                      backgroundColor: const Color.fromARGB(255, 99, 95, 80),
                      linesConfig: const LinesConfig(
                        lineColor: Color.fromARGB(255, 65, 63, 53),
                        strokeWidth: 2.5,
                        spacing: 7.0,
                        flickerDuration: Duration(milliseconds: 800),
                        enableFlicker: false,
                        drawHorizontalLines: true,
                        drawVerticalLines: true,
                      ),
                      ref: ref,
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MouseRegion(
                              onEnter: (final _) => isHovered.value = true,
                              onExit: (final _) => isHovered.value = false,
                              child: LevitatingImage(
                                imagePath:
                                    'assets/nier_image_folders/nier_enemies_ingame_images/$imageName',
                                isHovered: isHovered.value,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Enemy Information",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Close",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AutomatoThemeColors.primaryColor(ref),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showEnemyInformation(final BuildContext context, final WidgetRef ref) {
    AutomatoDialogManager().showInfoDialog(
      context: context,
      ref: ref,
      title: "Enemy Randomizer Information",
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              "This tool allows you to customize the enemy selection process in the game. Please note:",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AutomatoThemeColors.textDialogColor(ref)),
            ),
            const SizedBox(height: 10),
            Text(
                "• Single Enemy Selection: Choosing a single enemy will replace all enemies in the game with your selected enemy.",
                style:
                    TextStyle(color: AutomatoThemeColors.textDialogColor(ref))),
            const SizedBox(height: 5),
            Text(
                "• Multiple Enemies Selection: Selecting multiple enemies will randomize the game's enemies, limiting them to your chosen selections.",
                style:
                    TextStyle(color: AutomatoThemeColors.textDialogColor(ref))),
            const SizedBox(height: 5),
            Text(
                "• Full Randomization: For a completely unpredictable experience, simply hit 'Modify' without making any specific selections. This option includes all enemies in the randomization process.",
                style:
                    TextStyle(color: AutomatoThemeColors.textDialogColor(ref))),
            const SizedBox(height: 10),
            Text(
              "Important Notes:",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AutomatoThemeColors.dangerZone(ref)),
            ),
            const SizedBox(height: 5),
            Text(
                "• Bosses and enemies with alias tags remain unchanged to preserve game logic. Altering these can disrupt the game's fundamental mechanics, leading to potential issues during gameplay.",
                style:
                    TextStyle(color: AutomatoThemeColors.textDialogColor(ref))),
          ],
        ),
      ),
      onOkPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
