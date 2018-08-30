# Development History

**2018-08-30:** audiorecorder2 added to homebrew install formula. Can now be installed with option `--with-audiorecorder2`
**2018-03-15:** In development version 2 (in linux) tested with twenty minute recording at 24 bit/96 kHz stereo recording. File analyzed for interstitial errors using Wavelab Elements 9.5 global analysis with none detected.

**2017-12-26:** Version 0.1.08 released. Mainly typo fixes.

**2017-12-14:** Version 0.1.07 released. Fix bug. Stricter man page syntax.

**2017-10-18:** Version 0.1.06 released. Improved help message and man page.

**2017-10-01:** Version 0.1.05 released. Deletes BWF Metaedit from the package and uses its homebrew formula instead.

**2017-08-22:** Version 0.1.04 released. Mainly doc fixes.

**2017-06-05:** Version 0.1.03 released. Linux install instructions, man page and Code of Conduct have been added.

**2017-04-25:** Version 0.1.02 released. Includes font support for filters in Linux. (Tested in Ubuntu 16.04).

**2017-04-11:** Version 0.1.01 released. Contains some basic interface workarounds to decrease reliance on Pashua for user input. This makes audiorecorder able to run in a linux environment (further reliability testing for non macOS systems is underway).

**2017-03-11:** Major redesign of post-digitization functions and GUI. Audiorecorder now supports trimming of start and end of files via manual specification as well as auto-trim of silence at the start of files. Preview and post-digitization GUI now incorporate waveforms of the digitized audio to aid in trimming. All testing has been negative for dropped samples.

**2017-03-04:** For the new release changes have been made to streamline the way audiorecorder handles input channels. This will prevent it from being overwhelmed by A/D converters that output many empty tracks along with the desired tracks (such as the Apogee Symphony). In two 55 minute tests and one 30 minute no drops or problems were detected via Wavelab analysis. Due to more efficient management of data the current buffering now has increased the latency for mono captures. A next step will be to see how much buffering can be safely lowered.

**2017-02-24:** Changes appear to have been successful for adapting audiorecorder to macOS 10.12.03. In testing it was discovered that audiorecorder has issues with A/D converters that have a large number of output tracks (such as sixteen as opposed to two). Current audiorecorder head appears to be stable for two track A/D converters and testing is underway to expand its ability to deal with larger multi-track converters.

**2017-02-23:** Due to some issues that were reported with macOS 10.12.03, some changes to buffering have been made and are currently being tested.

**2017-02-15:** Ability to select which channel to record has been added to the GUI. This option was tested with a 25 minute ingest on 2013 Macbook Air with no dropped samples detected audibly or vie Wavelab global analysis. Some glitches with file trimming were resolved.

**2017-01-20:** Initial post digitization functions have been included via a basic GUI. These include ability to preview file with and without silence trimming, and an option to create a silence trimmed version of file. The spectrograph has also been changed to scroll for easier viewability. Further testing has not detected any dropped samples either audibly or via Wavelab global analysis. 

**2016-12-22:** Current build was tested with a 40 minute transfer on the 2013 Macbook Air with no dropped samples detected either audibly or via Wavelab's global analysis tool. Testing continues...
