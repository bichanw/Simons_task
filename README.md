# Simons Task

To perform the task:
1. Be sure to have matlab and [psychtoolbox](http://psychtoolbox.org/download) installed on your laptop.
2. Open `main_test_dots.m`, change line 7 to your initial. (E.g. `subjectID = 'BW';`)
3. Run the script. You will be presented with a cloud of dots on each trial. Press left arrow if you think there are more red dots; press right arrow if you think there are more green dots.
4. When finishing, send the files in the `Results` folder to me. They should be `your initial_thresh.mat` and `your initial_1.mat`.

A few things to watch out:
1. For the first few trials, it might take the program longer to draw dots, and please be patient if that is the case. You can try to press the response key more than once if the program is taking a while.
2. The first 3 trials should be relatively easy for you. If they appear to be difficult, change line 8 to be something higher. (E.g. `starting_coherence = 0.7;`)
3. After finishing the experiment, if you're interested, you can run `ana_resp.m` (change its line 3 to your initial) to view your psychometric curve. 
