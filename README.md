# NAER
NieR:Automata Enemy Randomizer Tool

This Tool randomizes the Enemys in NieR:Automata.

How to install/use?

1. Download the repository.
2. Download the Dart SDK or Flutter https://docs.flutter.dev/get-started/install , since this tool was writen in Dart and uses the NieR CLI: https://github.com/ArthurHeitmann/nier_cli
3. Download and Install Python since the GUI was writen in Python: https://www.python.org/downloads/
4. Now u need to update the dependencies for the Dart files, open a Terminal in the repository Folder and use: flutter pub get
5. If u got an issue that a python dependency is outdated or missing, open Windows Powershell and use: pip freeze | %{$_.split('==')[0]} | %{pip install --upgrade $_}
6. Start the NierAutomataEnemyRandomizer.py in  the lib folder.
7. Done

How to use?

1. Choose ur Input Folder, this Folder needs to have .cpk files from NieR:Automata (best practice is to copy the 3 .cpk's needed data002.cpk, data012.cpk and data100.cpk into a single Folder.
2. Choose ur Output Directory, this Folder needs to be the data folder of NieR:Automata.

   Selecting an Enemy means that all enemies in NieR:Automata will be changed to this selected Enemy.
   If u select more than one Enemy, this Enemys will be used to change all Enemies randomly to the selected Enemies.
   The Tool knows what are Fly and what are Ground Enemies. It will only change Fly enemies with Fly enemies, same with Ground Enemies.

   If u select nothing and directly click on "Start Randomizing", the tool uses every Enemy in the List for Randomizing.

   U can also say to only randomize Quests, Maps or the Game Phases.


What the Tool not does.

The Tool does not change enemies that have an alias with value. Alias tags can have hardcoded scripting specified for the Enemy. Changing the Enemy breaks the Script Logic of some that got Alias Values.
The Tool does not change Bosses so u can completly normally play the Game but still having different Enemies. It uses a Group Called "Delete" in sorted_enemy.dart. This Enemies will be ignored during Randomization.

Note:

This Tool with the Enemies was tested mostly on start of the Game and not on every scenario, of there are issues feel free to report in the NieR:automata Modding Discord.

