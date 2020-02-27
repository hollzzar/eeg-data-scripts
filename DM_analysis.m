%Call setup script to load eeglab and set file paths
setup

%Get subject list
current_subs.all = dir(strcat(filepath,'*.erp'));
num_all = length(current_subs.all);

%Initialize variables/fields
current_subs.MAE = {};
current_subs.SUSE = {};
erp_list.MAE = {};
erp_list.SUSE = {};

%Load SUSE ID numbers
SUSE_id = readcell([SUSEpath 'SUSE.txt']);
num_SUSE = length(SUSE_id);

%Get noisy subject numbers
noisy_subs = dir(strcat(filepath,'*_noisy_*'));
num_noisy = length(noisy_subs);

%Remove noisy subjects from further analysis
for n = 1:num_noisy
    sub = noisy_subs(n).name;
    sub = erase(sub,'_noisy_AR_Summary.txt');
    current_subs.noisy{n} = sub;
end

%Initialize analysis lists
erp_reject = [];
erp_MAE = [];
erp_SUSE = [];

%Loop through each subject to put it in the right group
%or remove if noisy
for n = 1:num_all
    
    %Get subject number and erp file name
    sub_erp = current_subs.all(n).name;
    sub = erase(sub_erp,'.erp');
    sub_num = str2num(sub);
    
    %Check if subject is in SUSE group
    check_SUSE = sum([SUSE_id{:}] == sub_num);
    
    %Check if subject is noisy
    check_noisy = sum(strcmp(sub,current_subs.noisy));
    
    %Manual adjustments to participant list
    if sub_num == 202 %remove 202; incorrect age group
        
        check_noisy = 1;
        
    elseif sub_num == 122 %remove 122; language history
        
        check_noisy = 1;
        
    elseif sub_num == 107 %remove 107; language history
        
        check_noisy = 1;
        
    end
    
    if check_SUSE == 0 && check_noisy == 0 %MAE
        
        current_subs.MAE{end+1} = sub;
        erp_list.MAE{end+1} = sub_erp;
        erp_MAE = [erp_MAE; sub_num];
        
    elseif check_SUSE == 1 && check_noisy == 0 %SUSE
        
        current_subs.SUSE{end+1} = sub;
        erp_list.SUSE{end+1} = sub_erp;
        erp_SUSE = [erp_SUSE; sub_num];
        
    else
        
        erp_reject = [erp_reject; sub_num];
        
    end
    
end

%Export txt files
dlmwrite([outpath 'ERP_reject.txt'],erp_reject)
dlmwrite([outpath 'ERP_MAE.txt'],erp_MAE)
dlmwrite([outpath 'ERP_SUSE.txt'],erp_SUSE)

%Set variables for time window average output
bins = [5 8];
electrodes = {[5 14 25 35:39], [13:15 18:21 23:27]};
times = {[150 300], [300 500], [500 900]};
fields = {'SUSE','MAE'};

%Set variables for grand mean output
filter = 15;
files = {'_elan.txt', '_n400.txt', '_p600.txt', '_centro-parietal_p600.txt'};

%Set counter/index variables
num_fields = length(fields);
num_files = length(files);
electrode_index = {1, 1, 1, 2};
    %Electrode index 1 = Fz, Cz, Pz, LF, RF, LP, RP
    %Electrode index 2 = Cz, C3, C4, CP1, CP2, CP5, CP6, Pz, P3, P4, P7, P8
time_index = {1, 2, 3, 3};

%Create averaged data for all time windows and subject groups
for f = 1:num_fields
    %Load all subjects' pre-processed data
    [ERP ALLERP] = pop_loaderp('filename', erp_list.(fields{f}), 'filepath', filepath);
    
    %Create list with set indices in ALLERP
    set_files = 1:length(ALLERP);
    
    %Loop through time windows of interest to output averaged data for analysis
    for t = 1:num_files
        latency = times{time_index{t}};
        filename = [fields{f} files{t}];
        elec = electrodes{electrode_index{t}};
        ALLERP = pop_geterpvalues(ALLERP, latency, bins, elec,...
            'Baseline', 'pre', 'Erpsets',  set_files, 'FileFormat', 'long',...
            'Filename', [outpath filename], 'Fracreplace', 'NaN',...
            'InterpFactor', 1, 'Measure', 'meanbl', 'PeakOnset', 1,...
            'Resolution', 3);
    end
    
    %Create file name
    grand_filename = [fields{f} '_grand'];
    
    %Create grand mean erp
    ERP = pop_gaverager(ALLERP, 'Erpsets', set_files, 'ExcludeNullBin',...
        'on', 'SEM', 'on');
    ERP = pop_filterp(ERP, 1:34, 'Cutoff', filter, 'Design', 'butter',...
        'Filter', 'lowpass', 'Order', 2);
    ERP = pop_savemyerp(ERP, 'erpname', grand_filename, 'filename',...
        ['erp/' grand_filename '.erp'], 'filepath', filepath, 'Warning', 'on');
    
    %Save grand mean as txt file for plotting
    pop_export2text(ERP, [outpath grand_filename], bins, 'time', 'on', 'timeunit',...
        0.001,'electrodes', 'on', 'transpose', 'off', 'precision', 10)
    
    clear ERP ALLERP ALLCOM
    
end