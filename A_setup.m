cd /your_dir/Matlab/eeglab14_1_2b

eeglab

cd /your_dir/eeg-data-scripts/

%% process_1 %%

%Location of raw data
parentfolder = '/your_dir/eeg-data-scripts/cnt_files/';

%Location of bdf file
bdffolder = '/your_dir/eeg-data-scripts/txt_files/';

%Location of channel information for EEG system
channelfolder = '/your_dir/MATLAB/eeglab14_1_2b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp';

%Location for pre-processed data
processfolder = '/your_dir/eeg-data-scripts/pre_process/';
if ~exist(processfolder, 'dir')
    mkdir(processfolder);
end

%% DM_analysis %%

%Location for averaged data
outpath = '/your_dir/eeg-data-scripts/avg_files/';
if ~exist(outpath, 'dir')
    mkdir(outpath);
end