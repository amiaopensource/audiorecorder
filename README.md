# audiorecorder

####  A free tool for the calibration and recording of analog audio signals

## Development information:
For updates and history of development please see [this page](https://github.com/amiaopensource/audiorecorder/blob/master/history.md).

## Installation:

audiorecorder can be installed via [homebrew](https://brew.sh/) on macOS and [linuxbrew](http://linuxbrew.sh/) on Linux.

__MacOS Installation__:
Audiorecorder can be installed via Homebrew with the following commands:

`brew tap amiaopensource/amiaos`

`brew install audiorecorder`

__Linux Installation__ (Tested in Ubuntu 16.04)

The following division of commands seeks to install up-to-date versions of audiorecorder dependencies while avoiding conflicts.

__Standard package manager commands__

`sudo apt-get install sox`

`sudo apt-get install libsdl2-2.0`

Install current [MPV](https://mpv.io/installation/) ppa, then `sudo apt-get install mpv`

__linuxbrew commands__

`brew install dialog`

If FFmpeg has already been installed with these options then skip next step. 

`brew install ffmpeg --with-freetype --with-sdl2`

sdl2 is necessary to build FFmpeg with FFplay, but removing it after build will avoid conflicts between other installations of sdl2.

`brew uninstall --ignore-dependencies sdl2`

`brew install --ignore-dependencies audiorecorder`


## Usage:
Usage: [-p] passthrough mode, [-e] edit config, [-m] edit metadata for BWF insertion

#### Initial setup:
To set up audiorecorder, first run the command `audiorecorder -e`. This will open an interface where settings such as recording bit depth and sample rate can be selected. This is also where the option to embed BEXT metadata can be selected.

To set the metadata that will be embedded in the BEXT chunk (if activated in the configuration menu) run the command `audiorecorder -m`. This will open an interface where the desired values can be entered.

#### Explanation of Interface:
1: Peak volume meters (dB)

2: Audio spectrum - lines (from left) represent 1, 5, 10, 15, 20kHz respectively

3: Recording time

4: Spectrogram

5: Audio vecorscope

6: Graph of peak volume values (dB) from -30dB to 0dB. Colored area represents -5dB to 0dB.

<img src="https://raw.githubusercontent.com/amiaopensource/audiorecorder/master/numbered_interface.png" alt="audiorecorder interface" height="350" width="350">

#### Preview:
Running `audiorecorder -p` will open the preview window. This window can be closed with the escape key. This allows you to check your settings and playback machine calibration using the audiorecorder interface without creating a file. It is recommended to use this mode before every recording. Once you are satisfied that everything is calibrated appropriately, move on to record mode.

#### Record:
Running the command `audiorecorder` will start record mode.  You will be prompted for the name of the file created. __Wait until the audiorecorder interface opens__, and then press play on your playback machine. During recording do not resize the window, as this can cause problems with the audio buffer. To stop recording press the escape key.

Once recording is complete, audiorecorder will process the file, and then an interface will open showing the waveform of the recorded file, as well as giving options to 'preview' and 'trim' the file.

Press 'Preview' to hear the file you recorded. To trim file, enter the amount (in seconds) to trim from the start and end of the file and press 'Trim'. If 'Start Trim' is left blank, auto-trim will be applied to start of file. If no trim at start is desired enter '0'. After trimming, a preview window will open for your new file. Trim can be run as many times as is necessary. Once you are done, press 'Finish' to finalize and quit. It is at this point that BEXT metadata will be embedded if that option has been selected.

## Huge thanks to all contributors to audiorecorder!
#### Contributors to date:
privatezero (Andrew Weaver), retokromer (Reto Kromer), dericed (Dave Rice)

Special thanks to Matt Boyd at the University of Washington for extensive testing assistance!

## License

The audiorecorder script is covered under a [BSD 3-clause license](https://github.com/amiaopensource/audiorecorder/blob/master/LICENSE.txt)

<a rel="license" href="https://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png"></a><br>All documentation for audiorecorder is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.

BWF Metaedit

>This code was created in 2010 for the Library of Congress and the other federal government agencies participating in the Federal Agencies Digitization Guidelines Initiative and it is in the public domain.

Detailed BWF Metaedit License available [here](https://mediaarea.net/BWFMetaEdit/License).
