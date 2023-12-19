# NAER - N:A Enemy Randomizer Tool

## Overview

NAER, the ultimate enemy randomization tool designed to enhance your gaming experience in the critically acclaimed action RPG. With NAER, you have the power to breathe new life into the game by introducing a variety of randomization options. Whether you seek to intensify the challenge or simply wish to explore the game from a fresh perspective, NAER is here to cater to your desires.

![grafik](https://github.com/Vluurie/NAER/assets/145698737/daa0572f-87c1-421d-986c-799dc4403c15)


## Features

- **Enemy Randomization**: Shake things up by randomizing enemies.
- **Level Modification**: Tailor the game's difficulty by adjusting the levels of bosses, selected enemies, or all enemies.
- **Selective Randomization**: Have full control with the ability to choose specific categories for randomization, including all maps, all phases, all quests, and an option to exclude DLC content.
- **Custom Enemy Selection**: Craft a personalized experience by handpicking the enemies you wish to encounter. You can even select just one enemy that replaces all other enemies in the game to this selected one.
- **Undo Functionality**: Revert back to the default setting when the Tool is still open.
- **User-Interface**: Enjoy a straightforward and intuitive user interface for a hassle-free configuration process.

  Note: Bosses and Alias Tagged Enemies who are needed for the Game Logic are not altered. So u can play normally the story.
  For now it was tested mostly for the complete prologue.
  Big enemies in small places can bug, this is totally normal.
  Sometimes some enemies that spawn from the top are staying on the top, simply shoot them down.
  If u found anything really annoying or u cannot continue the game because of some issue that is from an enemy. Feel free to join the Modding Discord and try to ask for help.

## Installation for Users

Download the latest executable, extract the .zip folder and run the .exe in the folder.

  1. Select your Input directory: Needs to be one with `.cpk` or `.dat` files. But recommended is your game data directory
  2. Select your Output directory: The modified files that get outputed. Recommended also your game data directory
     N:A data directory: `?:\SteamLibrary\steamapps\common\NieRAutomata\data`
  4. Simply select what you want to modify.
  5. Press 'Modify'.
  6. Watch out the log output for information and process.
  7. For undo, do not close the Tool after modifying. If u still have the tool open and want to undo, simply press 'Undo'.
  8. Also more information are hard coded in the tool.

## Installation for Developers

To install and build the NAER tool, follow these steps:

1. **Download Repository**: Clone or download the NAER repository from GitHub.
2. **Install Flutter Dart CLI**: Download and install the Flutter Dart CLI, which will help manage dependencies and build the project.
3. **Fetch Dependencies**: Navigate to the project directory and run `flutter pub get` to fetch the latest dependencies.
4. **Compile the CLI Tool**: Utilize `dart compile exe bin\nier_cli.dart` to compile the modified nier_cli tool.
5. **Build Executable**: Execute `flutter build windows` to create the Windows executable for the tool.

After successfully installing NAER, simply run the executable

## Special thanks to Arthur Heitmann (RaiderB) and all the other Modders who made this possible.
Nier CLI: https://github.com/ArthurHeitmann/nier_cli
