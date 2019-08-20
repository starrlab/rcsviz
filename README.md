Summit RC+S preprocessing and analysis functions and some cheat sheets 
==

Summary: 
-------------

This collection of code allows the preprocessing analysis and plotting of RC+S data. It includes a collection of GUI tools to plot the data in interactive form as well as command line (Matlab) tools to get at the raw data. It also has some code to allow syncing to Delsys data. 

![converting .json to .csv](figures/conversion.jpg)

Tips for data recording 
-------------
Sample data files for recording at home, in clinic and for aDBS are provided. 

* Check the sensing settings:
	* Mode 3/4 
	* Sampling rate 
	* Recording electrodes 
	* Check that current settings will not create packet loss 


Installation instructions
-------------

* Download the repository 
* Before every use please run the function `updateandcheckdepedencies`. 

Samples of raw RC+S time domain data (in JSON format) with the processed "tidy" output created from it are available in the `sample_data` folder of this repo.

GUI Tools
-------------

#### RC+S Session Viewer 

![RC+S schematics](figures/packet-loss.jpg)

#### RC+S Data Chopper 

![RC+S schematics](figures/packet-loss.jpg)

#### RC+S Delsys analysis tool 

What does the raw data look like? 
-------------
The following `.json` files are created with each recording session: 
* `DeviceSettings`
* `DeviceSettings`
* `DeviceSettings`
* `DeviceSettings`
* `DeviceSettings`

What command line tools exist to read and open data? 
-------------
#### Plot raw data 
* `DeviceSettings`- details about getting raw data 

#### Preprocess a large amount of data 
currently preprocessing a large amount of data takes a long time. 
* `DeviceSettings`
* `DeviceSettings`
* `DeviceSettings`


To Do: 
-------------
* Add routines to process data folders 
* Consider implementing more efficient datetime storage (double rather than string) if human readability not important. 
* Backtrace first packet `timestamp` from a system rollover. 
* Consider using data that exists in TimeSync.json option.
