# EEG data processing scripts

This repository contains the scripts that I used to process EEG data for an experiment on dialectal variation in American English. 

`DM_process` takes the CNT files from our NeuroScan system and processes them with the `EEGLAB` and [`ERPLAB`](https://github.com/lucklab/erplab) Matlab toolboxes for ERP analysis. This processing includes filtering, epoching, baseline correction, artifact detection/rejection, and computing averaged ERPs in each bin. `DM_process_half` is an adapted version of this script that separately processes the first and second halves of the experiment (based on the number of trigger codes) in order to test for adaptation effects.

`artifact_thresholds` and `accepted_trials` are custom functions for `DM_process` that interate over each participant's data to find the correct eye-blink voltage threshold.

`DM_analysis` loads the processed ERP files for each participant, computes averaged ERPs for each time window, and creates grand averaged waveforms for plotting.

The `setup` script referenced in `DM_process` and `DM_analysis` loads `EEGLAB` and sets up all of the input/output file paths. This file is not included in this repository.
