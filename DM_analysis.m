%% Load EEGLAB and set file paths

setup

%% Load participant numbers

%Get list of all participants
all_subs = dir(strcat(processfolder,'*.erp'));
all_subs = erase({all_subs.name},'.erp');

%Get list of participants with noisy EEG data
noisy_subs = dir(strcat(processfolder,'*_noisy_*'));
noisy_subs = erase({noisy_subs.name},'_noisy_AR_Summary.txt');

% Make list of participants who need to be removed
remove_subs = {'202', '122', '107', '214'};
%remove 202; incorrect age group
%remove 122, 107; language history
%remove 214; no behavioral data

%% Refine participant numbers

%Get list of participants to reject
reject_subs = [noisy_subs remove_subs];

%Get list of participants to keep
keep_subs = setdiff(all_subs, reject_subs);

%% Export txt files with participant lists

writecell(reject_subs, [outpath 'ERP_reject.txt'], 'Delimiter', '|')
writecell(reshape(keep_subs, [length(keep_subs) 1]), [outpath 'ERP_keep.txt'])

%% Initialize variables

%Set variables for time window average output
erp_data = strcat(keep_subs, '.erp');
first_data = strcat(keep_subs, '_first.erp');
second_data = strcat(keep_subs, '_second.erp');
bins = [5 8];
%     [5 8] % all SM vs. DM
%     [3 6] % could SM vs. DM
%     [4 7] % should SM vs. DM
electrodes = {[5 14 25 35:39]};
% Index 2: [13:15 18:21 23:27]
times = {[200 400], [500 900]};
files = {'_ean_', '_p600_'};

%Set counter/index variables
num_files = length(files);
electrode_index = {1, 1};
%Electrode index 1 = Fz, Cz, Pz, LF, RF, LP, RP, CP
%CP includes: C3, Cz, C4, CP1, CP2, P3, Pz, P4
%Electrode index 2 = Cz, C3, C4, CP1, CP2, CP5, CP6, Pz, P3, P4, P7, P8
time_index = {1, 2};

%Set variables for grand mean output
SUSE_id = readcell([SUSEpath 'SUSE.txt']);
filter = 15;

%% Load all subjects' pre-processed data: main analysis

%Load data
[ERP ALLERP] = pop_loaderp('filename', erp_data, 'filepath', processfolder);

%Create list with set indices in ALLERP
set_files = 1:length(ALLERP);

%% Calculate mean amplitudes: main analysis

%Loop through time windows of interest to output averaged data for analysis
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

%% Load all subjects' pre-processed data: half analysis

%Load data
[ERP_first ALLERP_first] = pop_loaderp('filename', first_data, 'filepath', halffolder);
[ERP_second ALLERP_second] = pop_loaderp('filename', second_data, 'filepath', halffolder);

%Create list with set indices in ALLERP
set_files = 1:length(ALLERP_first);

%% Calculate mean amplitudes: half analysis

%Loop through time windows of interest to output averaged data for analysis
for t = 1:num_files
    latency = times{time_index{t}};
    filename = ['all' files{t}];
    elec = electrodes{electrode_index{t}};
   
    % Half one
    ALLERP_first = pop_geterpvalues(ALLERP_first, latency, bins, elec,...
        'Baseline', 'pre', 'Erpsets',  set_files, 'FileFormat', 'long',...
        'Filename', [outpath filename 'half_1.txt'], 'Fracreplace', 'NaN',...
        'InterpFactor', 1, 'Measure', 'meanbl', 'PeakOnset', 1,...
        'Resolution', 3);
    
    % Half two
    ALLERP_second = pop_geterpvalues(ALLERP_second, latency, bins, elec,...
        'Baseline', 'pre', 'Erpsets',  set_files, 'FileFormat', 'long',...
        'Filename', [outpath filename 'half_2.txt'], 'Fracreplace', 'NaN',...
        'InterpFactor', 1, 'Measure', 'meanbl', 'PeakOnset', 1,...
        'Resolution', 3);
end

%% Create grand means

% Reshape list of SUSE participants
SUSE_id = SUSE_id(:,1);
SUSE_id = cellfun(@num2str, SUSE_id, 'un', 0);
SUSE_id = reshape(SUSE_id, [1 length(SUSE_id)]);

% Separate ERP data into SUSE/MAE participant groups
SUSE_subs = ALLERP(find(ismember({ALLERP.erpname}, SUSE_id)));
MAE_subs = ALLERP(find(~ismember({ALLERP.erpname}, SUSE_id)));

%% SUSE

%Create grand mean ERP: SUSE
SUSE_ERP = pop_gaverager(SUSE_subs, 'Erpsets', 1:length(SUSE_subs), 'ExcludeNullBin',...
    'on', 'SEM', 'on');
SUSE_ERP = pop_filterp(SUSE_ERP, 1:34, 'Cutoff', filter, 'Design', 'butter',...
    'Filter', 'lowpass', 'Order', 2);

%Save SUSE grand mean as txt file for plotting
pop_export2text(SUSE_ERP, [outpath 'SUSE_grand'], bins, 'time', 'on', 'timeunit',...
    0.001,'electrodes', 'on', 'transpose', 'off', 'precision', 10)

%% MAE

%Create grand mean ERP: MAE
MAE_ERP = pop_gaverager(MAE_subs, 'Erpsets', 1:length(MAE_subs), 'ExcludeNullBin',...
    'on', 'SEM', 'on');
MAE_ERP = pop_filterp(MAE_ERP, 1:34, 'Cutoff', filter, 'Design', 'butter',...
    'Filter', 'lowpass', 'Order', 2);

%Save MAE grand mean as txt file for plotting
pop_export2text(MAE_ERP, [outpath 'MAE_grand'], bins, 'time', 'on', 'timeunit',...
    0.001,'electrodes', 'on', 'transpose', 'off', 'precision', 10)
