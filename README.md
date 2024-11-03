# NAER - Enemy Randomizer Tool for NieR:Automata - WINDOWS ONLY

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

Download the latest installer and install or get the portable zip folder, extract the .zip folder and run the .exe in the folder.

Full Guide: [NAER GUIDE](https://github.com/Vluurie/NAER/blob/main/guide.md)



# NAER Tool - Developer Installation Guide

This guide provides the steps required to build and run the NAER tool for development purposes.

## Prerequisites

- **Flutter and Dart**: Make sure you have Flutter and Dart installed. [Download Flutter and Dart](https://flutter.dev/docs/get-started/install).
- **Rust**: Required for compiling the DAT extraction library. [Download and Install Rust](https://www.rust-lang.org/tools/install).

## Installation Steps

1. **Clone the Repository**
   - Clone or download the NAER repository from GitHub:
     ```bash
     git clone https://github.com/Vluurie/NAER.git
     ```
   - Navigate to the project directory:
     ```bash
     cd NAER
     ```

2. **Install Flutter Dependencies**
   - Fetch the required Flutter dependencies by running:
     ```bash
     flutter pub get
     ```

3. **Download Assets**
   - From the latest NAER release on GitHub, download the `assets.zip` file.
   - Extract the contents and place the missing folders/files `nier_image_folders` into the `assets` folder within the project directory.

6. **Build the NAER Tool**
   - Return to the NAER project directory and use Flutter to compile the tool:
       ```bash
       flutter build windows --release
       ```
  
5. **Compile the DAT Extraction DLL**
   - NAER requires a custom DLL for extracting DAT files, which is implemented in Rust by me:
     - Clone the DAT extraction library from GitHub:
       ```bash
       git clone https://github.com/Vluurie/nier_extract_dat_rust_dll.git
       cd nier_extract_dat_rust_dll
       ```
     - Fetch dependencies and build the library with:
       ```bash
       cargo build --release
       ```
     - After building, locate the compiled DLL `extract_dat_files.dll` in the `target/release` directory, navigate to the build directory of NAER and place it in the same folder as the compiled NAER executable.

7. **Run the Executable**
   - Now run the tool!
     
8. **Mod Manager mod files**
   - Get the mods for the mod manager from: [NAER Mod Package](https://www.nexusmods.com/nierautomata/mods/600)
   - Drag and drop the .zip file into the Mod Manager field and they will get loaded for usage!.

---

### Notes

- Ensure all DLLs and assets are correctly placed as specified.


## Special thanks to Arthur Heitmann (RaiderB) and all the other Modders who made this possible.
Nier CLI: https://github.com/ArthurHeitmann/nier_cli
