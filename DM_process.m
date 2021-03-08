%% Call setup script to load eeglab and set file paths

setup

%% Set up variables

%Create subject list
subject_list = dir(strcat(parentfolder,'*.cnt'));
subject_list = {subject_list.name};
subject_list = erase(subject_list,'.cnt');

%Set variables for pre-processing
bdf = 'bdf.txt';
acce_bins = [5,8]; %Bins that I care about the most
acce_min = 20; %Minimum number of trials per bin that I care about
acce_accpt = 25; %Minimum number

%Set eye-blink thresholds
threshold_1 = 55;
threshold_2 = 65;
threshold_3 = 75;

%% Set up participants and channels

%Only process data for new participants
%Get list of already processed subjects
current_subs = dir(strcat(processfolder,'*.erp'));
num_current = length(current_subs);

%Loop through each subject number to see if it's already been processed
%If it has, remove it from the subject list
for n = 1:num_current
    
    sub_file = current_subs(n).name;
    sub_file = erase(sub_file,'.erp');
    subject_list = subject_list(~strcmp(subject_list, sub_file));
    
end

%Update number of subjects
numsubjects = length(subject_list);

%Define EEG channels
chnl = {'nch1 = ch1 - ( (ch17+ch22)/2 ) Label Fp1'...
    'nch2 = ch2 - ( (ch17+ch22)/2 ) Label Fp2'...
    'nch3 = ch3 - ( (ch17+ch22)/2 ) Label F7'...
    'nch4 = ch4 - ( (ch17+ch22)/2 ) Label F3'...
    'nch5 = ch5 - ( (ch17+ch22)/2 ) Label Fz'...
    'nch6 = ch6 - ( (ch17+ch22)/2 ) Label F4'...
    'nch7 = ch7 - ( (ch17+ch22)/2 ) Label F8'...
    'nch8 = ch8 - ( (ch17+ch22)/2 ) Label FC5'...
    'nch9 = ch9 - ( (ch17+ch22)/2 ) Label FC1'...
    'nch10 = ch10 - ( (ch17+ch22)/2 ) Label FC2'...
    'nch11 = ch11 - ( (ch17+ch22)/2 ) Label FC6'...
    'nch12 = ch12 - ( (ch17+ch22)/2 ) Label T7'...
    'nch13 = ch13 - ( (ch17+ch22)/2 ) Label C3'...
    'nch14 = ch14 - ( (ch17+ch22)/2 ) Label Cz'...
    'nch15 = ch15 - ( (ch17+ch22)/2 ) Label C4'...
    'nch16 = ch16 - ( (ch17+ch22)/2 ) Label T8'...
    'nch17 = ch17 - ( (ch17+ch22)/2 ) Label M1'...
    'nch18 = ch18 - ( (ch17+ch22)/2 ) Label CP5'...
    'nch19 = ch19 - ( (ch17+ch22)/2 ) Label CP1'...
    'nch20 = ch20 - ( (ch17+ch22)/2 ) Label CP2'...
    'nch21 = ch21 - ( (ch17+ch22)/2 ) Label CP6'...
    'nch22 = ch22 - ( (ch17+ch22)/2 ) Label M2'...
    'nch23 = ch23 - ( (ch17+ch22)/2 ) Label P7'...
    'nch24 = ch24 - ( (ch17+ch22)/2 ) Label P3'...
    'nch25 = ch25 - ( (ch17+ch22)/2 ) Label Pz'...
    'nch26 = ch26 - ( (ch17+ch22)/2 ) Label P4'...
    'nch27 = ch27 - ( (ch17+ch22)/2 ) Label P8'...
    'nch28 = ch28 - ( (ch17+ch22)/2 ) Label PO9'...
    'nch29 = ch29 - ( (ch17+ch22)/2 ) Label O1'...
    'nch30 = ch30 - ( (ch17+ch22)/2 ) Label Oz'...
    'nch31 = ch31 - ( (ch17+ch22)/2 ) Label O2'...
    'nch32 = ch32 - ( (ch17+ch22)/2 ) Label PO10'...
    'nch33 = ch33 Label HEOG'...
    'nch34 = ch34 Label VEOG'};

%Define ERP channels for butterfly plot
butterfly =  {'ch35 = (ch3 + ch4 + ch8 + ch9)/4 label LF'...
    'ch36 = (ch6 + ch7 + ch10 + ch11)/4 label RF'...
    'ch37 = (ch18 + ch19 + ch23 + ch24)/4 label LP'...
    'ch38 = (ch20 + ch21 + ch26 + ch27)/4 label RP'...
    'ch39 = (ch13 + ch14 + ch15 + ch19 + ch20 + ch24 + ch25 + ch26)/8 label CP'...
    'ch40 = (ch5 + ch14 + ch25)/3 label Mid'...
    'ch41 = (ch14 + ch19 + ch20 + ch25)/4 label SmallCP'};

%% Get data

%Loop through each subject's cnt file and pre-process
for s = 1:numsubjects
    
    %Grab current subject number from list
    subject = subject_list{s};
    
    %Load CNT file into EEG structure
    EEG = pop_loadcnt([parentfolder subject '.cnt'], 'dataformat',...
        'int32', 'memmapfile', '');
    
    %Filter data with low-pass at 30 Hz
    EEG = pop_basicfilter(EEG, 1:34, 'Boundary', 'boundary', 'Cutoff',...
        30, 'Design', 'butter', 'Filter', 'lowpass', 'Order', 4);
    
    %Change channels for subject where amplifier wires were flipped
    if strcmp(subject,'203')
        chnl(1) = {'nch1 = ch30 - ( (ch17+ch22)/2 ) Label Fp1'};
        chnl(30) = {'nch30 = ch1 - ( (ch17+ch22)/2 ) Label Oz'};
    end
    
    %Create/modify channels in current EEG structure
    EEG = pop_eegchanoperator(EEG, chnl, 'ErrorMsg', 'popup', 'Warning', 'on');
    
    %Edit channel locations structure
    %Look-up channel numbers for standard locations in BESA
    EEG = pop_chanedit(EEG, 'lookup', channelfolder);
    
    %Create and save event list
    EEG = pop_creabasiceventlist(EEG , 'AlphanumericCleaning', 'on',...
        'BoundaryNumeric', {-99}, 'BoundaryString', {'boundary'},...
        'Eventlist', [processfolder subject '_event.txt']);
    
    %Sort events into bins for analysis
    EEG = pop_binlister(EEG, 'BDF', [bdffolder bdf], 'IndexEL',  1, 'SendEL2',...
        'EEG', 'Voutput', 'EEG');
    
    %Divide EEG into epochs based on bins and perform baseline correction
    EEG = pop_epochbin(EEG, [-200.0  1200.0], 'pre');
    
    %Mark epochs with peak to peak activity greater than threshold in eye electrodes
    %HEOG and VEOG (eye electrodes): pop_artmwppth()
    %Custom function with different thresholds for pop_artmwppth()
    [EEG, threshold_no] = artifact_thresholds(EEG, threshold_1, threshold_2, threshold_3,...
        acce_bins, acce_accpt, acce_min);
    
    %Mark epochs with activity above an upper and below a threshold in head channels
    EEG = pop_artextval(EEG, 'Channel',  1:32, 'Flag', [1 3],...
        'Threshold', [-100 100], 'Twindow', [-200 1200]);
    
    %Save summary of artifact rejection by bin
    EEG = pop_summary_AR_eeg_detection(EEG, [processfolder subject threshold_no 'AR_Summary.txt']);
    
    %Save EEG dataset file
    EEG = pop_saveset(EEG, 'filename',[processfolder subject '_AR.set']);
    
    %Average epochs by bin
    ERP = pop_averager(EEG, 'Criterion', 'good', 'DSindex', 1,...
        'ExcludeBoundary', 'on', 'SEM', 'on');
    
    %Create channel averages for butterfly plot
    ERP = pop_erpchanoperator(ERP, butterfly, 'ErrorMsg', 'popup', 'Warning', 'on');
    
    %Save ERP file
    ERP = pop_savemyerp(ERP, 'erpname', subject, 'filename',...
        [subject '.erp'], 'filepath', processfolder);
    
end