// arg_descriptions.dart

// Concise descriptions for each argument used in the batch command,
// optimized for clarity and command prompt readability.

const List<String> argDescriptions = [
  // Argument 1: Input Directory
  'Input directory for .cpk or .dat files. Any folder with these files can be used.',

  // Argument 2: Output Parameter
  'Defines the type of output for the process.',

  // Argument 3: Output Directory
  'Destination for modified .dat files, not limited to the game folder.',

  // Argument 4: Enemy Selection
  'Select enemies from sorted_enemy list. Creates a temporary file for random looping.',

  // Argument 5: Bosses Parameter
  'Selects specific bosses for modifications.',

  // Argument 6: Selected Bosses
  'Modify ExpInfo.csv for chosen bosses with bossStats argument.',

  // Argument 7: Boss Stats Parameter
  'Multiplier for boss stats in ExpInfo.csv, max limit is 5.',

  // Argument 8: ExpInfo Multiplier
  'Sets multiplier for ExpInfo.csv, max 5. High values may cause unbeatable enemies.',

  // Argument 9: Enemy Level Modification
  'Sets enemy levels post-modification. Options: all, only bosses, sorted enemies.',

  // Argument 10: Category Parameter --allquests
  '--allquests: Includes all quest (.dat) files, skips if not used.',

  // Argument 11: Category Parameter --allphases
  '--allphases: Includes all phase files (p100, etc.), skips if not used.',

  // Argument 12: Category Parameter --allmaps
  '--allmaps: Includes all map (.dat) files, skips if not used.',

  // Argument 13: Category Parameter --ignoredlc
  '--ignoredlc: Ignores files in data100.cpk.',

  // Argument 14: Level Change Option Parameter
  '--category options: default (no change), onlybosses, onlyselectedenemies, allenemies.',
];

String asciiArt2B = '''
... ⠄⠄⠄⠄⢠⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿⣿⣿⣿⣿⣯⢻⣿⣿⣿⣿⣆⠄⠄⠄
⠄⠄⣼⢀⣿⣿⣿⣿⣏⡏⠄⠹⣿⣿⣿⣿⣿⣿⣿⣿⣧⢻⣿⣿⣿⣿⡆⠄⠄
⠄⠄⡟⣼⣿⣿⣿⣿⣿⠄⠄⠄⠈⠻⣿⣿⣿⣿⣿⣿⣿⣇⢻⣿⣿⣿⣿⠄⠄
⠄⢰⠃⣿⣿⠿⣿⣿⣿⠄⠄⠄⠄⠄⠄⠙⠿⣿⣿⣿⣿⣿⠄⢿⣿⣿⣿⡄⠄
⠄⢸⢠⣿⣿⣧⡙⣿⣿⡆⠄⠄⠄⠄⠄⠄⠄⠈⠛⢿⣿⣿⡇⠸⣿⡿⣸⡇⠄
⠄⠈⡆⣿⣿⣿⣿⣦⡙⠳⠄⠄⠄⠄⠄⠄⢀⣠⣤⣀⣈⠙⠃⠄⠿⢇⣿⡇⠄
⠄⠄⡇⢿⣿⣿⣿⣿⡇⠄⠄⠄⠄⠄⣠⣶⣿⣿⣿⣿⣿⣿⣷⣆⡀⣼⣿⡇⠄
⠄⠄⢹⡘⣿⣿⣿⢿⣷⡀⠄⢀⣴⣾⣟⠉⠉⠉⠉⣽⣿⣿⣿⣿⠇⢹⣿⠃⠄
⠄⠄⠄⢷⡘⢿⣿⣎⢻⣷⠰⣿⣿⣿⣿⣦⣀⣀⣴⣿⣿⣿⠟⢫⡾⢸⡟⠄.
⠄⠄⠄⠄⠻⣦⡙⠿⣧⠙⢷⠙⠻⠿⢿⡿⠿⠿⠛⠋⠉⠄⠂⠘⠁⠞⠄⠄⠄
⠄⠄⠄⠄⠄⠈⠙⠑⣠⣤⣴⡖⠄⠿⣋⣉⣉⡁⠄⢾⣦⠄⠄⠄⠄⠄⠄⠄⠄ ...
''';

String initNaerArt = '''
@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo     Automata Command Protocol
echo ========================================
call :typingEffect "System Check Initiated..."
call :typingEffect "Memory Unit...........[OK]"
call :typingEffect "Tactics Log...........[OK]"
call :typingEffect "Geographic Data.......[LOADED]"
call :typingEffect "Vitals................[GREEN]"
call :typingEffect "Remaining MP..........[100%]"
call :typingEffect "Black Box Temp........[NORMAL]"
call :typingEffect "Internal Pressure.....[NORMAL]"
call :typingEffect "IFF...................[ACTIVATED]"
call :typingEffect "FCS...................[ACTIVATED]"
call :typingEffect "Pod Connection........[ESTABLISHED]"
call :typingEffect "DBU Setup.............[LAUNCHED]"
call :typingEffect "Inertia Control.......[ONLINE]"
call :typingEffect "Env. Sensors..........[ONLINE]"
call :typingEffect "Equipment Auth........[VERIFIED]"
call :typingEffect "Status................[ALL GREEN]"
call :typingEffect "Combat Prep...........[COMPLETE]"
echo ========================================
call :typingEffect "...."
echo ".-----------------. .----------------.  .----------------.  .----------------. "
echo "| .--------------. || .--------------. || .--------------. || .--------------. |"
echo "| | ____  _____  | || |      __      | || |  _________   | || |  _______     | |"
echo "| ||_   ||_   _| | || |     /  |     | || | |_   ___  |  | || | |_   __ |    | |"
echo "| |  |   \ | |   | || |    / /| |    | || |   | |_  |_|  | || |   | |__) |   | |"
echo "| |  | || |\ |   | || |   / ____ |   | || |   |  _|  _   | || |   |  __ /    | |"
echo "| | _| |_\   |_  | || | _/ /    | |_ | || |  _| |___/ |  | || |  _| |  | |_  | |"
echo "| ||_____|\____| | || ||____|  |____|| || | |_________|  | || | |____| |___| | |"
echo "| |              | || |              | || |              | || |              | |"
echo "| '--------------' || '--------------' || '--------------' || '--------------' |"
echo  "'----------------'  '----------------'  '----------------'  '----------------' "
echo Protocol completed. Stand by...
call :typingEffect "...."
goto endScript

:typingEffect
setlocal enabledelayedexpansion
set "line=%~1"
set "length=0"

:: Calculate the length of the string
:findLength
if not "!line:~%length%,1!"=="" (
    set /a "length+=1"
    goto findLength
)

:: Print each character with a delay
for /L %%i in (0,1,%length%-1) do (
    set "char=!line:~%%i,1!"
    if "!char!"==" " set "char=_"
    <nul set /p=!char!
    ping -n 1 127.0.0.1 > nul
)
echo.
endlocal
goto :eof

:endScript

''';

String asciiStart = '''"...."
echo "8888888b.                   .d8888b."
echo "888   Y88b                 d88P  Y88b "
echo "888    888                      .d88P "
echo "888   d88P 888 888  888 888  .d88P"  
echo "8888888P"  888  888 888 88b  888"    
echo "888 T88b   888  888 888  888  888 "    
echo "888  T88b  Y88b 888 888  888       "   
echo "888   T88b  "Y88888 888  888  888  "    
echo "...."                                                               
''';
