Note: I try to keep it up to date as recent as possible when i have time, some of this can still be outdated.

It's an enemy randomizer for NieR that modifies the files loaded on game startup without modifying the game's memory. No injection of DLLs is needed.

Enemies are all randomized. Key enemy randomization is not supported, but most enemies can be randomized as well, with extensive randomization for different enemy types. There are even types that normally do not exist, like YoRHa Androids with a Pod.

If you use this mod in a casual livestream or published video, please link to this mod page from a chat command or in the video description if possible. If you use this mod in a unique live event like a showcase or a contest, please credit Vluurie and RaiderB for the mod if it's reasonable to do so. There isn't a team behind this mod. I created it for people to use, so please facilitate that if you manage to create engaging content from it. Thank you!

If you would like to provide feedback, you can join the Discord server at https://discord.gg/djxrH6q7QQ. This mod is under development intermittently, so please check this mod page and the server for updates. I aim to support Item Randomization in the future as well.

Installation

These instructions are a bit long, mainly to cover all the different ways you can use the randomizer with other mods and various modding setups. For the simplest installation process, after selecting the input and output, select nothing and just hit 'Modify.' If you run into issues, check out the Troubleshooting section below.

There are mainly two types of NieR mods: DLL mods and file mods. DLL mods hook into the game when it's running to change it in various ways, similar to what a Cheat Engine script might do. For example, 2B Hook. File mods provide an altered version of the data files used by the game, such as corehap.dat (which contains global game parameters and logic) and mainly the files packaged as CPK extension in the data folder.

File mods like this randomizer do not hook into the game and require you to extract and back up the extracted game files. Since this tool does not use hooks, crashes in the game are close to zero. On the other hand, DLL mods can be installed at any time and used with NAER together.

There are two main ways to set up the randomizer so everyone has the same seed: either everyone separately downloads the randomizer and runs it using the same options (randomize settings) or copies CLI arguments and shares them with others (if the randomization with the CLI does not work, please report this, as it has not been tested extensively), or one person downloads the randomizer, runs it, and distributes a zip file to everyone else.

For other mods, the overall idea is to first randomize normally with specific options, and then install other mods from the Mod Manager. However, this can be chosen as desired.

If there is a new version of NAER available, please first undo every last randomization with the old version and then use the new version.

Regarding bans: using mods will not ban your Steam account in NieR.

Detailed Installation

You need to close the game first before trying to modify the game files. As a result, if you try to do so, NAER knows when the game runs and shows an Information Dialog.

First:

The very first and most important thing is to select the "Input directory," which is the data folder of the game.
Example: ?:\SteamLibrary\steamapps\common\NieRAutomata\data
Cracked versions should also work but are not supported or tested by me. You can try it anyway.

After selecting the input, three scenarios can happen:

    You did not select the correct path; NAER did not find the core game files such as data002.cpk, data0012.cpk, data100.cpk, data006, data016.cpk.
    Solution: Ensure you select the correct path of NieR containing these files and the NieR executable in the parent directory.
    NAER detected that the DLC exists!

    This informs the user that 1. the directory is correct and 2. that the DLC is installed. NAER automatically shows every enemy and .dat folder of the DLC. They are now usable for modification.

    NAER detected that the DLC does not exist or is not installed!

    This informs the user that 1. the directory is still correct and 2. that the DLC is not purchased or installed. NAER removes all enemies and files that are from the DLC. If it was a false flag, you can enable the DLC with a checkbox from the Action Panel.

Second:

The second most important thing is to select the "Output Directory," which is also the data folder (See FIRST).
You might wonder why?
Simple answer: NAER extracts the original files and since the original files are by default read by the game in the data folder, the modified files also need to be outputted to the data folder.
Another question: Why then not simply search and make them automatically selected?

NAER is designed to modify game files and to specify the output directory for the modified files dynamically. This means you can select any folder as output and modify; afterward, you can, for example, share the randomized files with other people.

Now to the scenarios that could happen after selection:

Manage Mod Files dialog appears:
NAER detected files that are by default not in the data directory, which NAER sees as mod files, because NAER creates a pre-randomization time with a range of 60 minutes, NAER knows what files it modified or what files are not modified by NAER.

Now you have the option to add the detected mods to the randomization operation or to say "No, my favorite mod should not be overwritten by NAER" by simply adding the Mod file to the Ignore List, which is saved in NAER's storage.

No scripted mod files detected!:
NAER found no mod files it uses by itself in its operations, so you are safe to proceed. Since appearance mods have no game logic, they are not touched by NAER, unless you are installing mods from the Mod Manager.

At the end, check the checkbox to save the current selected paths for the future, so you don't need to do it a second time.

NOW YOU ARE READY TO MODIFY

You can now begin selecting options and making modifications.

Here are detailed explanations:

LEVEL CHANGE:

All Enemies: Selecting this option modifies the level of every enemy in the chosen categories to the specified level.

All Enemies Without Randomization: When enabled, this option maintains the current status of all enemies, even if some were previously selected for randomization, and only modifies their level.

CATEGORIES:

The game includes four categories where enemies can exist: Quests, Maps, Game Phases, and the Game Core File. You can choose to use all categories (checked by default) or only specific ones. For instance, if you want only 2B's in the phase before the big bang, deselect all other categories except for this one and begin modifications. It will then only include the selected category and exclude the others. If no categories are selected, the default scenario, which includes all categories, is used.

ENEMY STATS:

This functions similarly to categories: only the selected enemy stats files are modified and outputted. Possible scenarios include changing the stats, playing the game, and realizing it is too challenging. You can adjust by selecting a different multiplier. However, if you deselect the multiplier or set it to 0.0, the previous stats modification remains unchanged. To completely restart with different stats or no stat changes, you need to "Undo" the last modification or select a different modifier. (This feature is subject to future changes as seperate modify runner.)

IT'S TIME TO SELECT THE ENEMIES:

Now that you have the option to modify settings (or not), you can choose which enemies you want to face. By default, if no enemies are selected, all enemies are included in the randomization. If only one enemy is selected, all enemies will be transformed into this type (as mentioned in the categories section explanation).

The game features both ground and flying enemies. NAER identifies which enemies belong to each type. Therefore, if you select only flying enemies, you'll notice that all ground enemies remain unchanged. The same holds true if you only select ground enemies; the flyers will not be affected.

But why do we do this?

Answer: Imagine you are randomizing flying enemies in a shooting section and a tank spawns, only to fall endlessly into the void. This would cause a glitch that necessitates a restart of the game or uncontinue. This is why enemies are divided into two separate groups.

Second Question: Why can't I see every enemy for randomization? Where is the DLC President? Where is Engels?

Answer: The game is intentionally designed so that bosses are defeated in scripted scenarios. Consequently, certain enemies, like the President Boss, cannot be killed because they are normally despawned by the game’s script engine. These enemies have infinite health and are invulnerable to damage. Additionally, bosses like Engels are too large to fit in random locations except for specific areas like the desert. Also, some enemies trigger specific behaviors upon spawning; for example, the President's spawn cutscene is hardcoded into the enemy, activating whenever he appears. Unfortunately, not all enemies are currently suitable for randomization. This may change in the future with further modifications to the game's code.

I can assure you that I have thoroughly checked every single enemy that could potentially be included in the modification. Even the red girls are not feasible; enemies that are supposed to fall to the ground when spawned will remain aloft when randomized with a red girl. This results in a soft lock in some scenarios.

You will notice that when animals spawn, they remain on the map even after cutscenes, or they are triggered by the script engine as already defeated. This is standard behavior because animals were never intended to be involved in kill events.

I could delve deeper into each enemy, but let's pause here and continue.

Something special about the randomizer is that it also randomizes the types of enemies. For instance, a machine might use a sword instead of a spear, or it could employ an electroshock attack that normally doesn't exist for that specific enemy. This feature adds a unique and fun twist to the game, even incorporating unusual elements like balloons and buckets as potential enemy types.

IT'S TIME TO PRESS MODIFY.

Now, you can press the 'Modify' button located in the bottom right corner. You will see an overview of all selected settings before you can click "Start Modifying." After pressing this, another dialog—the Backup dialog—will appear.

You now have the option to create a copy of the extracted folders. As a side note, this requires about 9GB of disk space since it copies the files three times. You might wonder why? Here's the breakdown:

If you choose to randomize and change levels, the copied folder named "naer_randomize_and_level" is used.

If only randomization is selected, without level changes, the "naer_randomized" folder is utilized.

If only level modification is chosen, the "naer_onlylevel" folder is used.

Imagine you initially create a single backup folder and randomize. Later, if you decide to change only the level, the level change will apply to the already randomized enemies, copying over the randomized folder with level changes instead of maintaining the original enemies with the level change. This is why three separate backup folders are necessary.

As a result of not needing to extract game files again, the next computation and randomization time is drastically reduced. My randomization time dropped to 8 seconds, and hopefully, yours will too.

When pressed, the tool begins extracting the game files, a demanding computing task. I've developed it to use every single core of the device and compute in parallel, so you will notice significant resource usage during extraction.

After extraction, the tool directly modifies the game files, repacks them, and transfers them to the output directory. A new dialog will then pop up indicating a successful randomization. Now, it's time to press "Play". This will launch the game if the output directory was correctly selected and the game executable is present in the parent directory, allowing you to enjoy your selected modifications.

However, a few issues might arise:

    If you press "Play" and the game is not found, immediately cancel the dialog and start the game manually.
    It's also possible that the process intended to delete the temporary extracted game files inside the input directory hasn't completed. If an error dialog appears, simply press "Retry."
    If the temporary extracted folders remain in the input directory, the game may crash, displaying a white window with an unreadable message.

If the input and output settings cause issues, you can reset the local application state and start over. Before doing a full refresh of the tool, try to press first "Undo" in the bottom middle. Additionally, if you wish to delete the backup, you can do so from the action panel. This allows you to clear any problematic configurations and ensure a fresh setup for your modifications.

Sidenote: If an interruption occurs during the process—whether during extraction, modification, or any other stage—check the data folder (input directory) and manually delete the following folders:

data002.cpk_extracted
data012.cpk_extracted
data100.cpk_extracted
data016.cpk_extracted
data006.cpk_extracted

This cleanup helps prevent any residual issues from incomplete operations.

That's it, atleast for the default features.

EXTRA FEATURES:

Balance Mode:

Enabling Balance Mode significantly reduces the health and defense of particularly strong and defensive enemies. This mode also interacts with the stats multiplier. Use this feature if you feel that certain enemies, especially in the prologue, are excessively resilient. This adjustment ensures that these tough enemies become considerably less formidable. Additionally, Balance Mode is especially useful since special and very defensive enemies are intentionally not spawned multiple times, making each encounter with them much easier.

Save File Editor:

The save file editor automatically checks the "Document" folder in the default Windows location for SlotData.dat files, which store game progress, level, gold, and more. The tool creates a backup folder in the same directory, allowing you to restore any selected or automatically found save files. If no file is automatically detected, you can manually search for them in this path and add them to the list.

Once you've selected the SlotData.dat file you want to modify, the editor will display the player name associated with the save file, as well as the current amount of experience and gold. You can then adjust these values to your preference; changes are made in real time and no additional saving is necessary.

App Theme Modifier:

This feature is straightforward. Change the app theme to suit your preferences. Personally, I prefer the Retro style. ;).

MOD MANAGER:

It's important to note that any modifications made within the Mod Manager using the randomization feature will adhere to the same settings selected on the main page of the tool. Be sure to review and adjust these settings according to your needs before proceeding with installation.

The Mod Manager is a key additional feature of this tool. By default, three mods are available for installation, all of which I developed: the Debug Room Mod, Opera NG+ Mod, and a mod that includes all weapons, pods, and chips in the Resistance Camp shop. You have the flexibility to either randomize and install these mods simultaneously or install them without randomization. Additionally, you can add your own mods to the list. Let’s walk through how you can do this using the Church Mod as an example:

In the bottom right corner, there is a "+" button. Clicking this button opens the metadata form. This form needs to be completed to add a mod to the mod list. It's somewhat similar to how NAMH operates but without individual dialogs for each step and is tailored for handling randomization.

Fields Explained:

    ID: church
    Explanation: This ID is used by NAER to create the folder name where the mod files get copied.

    Name: The NieR Automata Church
    Explanation: This is simply to identify which mod you are adding; you can use any name you choose.

    Version: 1.0.0
    Explanation: The version acts as an identifier if you add the same mod multiple times, but it can be any x.x.x format you wish.

    Author: SadFutago
    Explanation: Add the author's name here. If you encounter issues with the mod, this will help identify who created it, but you can add any name you wish.

    Description:
    Explanation: Provide any description you want for the mod.

    DLC: true
    Explanation: Setting this to true ensures that the mod checks if you have the necessary DLC installed before installation. This is a safeguard to ensure that only mods requiring the DLC can be installed if the DLC is present.

    Extra: Advanced for ignoring enemies from modifying.
    Explanation: This field is for mod developers who have created mods that normally NAER would modify. For instance, if the mod includes unique enemy spawn actions that should not be altered, the mod author can list the IDs here. For example, adding the spawn action for the Zero Shade Boss from the Church Mod (EnemySetAction "0xc22a1de3") will instruct NAER to ignore this ID. However, this feature is rarely used, so it might not be necessary to add anything here for now.

Image: You can enhance the visual appeal of your mod in the list by adding an image or a GIF. If no image is provided, a default modification icon is used instead.

Add Mod Folder: First, ensure you have extracted the mod you want to add. Select the mod folder you wish to include. The tool will then scan through the folder, identify any valid NieR mod files, create relative paths, and creates a list for you to verify that all mod files are present.

Saving Metadata: Once you've filled out the metadata form, save it, and the mod should be ready for randomization, installation, or simply to be listed in the mod manager. If any fields are left incomplete, an error message will appear, prompting you to fill out all required fields.

You can now attempt to install the mod. After installation, if not already activated, consider enabling the mod verifier. This feature checks the output directory against the saved mod files. If any mods are missing, it will delete the affected files from the output and display a dialog indicating which mods were missing or affected.

If you decide you don’t need a mod in the mod list and simply want to randomize it, you can drag the mod folder into the drag-and-drop field at the bottom right. Doing this will randomize the folder’s files and place them in the output path. However, note that these files are not verified to ensure they were installed correctly, nor are they added to the tool’s ignore list. As a result, they may be overwritten during the next modification if they involve the same game file.

And that’s it—
surprisingly straightforward
, right? (Just kidding, by the way). I hope you enjoy using this free tool. If I forgot anything, it might just be because I've developed too much! Have fun exploring and customizing with it.
####################################################