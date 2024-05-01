# AC7_Autosplit

This repository contains a basic autosplitter for the game 'Ace Combat 7'.
The autosplitter currently supports automatic tracking of ingame time as well as splits on mission fadeout.
An other feature already implemented is the ability to do subsplits for the destruction missions in the main campaign (Long Day and Fleet Destruction) on their respective Ace and S-Rank score requirements.

For usage in a full game run just start your timing normally (on difficulty select) with your split button, thereafter you should no longer need to worry about the splits.

For individual level usage just start the mission as you normally would - the autosplitter will automatically detect the mission start and begin to start the timing.

This repository also contains sample layout and split files for reference.

## Setup
To be able to use the autosplitter you first have to complete the basic setup for LiveSplit (https://livesplit.org/introduction/).
Once you have a layout and splits set up, navigate to the "Edit Splits..." option (Rightclicking the livesplit window, first option) and make sure `Ace Combat 7: Skies Unknown` is selected for "Game Name".
If this is the case, the Autosplit section should appear, looking somewhat like this:

![image](https://github.com/CptPie/AC7_Autosplit/assets/23438606/55335c7e-7017-4c18-aae9-72ef92cc2f62)

To enable autosplitting just click on the "Activate" button. Once you did that, the Settings button is enabled, by pressing it you can configure the autosplitter.

The settings should be self explanatory, the version option is just there to display the currently used version and does not change the behaviour of the splitter.

Once you have configured the autosplitter to your needs you are good to go for your first run with it.

## Usage
The rules for a full game run mandate that the RTA timing shall start on the last input before the first cutscene (the difficulty select). As the autosplitter cannot detect this, the timing has to be started manually. A neat trick here is to bind LiveSplit's "Start/Split" key to either Return or Space, as those keys also act as input for the difficulty select. (If you didn't already it might be a good idea to also enable global hotkeys for this purpose.)

Once the timing is started the autosplitter automatically keeps track of the ingame time (by reading the game state) and will split on mission transitions. 

## Known issues
Due to an unknown issue, the autosplitter is unable to detect the mission transitions for certain missions (Mission 4 and Mission 15), hence the runner has to split those missions manually.
