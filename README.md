# EEG data processing scripts

This repository contains the scripts that I used to process EEG data for an experiment on dialectal variation in United States English. 

`A_setup` is referenced in `B_process` and `C_analysis`; it loads `EEGLAB` and sets up all of the input/output file paths.

`B_process` takes the CNT files from our NeuroScan system and processes them with the `EEGLAB` and [`ERPLAB`](https://github.com/lucklab/erplab) MATLAB toolboxes for ERP analysis. This processing includes filtering, epoching, baseline correction, artifact detection/rejection, and computing averaged ERPs in each bin.

`artifact_thresholds` and `accepted_trials` are custom functions that I wrote/adapted for `B_process` that iterate over each participant's data to find the correct eye-blink voltage threshold.

`txt_files` contains the BDF file that relates the trigger codes to the different conditions/bins. This is used for epoching in B_process.

`C_analysis` loads the processed ERP files for each participant, computes averaged ERPs for each time window, and creates grand averaged waveforms for plotting.

