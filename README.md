# AppleScript Libraries

Script libraries I've developed over the years others may find useful as well.

- Recall these files must be stored in ``~/Library/Script Libraries``

____
## Kevin's Library
- Collection of handlers useful for everyday scripting, includes text manipulation, file handling, Safari control, list manipulation and others. Shout out to Mark Aldritt (https://github.com/alldritt) for many of his great handlers in here.
____
## Alfred Library
- Handlers for creating new Workflow script objects (mimics classes and constructors from OOP) to be used for developing Alfred 3 workflows. Shout out to Ursan Razvan for developing the original version for use with Alfred 2, I made some adjustments for Alfred 3 and added some extra useful handlers.
____
## Script Debugger Library
- This library provides several useful editor functions for ScriptDebugger.

### Line Actions:
- Select Line
- Copy Line
- Cut Line
- Delete Line

<div align="center">
  <img src="./imgs/selectCutCopyLine.gif" alt="selectCutCopyLine" height="250">
</div>


- Move Line Up
- Move Line Down

<div align="center">
  <img src="./imgs/moveLineUpDown.gif" alt="moveLineUpDown" height="250">
</div>



### Word Actions:
- Select Word Under Cursor
- Copy Word Under Cursor
- Cut Word Under Cursor
- Delete Word Under Cursor

<div align="center">
  <img src="./imgs/selectCutCopyWord.gif" alt="selectCutCopyWord" height="250">
</div>


### camelHumps Word Actions
- Move Cursor Through camelHumps words
- Select Words in camelHumps words
- Delete Words in camelHumps words

<div align="center">
  <img src="./imgs/selectCopyDeleteCamelHumps.gif" alt="selectCopyDeleteCamelHumps" height="250">
</div>



- Personally I use Keyboard Maestro to execute these scripts as in the example below.

<div align="center">
  <img src="./imgs/macro.png" alt="macro" height="250">
</div>
