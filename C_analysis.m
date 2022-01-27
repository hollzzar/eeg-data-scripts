%% Load EEGLAB and set file paths

A_setup

%% Load participant numbers

%Get list of all participants
all_subs = dir(strcat(processfolder,'*.erp'));
all_subs = erase({all_subs.name},'.erp');

%Get list of participants with noisy EEG data
noisy_subs = dir(strcat(processfolder,'*_noisy_*'));
noisy_subs = erase({noisy_subs.name},'_noisy_AR_Summary.txt');

% Make list of participants who need to be removed manually
remove_subs = {};

%% Refine participant numbers

%Get list of participants to reject
reject_subs = [noisy_subs remove_subs];

%Get list of participants to keep
keep_subs = setdiff(all_subs, reject_subs);

%% Export txt files with participant lists

writecell(reshape(reject_subs, [length(reject_subs) 1]), [outpath 'ERP_reject.txt'])
writecell(reshape(keep_subs, [length(keep_subs) 1]), [outpath 'ERP_keep.txt'])

%% Initialize variables

%Set variables for time window average output
erp_data = strcat(keep_subs, '.erp'); %Participants left after automatic 
%and manual rejection
bins = [5 8]; %Bin numbers from bdf file 
electrodes = {[5 14 25 35:39]}; %Electrode numbers from process file = Fz, 
%Cz, Pz, LF, RF, LP, RP, CP
times = {[200 400], [500 900]}; %Time windows in ms
files = {'_t1_', '_t2_'}; %One file per time window

%Set counter/index variables
num_files = length(files); %Number of loops for mean amplitude calculations
%= number of time windows
electrode_index = {1, 1}; %One index per time window
time_index = {1, 2};

%Set variables for grand mean output
filter = 15;

%% Load all subjects' pre-processed data: main analysis

%Load data
[ERP ALLERP] = pop_loaderp('filename', erp_data, 'filepath', processfolder);

%Create list with set indices in ALLERP
set_files = 1:length(ALLERP);

%% Calculate mean amplitudes

%Loop through time windows of interest to output averaged data for analysis
%in R
for t = 1:num_files
    latency = times{time_index{t}};
    filename = ['all' files{t}];
    elec = electrodes{electrode_index{t}};
    ALLERP = pop_geterpvalues(ALLERP, latency, bins, elec,...
        'Baseline', 'pre', 'Erpsets',  set_files, 'FileFormat', 'long',...
        'Filename', [outpath filename], 'Fracreplace', 'NaN',...
        'InterpFactor', 1, 'Measure', 'meanbl', 'PeakOnset', 1,...
        'Resolution', 3);
end

%% Calculate grand means for plotting

%Create grand means
ERP = pop_gaverager(ALLERP, 'Erpsets', set_files, 'ExcludeNullBin',...
    'on', 'SEM', 'on');
ERP = pop_filterp(ERP, 1:34, 'Cutoff', filter, 'Design', 'butter',...
    'Filter', 'lowpass', 'Order', 2);

%Save grand mean as txt file for plotting
pop_export2text(ERP, [outpath 'grand_mean'], bins, 'time', 'on', 'timeunit',...
    0.001,'electrodes', 'on', 'transpose', 'off', 'precision', 10)