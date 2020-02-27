function [EEG, threshold_no] = artifact_thresholds(EEG, threshold_1, threshold_2, threshold_3,...
    acce_bins, acce_accpt, acce_min)

%Number of bins I care about
nbins = length(acce_bins);

%Initialize EEG frame
test = EEG;

%Mark epochs with peak to peak activity greater than threshold
%HEOG and VEOG (eye electrodes)
test = pop_artmwppth(test, 'Channel', [33 34], 'Flag', [1 2],...
    'Threshold', threshold_1, 'Twindow', [-200 1200], 'Windowsize', 200,...
    'Windowstep', 100);

%Get matrix with accepted trials for each bin
acce = accepted_trials(test);

%Initialize matrix with binary marker bins without enough trials
acce_count = zeros(1,nbins);

%Loop through important bins to check if there are enough trials
for i=1:nbins
    
    b = acce_bins(i);
    
    if acce(b) < acce_accpt %If there are too few trials in a bin
        
        acce_count(i) = 1;
        
    else %If there are enough trials in a bin
        
        acce_count(i) = 0;
        
    end
end

%Check if bins have enough good trials
if sum(acce_count) > 0
    
    %Initialize EEG frame
    test = EEG;
    
    %Mark epochs with peak to peak activity greater than threshold
    %HEOG and VEOG (eye electrodes)
    test = pop_artmwppth(test, 'Channel', [33 34], 'Flag', [1 2],...
        'Threshold', threshold_2, 'Twindow', [-200 1200], 'Windowsize', 200,...
        'Windowstep', 100);
    
    %Get matrix with accepted trials for each bin
    acce = accepted_trials(test);
    
    %Initialize matrix with binary marker bins without enough trials
    acce_count = zeros(1,nbins);
    
    %Loop through important bins to check if there are enough trials
    for i=1:nbins
        
        b = acce_bins(i);
        
        if acce(b) < acce_min %If there are too few trials in a bin
            
            acce_count(i) = 1;
            
        else %If there are enough trials in a bin
            
            acce_count(i) = 0;
            
        end
    end
    
    %If any bins do not have nough trials, use higher threshold (3)
    if sum(acce_count) > 0
        
        %Initialize EEG frame
        test = EEG;
        
        %Mark epochs with peak to peak activity greater than threshold
        %HEOG and VEOG (eye electrodes)
        test = pop_artmwppth(test, 'Channel', [33 34], 'Flag', [1 2],...
            'Threshold', threshold_3, 'Twindow', [-200 1200], 'Windowsize', 200,...
            'Windowstep', 100);
        
        %Get matrix with accepted trials for each bin
        acce = accepted_trials(test);
        
        %Initialize matrix with binary marker bins without enough trials
        acce_count = zeros(1,nbins);
        
        %Loop through important bins to check if there are enough trials
        for i=1:nbins
            
            b = acce_bins(i);
            
            if acce(b) < acce_min %If there are too few trials in a bin
                
                acce_count(i) = 1;
                
            else %If there are enough trials in a bin
                
                acce_count(i) = 0;
                
            end
        end
        
        if sum(acce_count) > 0
            
            EEG = pop_artmwppth(EEG, 'Channel', [33 34], 'Flag', [1 2],...
                'Threshold', threshold_3, 'Twindow', [-200 1200], 'Windowsize', 200,...
                'Windowstep', 100);
            
            threshold_no = '_noisy_';
            
        else
            
            EEG = pop_artmwppth(EEG, 'Channel', [33 34], 'Flag', [1 2],...
                'Threshold', threshold_3, 'Twindow', [-200 1200], 'Windowsize', 200,...
                'Windowstep', 100);
            
            threshold_no = '_3_';
            
        end
        
    else %threshold_2 sufficient
        
        EEG = pop_artmwppth(EEG, 'Channel', [33 34], 'Flag', [1 2],...
            'Threshold', threshold_2, 'Twindow', [-200 1200], 'Windowsize', 200,...
            'Windowstep', 100);
        
        threshold_no = '_2_';
        
    end
else %threshold_1 sufficient
    
    EEG = pop_artmwppth(EEG, 'Channel', [33 34], 'Flag', [1 2],...
        'Threshold', threshold_1, 'Twindow', [-200 1200], 'Windowsize', 200,...
        'Windowstep', 100);
    
    threshold_no = '_1_';
    
end