Summit RC+S preprocessing and analysis functions
==

Summary: 
-------------

This collection of code allows the preprocessing analysis and plotting of RC+S data. It includes a collection of GUI tools to plot the data in interactive form as well as command line (Matlab) tools to get at the raw data. It also has some code to allow syncing to Delsys data. 

Tips for data recording 
-------------
Sample data files for recording at home, in clinic and for aDBS are provided in this repo. Below you will find links to sample files that will work with each recording scenario. Here are a few general tips: 

* Check the sensing settings:
	* Mode 3/4: Recording in mode 3 allows reliable transmission at 4500 bps at a larger range, whereas mode 4 allows 6000 bps at a shorter range. At home we usually use mode 3 and in clinic mode 4.  
	* Sampling rate: 2 time domain channels @1000Hz, 4 @500hz.   
	* Recording electrodes: Make sure to check recording electrodes are correct. 
	* Make sure all the channels you want are "enabled". 
	* Check both stream and sense enables are set correctly. Stream enables control what data is actually streamed (recorded) whereas sense enables have to do with what data it is possible to stream. One example: to stream power data you would want to allow FFT for sense (required) but not stream (since it transmits too much data and you will get packet loss). Consult Medtronic manual for more detail on this. 
	* Check that current settings will not create packet loss using excel sheet in the help docs if using settings that are different than the ones supplied below. This is currently being implemented in software but is not ready yet. 
	* On stim: unless tested, best to stick to LFP1 and LFP2 at 100Hz for STN/GPi leads.

#### Sample config files: 
* [aDBS settings sample file](data/sample_config_files/aDBS_config) - these are sample sense settings for aDBS (embedded) recording using one LD and 1 power channel. 
* [home recording](data/sample_config_files/home_recording) - setting optimized for home recording of data 
* [in clinic recording](data/sample_config_files/in_clinic_recording) - setting optimized for in clinic recording of data 
* [montage recording](data/sample_config_files/montage_recording) - sample montage files that we used for most montage settings 
* [stim sweeep](data/sample_config_files/stim_sweep) - sample files to be used during a stimulation sweep
	
Installation instructions
-------------

* Compatibility - mac or PC. Much of this also works on Linux but a central toolbox we rely on to open `.json` files does not work on Linux. 
* If you are on a PC install GitHub (if it isn't already installed). You can check this by open opening terminal (mac) or cmd (pc) and typing `git status`. If that doesn't work, than you need to install GitHub. 
* Clone the repository. It's very important that you don't just download all the code but do it properly with a clone so that you can get updates in the future and the next item on the list work (the check updates). If you don't know how to do that:
	* PC: Navigate to a location in which you want the code to save then `Shift` `right-click` on the background of the Explorer window, then click on "Open command window here" or "Open PowerShell window here". 
	* Mac: open a terminal and navigate to location where you want the code to download [(shortcut)](https://www.maketecheasier.com/launch-terminal-current-folder-mac/)
* in resulting window type: `git clone https://github.com/starrlab/rcsviz.git` 
* `cd` into the downloaded directory 
* Note that you should always run all of this code within the `code` directory. It relies on relative directory structure to operate properly. Do not navigate to patient data folders even if you added everything to your matlab path. 
* Before every use please run the function `updateandcheckdepedencies`. 
* The best place start if you don't want to use GUI tools and wand to understand the data structure is the sample data folder and this script `START_HERE_EXP_SCRIPT`. 
This will allow you to see samples of raw RC+S time domain data (in JSON format) and test the processed "tidy" output created from the `.json` files that RC+S output. All data exists in the `sample_data` folder of this rep and `START_HERE_EXP_SCRIPT` navigates there using relative directory mapping.

Quick and dirty 
-------------
I don't care about the details - just tell me how to plot the data - I want to take a look!
Run this matlab function: 
`plot_raw_rcs_data(fn)` The variable `fn` is a string of the path to the folder with the `.json` files. This is the folder that starts with `Device...`. Note that zooming in with resulting graph will zoom in all channels at once. Also (top left) button (plot PSD + spect) will allow you to plot PSD's and spectrograms of the zoomed in portion. This is stored in a "snapshots" folder that is created in the directory of the raw data.
Another way to quickly get started (not using GUI tools) is to run the example script (`START_HERE_EXP_SCRIPT`) that has executable blocks that work with the sample data we have in this repo.  

GUI Tools
-------------

#### RC+S Session Viewer 

This is the "gateway" into easily reading a large directory with session folders from RC+S. Run `rcsSessionViewer` from the command line. Note that you need `Matlab 2018b` or newer to run this function. Click "load dir":

![RC+S Session Viewer](images/rcsSessionViewer.jpg)

Choose a directory that contains all the session folders: 

![RC+S Session Viewer Post selection](images/rcsSessionViewerPostSelection.jpg)

And you will get this view: 

![RC+S Session Viewer populated](images/rcsSessionViewerPopulated.jpg)

Clicking on any row will bring up the `RC+S data chopper` that will allow you to view interactive version of the data. 


#### RC+S Data Chopper 

This will bring up the RC+S data chopper: 

![RC+S data chopper](images/rcsDataChopperFirstSelection.jpg)

This has two tabs - an event tab and a data view tab. Navigate to the data view tab: 

![RC+S data view](images/rcsDataChopperDataView.jpg)

The data viewer has many functions. It allows you zoom into the data, plot PSD's and spectrograms,zoom into specific events and save data "chunks" for later analysis. Here is a run down - going top left to right: 

* Note that the session name (folder) is in the title of the window. 
* `From\To dropdown` - these buttons will zoom in on events  
* `zoom out` - zooms all the way out 
* `print label struc` - prints the channels out to the command line 
* `lblstruct dropdown` - this will switch the channel labels if more than one recording param was used 
* `save` - saves the current view as a data chunk in the directory in which the data exists 
* `From\To text boxes` - if you input time information it will zoom into these times (press return). 
* `plot psd` - plots psd of zoomed in section 
* `plot spectrogram` - plots spectrogram of zoomed in section 
* `Save name` - saves the current data chunk with the name given in text box 

#### RC+S Montage Sweep viewer 

This tool is used in tandem with the montage function with the adaptiveDBS software we use for in clinic data collection. It relies on having a single session with only montage data in it (so don't record anything else during this session except for montage data). It automatically uses the events for the different electrode configuration to plot the montage data. 

This will bring up the following GUI: 

![RC+S montage GUI](images/rcsMontageGUI.jpg)

A - use the load data button to load the directory with all session .json folders, then press plot PSD's button
B - There is a tab for STN and for M1 data 
C - You can selector + CTRL to select only a few channels at a time 

#### RC+S data format 

What is the RC+S native data format? 
-------------

The Medtronic API saves data into a session directory. Files can typically be streamed for 30 hours (~ max INS battery life) if streaming time domain data, or even longer if streaming power domain data. 

There are two primary challenges associated with opening these `.json` file and analyzing them. The first, is the nature of the files. There are 11 `.json` files that combine meta-data and numerical data. As explained below, interpreting the meaning of the metadata is often not straightforward. The second is dealing with lost packets and accurately representing the data in the time domain across the different classes of data. Each of these challenges and how we have solved in this instance are detailed below. 

RC+S raw data structure and conversions  
-------------

Each session directory contains a number of files in `.json` format. Typically each of the `.json` files have a header that includes some metadata and then contain information in packet form. Packets are streamed in UDP fashion. This means that some packets may be lost in transmission or if patient walks out of range. Usually each packet in the `.json` files contains a mix of numerical data and metadata. Below is a non-comprehensive guide regarding the main datatypes that exists within each `.json` file as well as their organization when being imported into the `matlab` table format. 

The `.json` file structure has several advantages: It is human readable, there is a library of parsers to read and ingest data in `.json` format and the hierarchal structural organization make supporting complex data types and structured variables easy. It also has several notable disadvantages (somewhat attributable to the way Medtronic implemented their file format): You can not easily open large files, can not jump to specific area in the file quickly and the data is not organized in easy to analyze matrices. Further, information from each session is scattered across a large number of `.json` files. Finally, much of the meta data, though human readable is not readily understandable. For example, sampling rates are stored in binary format with arbitrary values that must be looked up in the Medtronic support docs instead of in Hz. There are much worse examples, for example decoding which power domain predetermined bands were streamed from the device required a complex set of deductive steps. 

The main goal of this section of the document is to describe the .json file types and the Matlab table variables that are used to flatten them to simple, easily analyzable structures. I opted to keep the .json file names whenever possible. I also flattened the data such that samples were in rows, and data features are in columns. 

Each `session` will create a directory with a unix timestamp in the format [`session` `timestamp`]. This session directory will have the following `.json` files. I have written readers for 5/9 `.json` files (the first 6 listed below). 

* `RawDataTD.json` - Contains continuous raw time domain data in packet form. Each packet has timing information (and packet sizes are not consistant). Data can be streamed from up to 4 time domain channels (2 on each bore) at 250Hz and 500Hz or up to 2 time domain channels at 1000Hz. Data is represented in packets that contain variable sample numbers. A timestamp is only available for the last element of each data packet and timing information for each sample must be deduced. 
* `RawDataAccel.json` - Contains continuous raw onboard 3 axis accelerometry data as well as timing information. The structure and timing information is similar to the time data files 
* `DeviceSettings.json` Contains discrete information about device settings. For example, the sampling rate, the montage config (which electrodes are being recorded from), power bands being used, etc. Since connecting to the RC+S is often a time consuming processes the same file often contains different sample rates and recording montages. Each time a change is registered `DeviceSettings.json` will contain another packet with the timestamped nature of the change. This data is discrete and not continuous. 
* `RawDataFFT.json` - Contains continuous information streamed from the onboard (on-chip) FFT engine. This is only used in rare cases in our use cases, since streaming FFT information is bandwidth intensive and will preclude one from streaming any time domain data. I have not written a reader for this file type. 
* `RawDataPower.json` - Contains continuous information streamed from the on board FFT engine in select power bands. The data rate is set by the FFT engine, and can be very fast (1ms) and very slow (upper limit is in the hours or days range). This is the raw input in the onboard embedded adaptive detector. The raw power is much less data intensive than the FFT data. You can stream up to 8 power domain channels (2/each TD channel) at once. Note that the actual bandpass information is (e.g. what values in Hz are being bandpassed) is not contained in the `RawDataPower.json` but in the `DeviceSettings.json`. If these values are changes in the middle of the recording (as they often are during testing of embedded adaptive sessions) this will have to be dealt with later in stitching the data into readable form. 
* `AdaptiveLog.json` -  Contains any information from the embedded adaptive detector. Information such as detector state and current in milliamps. 
* `StimLog.json` - Contains discrete information about the stimulation setup. E.G. which group, program, rate and amplitude the device is currently in. 
* `ErrorLog.json` - Contains information about errors. I have not written a parser for this as most of the errors are caught by our loggers or other methods. 
* `EventLog.json` - Contains discrete information we write down into the device. These can be experimental timings or patient report of his state if streaming at home. Note that this information only contains timing information in computer time, whereas all the continuous information time domain or power domain data has INS time to rely on (on board INS clock). More about why this is important below. 
* `DiagnosticsLog.json` - Contains discrete information that can be used for error checking. 
* `TimeSync.json` - Do not use this file. Not clear to me what it does. 

Note that in each recording session it is possible to not stream a particular data subset. For example, you can stream power domain data and not time domain data or any other data type. In that case the other data types will contain empty `.json` files with minimal metadata information. `

General note: There are a number of utility functions to open the raw data at once from one folder (these are covered below). All the main functions should run without input (in which case they will usually ask for data directory with all `.json` files) or can be given a string with the folder path. 

#### Detailed information about the structure of each `.json` file and conversion to `.mat` variables (mostly `table`). 

* `MAIN_load_rcs_data_from_folder.m` - This function returns all data types for which data converters are written. Each of the arguments it returns is outlined below as well as the corresponding .json file and the `.m` file  that is called to convert this file. 

The main function referenced above opens some of the files mentioned above and mostly returned them in the format of a Matlab `table` variables or `struct`. Below is a detailed list of each `.json` file that is created for each RC+S session, input strucure, output structure and details about the type of information the file contains: 

* `AdaptiveLog.json`
	* Data type: Adaptive packets with information about adaptive algorithm states (like stim changes). Packet corresponds to FFT packets size. 
		*`HostUnixTime`
		*`PacketGenTime`	
		*`PacketRxUnixTime`
		*`dataSize`
		*`dataType`
		*`dataTypeSequence`
		*`globalSequence`
		*`info`
		*`systemTick`
		*`timestamp`
		*`CurrentAdaptiveState`
		*`CurrentProgramAmplitudesInMilliamps`
		*`IsInHoldOffOnStartup`
		*`Ld0DetectionStatus`
		*`Ld1DetectionStatus`
		*`PreviousAdaptiveState`
		*`SensingStatus`
		*`StateEntryCount`
		*`StateTime`
		*`StimFlags`
		*`StimRateInHz`
		*`LD0_featureInputs`
		*`LD0_fixedDecimalPoint`
		*`LD0_highThreshold`
		*`LD0_lowThreshold`
		*`LD0_output`
		*`LD1_featureInputs`
		*`LD1_fixedDecimalPoint`
		*`LD1_highThreshold`
		*`LD1_lowThreshold`
		*`LD1_output`

	* Matlab function to open: `readAdaptiveJson.m` still a little buggy and does not return data in ideal table structure but still in a simple mat structure that mirror `.json` to a certain degree. 
	
* `DeviceSettings.json`
	* Data type: Contains all information about device settings (recording contacts used etc.). 
	* Matlab function to open: `loadDeviceSettings`
	* Output: `outRec` a structure variable that contains discrete channel information. Still needs more work to be combined with other table data forms. 
	
	
* `EventLog.json`
	* Data type: Contains event information that is created using the `report` function in the `AdaptiveDBS` or `SCBS` data collection apps. 
	* Matlab function to open: `loadEventLog` 
	* Output: `eventTable`  
	* `sessionTime`
	* `sessionid`
	* `EventSubType`
	* `EventType`
	* `UnixOnsetTime`
	* `UnixOffsetTime`
	* `HostUnixTime
	`
* `RawDataFFT.json`
	* Data type: Contains FFT packets 
	* Matlab function to open: Not written yet as large scale data unlikely with full FFT packets. 
	* Output:
	
* `RawDataPower.json`
	* Data type: Power data from predefined power bands. 
	* Matlab function to open: `loadPowerData` 
	* Output: `powerTable` - which contains all power packets and `powerBandInHz` which is a cell array with the pre defined power bands. 
	* `powerOut`, `powerTable`, `bands`
	*`powerBandInHz`
	*`powerChannelsIdxs`
	*`fftSize`
	*`bins`
	*`numBins`
	*`binWidth`
	*`sampleRate`
	*`PacketGenTime`
	*`PacketRxUnixTime`
	*`ExternalValuesMask`
	*`FftSize`
	*`IsPowerChannelOverrange`
	*`SampleRate`
	*`ValidDataMask`
	*`Band1`
	*`Band2`
	*`Band3`
	*`Band4`
	*`Band5`
	*`Band6`
	*`Band7`
	*`Band8`
	*`dataSize`
	*`dataType`
	*`dataTypeSequence`
	*`globalSequence`
	*`info`
	*`systemTick`
	*`timestamp`

* `RawDataTD.json`
	* Data type: This contains all the time domain data packets as well some timing information and meta data. 
	* Matlab function to open: `MAIN` 
	* Output:  
	* `outdatcomplete` a matlab `table` with all the data which includes these columns:  
	* `srates` - a vector of size `number of samples` samples has a sample rate associated with it for each data sample. This can be different across the file.  
			* `key0` - channel 0 on the first INS bore (assuming no bridging). containes numerical data in milivolt. This is the name of the field in the `.json`. Information about channnel setings is in the `DeviceSettings.json` file.  
			* `key1` - channel 1 on the first INS bore (assuming no bridging). containes numerical data in milivolt. This is the name of the field in the `.json`  
			* `key2` - channel 2 on the first INS bore (assuming no bridging). containes numerical data in milivolt. This is the name of the field in the `.json`  
			* `key3` - channel 3 on the first INS bore (assuming no bridging). containes numerical data in milivolt. This is the name of the field in the `.json`  
			* `systemTick` - 16bit INS clock-driven tick counter, rolls over, LSB is 100microseconds (high accuracy and resolution). You get one of these for each packet which corresopnds to the last sample.  
			* `timestamp` -  INS clock-driven time, LSB is seconds (highly accurate, low resolution, does not roll over). Same as above.  
			* `samplerate`- derived metric I compute for each sample, vector.  
			* `PacketGenTime` - API estimate of when the data packet was created on the INS within the PC clock domain. Estimate created by using results of latest latency check (one is done at system initialization, but can re-perform whenever you want) and time sync streaming. Potentially useful for syncing with other sensors or devices by bringing things into the PC clock domain, but is only accurate within 50ms give or take.  
			* `PacketRxUnixTime` - PC clock-driven time when the packet was received via Bluetooth, as accurate as a C# DateTime.now (10-20ms).  
			* `packetsizes` - number of samples per packet.  
			* `derivedTimes` - the derived time for each sample computed using a combination of `timestamp` and `systemTick`. This is the most accurate clock in the time domai. For more on how this computation is done see [here](https://github.com/roeegilron/rcsanalysis).  

		
		
* `RawDataAccel.json` - Contains continuous raw onboard 3 axis accelerometry data as well as timing information. The structure and timing information is similar to the time data files. 
	* Data type: This contains all the time domain data packets as well some timing information and meta data. 
		*`outdatcomplete` a table with all the data
		* `srates` - a matrix with all sampling rates (double)
		* `unqsrates` - a matrix with all unique sampling rates in the file 
		* `XSamples` `YSamples` `ZSamples`  
		* `systemTick`
		* `timestamp`
		* `samplerate`
		* `PacketGenTime`		
		* `PacketRxUnixTime`
		* `packetsizes`
		* `derivedTimes`
	
* `DiagnosticsLog.json`
	* contains mostly diagnostic information Medtronic may use for debug sessions. 
	
* `ErrorLog.json`
	* contains mostly diagnostic information Medtronic may use for debug sessions. 

		
		
		
		
		
		
* `StimLog.json`
	* Data type: Contains information about stim changes 
	* Matlab function to open: not written yet 
	* Output:
* `TimeSync.json`
	* Data type: Contains information about timing
	* Matlab function to open: not written yet, may not be needed 
	* Output:

* `MAIN_report_data_in_folder.json`- Quickly reads a folder with many session folders and generates a textual report. This is helpful when looking at a month of data for example to sort out what has been done. 

To get more in-depth information about the format of the data, please take a look at this example script `START_HERE_EXP_SCRIPT` which loads data in this repo with examples that can be executed in code blocks. 


#### Preprocess a large amount of data 
currently preprocessing a large amount of data takes a long time. Utility function to load many folders serially: 
* `MAIN_load_rcsdata_from_folders`


To Do: 
-------------
* 1
* 2
* 3
