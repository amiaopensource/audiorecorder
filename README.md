# audiorecorder

## A work in progress to create a free tool for the calibration and recording of analog audio signals

Current Usage: [-p] passthrough mode, [-e] edit config

Must have FFmpeg/FFplay and Pashua installed.

## Current quirks:

1. There is a small hickup when the visualization window opens. This means you must wait until the window opens to press play on source material.
2. Don't use your built in microphone as a device without using headphones or muting your speakers othewise you will start a feedback loop that sounds like you are bringing about armageddon.
3. Tested on 2014 iMac and 2013 Macbook Air.  There appeared to be some dropped samples on the Air.  No problems were detected on recordings made via the iMac.

## Current Window
Includes peak meters, spectrum information (lines represent 1,5,10,15,20 kHz), audio phase, spectrogram and a graph representing peak levels (colored area represents -5dB to 0 dB).

![Window](https://github.com/amiaopensource/audiorecorder/blob/master/current_interface.gif)

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />The Audio Recorder script and all associated documentation is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
