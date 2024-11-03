# NAER - N:A Enemy Randomizer Tool

## Overview

NAER, the ultimate enemy randomization tool designed to enhance your gaming experience in the critically acclaimed action RPG. With NAER, you have the power to breathe new life into the game by introducing a variety of randomization options. Whether you seek to intensify the challenge or simply wish to explore the game from a fresh perspective, NAER is here to cater to your desires.

![Screenshot 2024-09-09 222510](https://github.com/user-attachments/assets/cb163537-f0b9-4f44-8824-98934490c6f7)

## Features

- **Enemy Randomization**: Shake things up by randomizing enemies.
- **Level Modification**: Tailor the game's difficulty by adjusting the levels of all enemies. If you don't want randomized enemies but the level changed, this is indeed possible!.
- **Selective Randomization**: Have full control with the ability to choose specific categories for randomization, including all maps, all phases, all quests, and an option to exclude DLC content.
- **Custom Enemy Selection**: Craft a personalized experience by handpicking the enemies you wish to encounter. You can even select just one enemy that replaces all other enemies in the game to this selected one.
- **Undo Functionality**: Revert back to the default setting of the game with just two clicks. 
- **Enemy Stats modification**: By this amount of combo possibilities, you think the enemies are just too weak? Change the enemy stats up to 5x for a harder playthrough.
- **Balance Mode**: Enemies too hard? With the balance mode you can easy kill even hard enemies that got randomized!.
- **Save File Editor**: First time playing again? Want to be directly max level? Need money? Edit your save file directly in NAER!.
- **Mod Manager**: You come to the point that only randomizing is not enough? Adding extra mods does remove the randomized files? With the mod manager you can randomize any mod file or add them to the mod list with ID's that should not be randomized! Drag folders, press install or only install the mod without randomization any time!
- **Backup extracted files**: Tired of waiting over 1 minute for a randomization? With backup option you reduce the modify time to less than 15 seconds!
- **User-Interface**: Enjoy a straightforward and intuitive user interface for a hassle-free configuration process.
- **NAER UI Theme**: You want a different theme? Choose a different one from over 8 automato themes!.

  Note: Bosses needed for the Game Logic are not altered. So u can play normally the story.
  Sometimes some enemies that spawn from the top are staying on the top, simply shoot them down.
  If u found anything really annoying or u cannot continue the game because of some issue that is from an enemy. Feel free to join the Modding Discord and try to ask for help.

## Installation for Users

Download the latest executable, extract the .zip folder and run the .exe in the folder.

  1. Select your game data directory of Nier as Input directory.
  2.Select ANY (but recommended for direct play also your game data path) directory of Nier as Output directory.
     N:A data directory: `?:\SteamLibrary\steamapps\common\NieRAutomata\data`
  4. Simply select what you want to modify.
  5. Press 'Modify'.
  6. Watch out the log output for information and process.
  7. For undo, simply press 'Undo'.
  8. Enjoy!

## Installation for Developers

To build the NAER tool, follow these steps:

1. **Download Repository**: Clone or download the NAER repository from GitHub.
2. **Install Flutter Dart CLI**: Download and install the Flutter Dart CLI, which will help manage dependencies and build the project.
3. **Fetch Dependencies**: Navigate to the project directory and run `flutter pub get` to fetch the latest dependencies.
4. **Assets**: For the missing assets, feel free to get them from the last release assets folder and copy them into the assets folder.
5. **Build Executable**: Execute `flutter build windows` to create the Windows executable for the tool.

After successfully building NAER, simply run the executable

## Special thanks to Arthur Heitmann (RaiderB) and all the other Modders who made this possible.
Nier CLI: https://github.com/ArthurHeitmann/nier_cli
