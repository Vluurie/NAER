# NAER - NieR:Automata Enemy Randomizer Tool

## Overview

The NAER is a tool designed to randomize enemy placements in NieR:Automata, offering a fresh and unpredictable gameplay experience. It is developed using Dart and Python and utilizes the [NieR CLI](https://github.com/ArthurHeitmann/nier_cli) by Arthur Heitmann, which has been instrumental in the development of this tool.


## Installation and Setup

### Prerequisites
1. **Dart SDK or Flutter**: Required for Dart-based operations. Install from [Flutter Installation Guide](https://docs.flutter.dev/get-started/install).
2. **Python**: Necessary for the GUI component. Download and install from [Python Official Downloads](https://www.python.org/downloads/).

### Steps
1. **Clone the Repository**: Download the NAER tool repository.
2. **Dart Dependencies**: In the repository directory, open a terminal and execute:
   
   ```flutter pub get```
   
4. **Python Dependencies**: If any Python dependencies are outdated or missing, run the following in Windows Powershell:
   
   ```pip freeze | %{$.split('==')[0]} | %{pip install --upgrade $}```

4. **Launch the Tool**: Start `NierAutomataEnemyRandomizer.py` located in the lib folder.

## Usage Instructions

### Preparing the Tool
1. **Input Folder**: Select a folder containing NieR:Automata `.cpk` files (e.g., `data002.cpk`, `data012.cpk`, and `data100.cpk`).
2. **Output Directory**:
Select the `data` folder within your NieR:Automata installation as the output directory.
**Note**:
This tool is adept at managing existing `.dat` mods in this directory. Any detected mods will be automatically excluded from the randomization process to prevent conflicts. Additionally, the tool generates `.json` files, capturing pre-randomization and most recent usage timestamps. This feature helps track when the last randomization occurred, ensuring a smoother user experience.


### Randomization Options
- **Single Enemy Selection**: Replaces all enemies with the selected one.
- **Multiple Enemies Selection**: Randomly swaps enemies using the selected types.
- **Enemy Types**: The tool distinguishes between flying and ground enemies for appropriate replacements.
- **Full Randomization**: With no specific selections, the tool randomizes using all available enemies.
- **Selective Randomization**: Options to randomize specific aspects such as quests, maps, or game phases.

## Limitations

- **Alias-Tagged Enemies**: The tool doesn't change enemies with alias tags having specific values, as it might break the script logic.
- **Bosses**: Boss enemies are not altered, allowing normal game progression. These are listed under the "Delete" group in `sorted_enemy.dart` and are excluded from randomization.

## Note

- **Testing**: This tool has been primarily tested in early game scenarios. For any issues, report them in the NieR:Automata Modding Discord.

## Special Thanks

I would like to extend my sincere thanks to Arthur Heitmann for developing the NieR CLI, and for his valuable assistance in resolving some of the issues I faced during the development of NAER. His contributions have been greatly appreciated.

---


