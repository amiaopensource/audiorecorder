# audiorecorder

## A work in progress to create a free tool for the calibration and recording of analog audio signals

Current Usage: [-p] passthrough mode, [-e] edit config

Must have FFmpeg/FFplay and Pashua installed.

## Current quirks:

1. There is a small hickup when the visualization window opens. This means you must wait until the window opens to press play on source material.
2. Tested on 2014 iMac and 2013 Macbook Air.  There appeared to be some dropped samples on the Air.  No problems were detected on recordings made via the iMac.

## Current Window
Includes peak meters, spectrum information (lines represent 1,5,10,15,10 kHz), audio phase, spectrogram and a graph representing peak levels (colored area starts at -5 dB).

![Window](https://github.com/amiaopensource/audiorecorder/blob/master/current_interface.gif)
