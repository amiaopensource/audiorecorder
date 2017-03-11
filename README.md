# audiorecorder

## A work in progress to create a free tool for the calibration and recording of analog audio signals

Can be installed via Homebrew: `brew tap amiaopensource/amiaos` and `brew install audiorecorder`.

Current Usage: [-p] passthrough mode, [-e] edit config, [-m] edit metadata for BWF insertion

**2017-03-11 UPDATE:** Major redesign of post-digitization functions and GUI. Audiorecorder now supports trimming of start and end of files via manual specification as well as auto-trim of silence at the start of files. Preview and post-digitization GUI now incorporate waveforms of the digitized audio to aid in trimming. All testing has been negative for dropped samples.

**2017-03-04 UPDATE:** For the new release changes have been made to streamline the way audiorecorder handles input channels. This will prevent it from being overwhelmed by A/D converters that output many empty tracks along with the desired tracks (such as the Apogee Symphony). In two 55 minute tests and one 30 minute no drops or problems were detected via Wavelab analysis. Due to more efficient management of data the current buffering now has increased the latency for mono captures. A next step will be to see how much buffering can be safely lowered.

**2017-02-24 UPDATE:** Changes appear to have been successful for adapting audiorecorder to macOS 10.12.03. In testing it was discovered that audiorecorder has issues with A/D converters that have a large number of output tracks (such as sixteen as opposed to two). Current audiorecorder head appears to be stable for two track A/D converters and testing is underway to expand its ability to deal with larger multi-track converters.

**2017-02-23 UPDATE:** Due to some issues that were reported with macOS 10.12.03, some changes to buffering have been made and are currently being tested.

**2017-02-15 UPDATE:** Ability to select which channel to record has been added to the GUI. This option was tested with a 25 minute ingest on 2013 Macbook Air with no dropped samples detected audibly or vie Wavelab global analysis. Some glitches with file trimming were resolved.

**2017-01-20 UPDATE:** Initial post digitization functions have been included via a basic GUI. These include ability to preview file with and without silence trimming, and an option to create a silence trimmed version of file. The spectrograph has also been changed to scroll for easier viewability. Further testing has not detected any dropped samples either audibly or via Wavelab global analysis. 

**2016-12-22 UPDATE:** Current build was tested with a 40 minute transfer on the 2013 Macbook Air with no dropped samples detected either audibly or via Wavelab's global analysis tool. Testing continues...

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
