# Violin Bow Path
## Introduction
When play super fast notes on violin, the path of bow become exteremly important to get everything work.

This algorithm could calculate the violin bow path with custom given condition.
### Deficiency
This algorithm is not optimized. It can roughly show one solution with strict condition. However, this solution is pretty much near the optimized solution ignoring some low frequency movement, thus it still could help me to solve violin problem.
## Details
### Custom Data Format
It is a matrix with given attributes:
* `n`: (any format ~ string) music note indicator, you can put any string that indicate your note that help you understand.
* `t`: (real number) time length of music note.
* `l`: (real number range from 0 to 1) the starting position of bow at given time -- 0 is root of bow, 1 is the tip of bow (this value could be missing if the length of bow passing is unknown; however you should make sure the first and last value is given).
* `s`: (integer from 1 to **x**:`number of strings`; count from right to left) the string index -- `vioin` 4: G, 3: D, 2: A, 1: E; other string instruments are supported only by changing the parameter `stringname` (violin:`stringname={"G","D","A","E"}`; examples are in the comment of code).
#### Notice
* Attribute `n` is not required; any order of these attributes is allowed only if `t`, `l` and `s` is given (other attributes will be ignored).
* You should give at least 3 notes to calculate.
* You should give one more note at the end, since the path of last note will not show up.

See examples in demo `.csv`.
### Plots
#### Bow Path
* Color of path represent the speed of bow (red: fast, blue: slow).
* Indicators near the path (red: bow from root to tip [left -> right], blue: reverse direction; Format: `[time]:[indicator string]`).
#### Other Plot
Other Plot on the bottom represent the angle and position of bow changed by time.
## Appendix
### Files
* Demos are in demo folder.
* Source files are in src folder.
### Usage
Go to folder and open file `./src/bow path.nb`. 
* Run the first line to initialize the packages. 
* Run the demo (or see the demo file) to check it out. 
* Run your test case by providing the `.csv` file, and put the url in to the text area in UI, then put your cursor to where you wish to see the result, then click `Calculate` button to see it, OR you can click `Export` button to export files, the files are in the location shown below at the result.
### Algorithms
Algorithm is written in the `./src/bowPath.wl` comments. Read it and you can get my idea.
## Demos
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/demo%20score.png "Demo Score")
### Demo
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/demo.png "Demo")
### Demo2
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/demo2.png "Demo2")
### Swipe
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/swipe.png "Swipe")
[Video of Swipe](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/swipe.mp4 "Swipe Video")
### Short Swipe
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/shortswipe.png "Short Swipe")
[Video of Short Swipe](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/shortswipe.mp4 "Short Swipe Video")
### Reverse Swipe
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/reverseswipe.png "Reverse Swipe")
[Video of Reverse Swipe](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/reverseswipe.mp4 "Reverse Swipe Video")
### Wave Swipe
![alt text](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/waveswipe.png "Wave Swipe")
[Video of Wave Swipe](https://github.com/RobertBoganKang/Violin_Bow_Path/blob/master/demo/waveswipe.mp4 "Wave Swipe Video")
