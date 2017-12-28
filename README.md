# Violin Bow Path
## Introduction
When play super fast notes on violin, the path of bow become exteremly important to get everything work.

This algorithm could calculate the violin bow path with custom given condition.
### Deficiency
This algorithm is not optimized. It can roughly show one solution with strict condition. However, this solution is pretty much near the optimized solution ignoring some low frequency movement, thus it still could help me to solve violin problem.
## Details
### Custom Data Form
It is a matrix with given attributes:
* `n`: music note indicator, you can put any string that indicate your note that help you understand.
* `t`: time length of music note.
* `l`: the starting position of bow at given time -- 0 is root of bow, 1 is the tip of bow.
* `s`: the string index -- 4: G, 3: D, 2: A, 1: E.

Attribute `n` is not required; any order of these attributes is allowed only if `t`, `l` and `s` is given.
### Plots
#### Bow Path
* Color of path represent the speed of bow (red: fast, blue: slow).
* Indicators near the path (red: bow from bottom to top, blue: reverse direction; Format: `[time]:[indicator string]`).
#### Other Plot
Other Plot on the bottom represent the angle and position of bow changed by time.
## Files
Demos are in demo folder.
Source files are in src folder.
## Demos
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/demo%20score.png "Demo Score")
### Demo
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/demo.png "Demo")
### Demo2
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/demo2.png "Demo")
### Swipe
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/swipe.png "Swipe")
### Short Swipe
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/shortswipe.png "Short Swipe")
### Reverse Swipe
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/reverseswipe.png "Reverse Swipe")
### Wave Swipe
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/waveswipe.png "Wave Swipe")
