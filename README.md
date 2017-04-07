# audiorecorder

## A work in progress to create a free tool for the calibration and recording of analog audio signals

Can be installed via Homebrew: `brew tap amiaopensource/amiaos` and `brew install audiorecorder`.

Current Usage: [-p] passthrough mode, [-e] edit config, [-m] edit metadata for BWF insertion

# Huge thanks to all contributors!
## Contributors to date:
privatezero (Andrew Weaver), retokromer (Reto Kromer), dericed (Dave Rice)

Special thanks to Matt Boyd at the University of Washington for extensive testing assistance!

## Current quirks:

1. There is a small hiccup when the visualization window opens. This means you must wait until the window opens to press play on source material.
2. Don't use your built in microphone as a device without using headphones or muting your speakers othewise you will start a feedback loop that sounds like you are bringing about armageddon.
3. The signal information in the CLI by sox is for the stream that is being piped into ffplay, so things like peaked audio warnings and levels will be accurate, but the displayed sample rate and depth are not the ones being used in the recorded file.
4. The audiostats that are provided post digitization appear to not reflect actual values sometimes (especially depending on device used to digitize). For the time being they should be taken with a grain of salt.

## Current Window
Includes peak meters, spectrum information (lines represent 1, 5, 10, 15, 20 kHz), audio phase, spectrogram and a graph representing peak levels (colored area represents -5 dB to 0 dB).

![Window](https://github.com/amiaopensource/audiorecorder/blob/master/current_interface.gif)

## License
<a rel="license" href="https://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png"></a><br>The audiorecorder script and all associated documentation is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.

BWF Metaedit

>This code was created in 2010 for the Library of Congress and the other federal government agencies participating in the Federal Agencies Digitization Guidelines Initiative and it is in the public domain.

Detailed BWF Metaedit License available [here](https://mediaarea.net/BWFMetaEdit/License).
