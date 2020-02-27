function  [acce] = accepted_trials(EEG)

%The following code is taken directly from pop_summary_AR_eeg_detection()
%pop_artmwppth() calls that function during artifact detection
%This new function outputs a matrix with the accepted trials, which will
%allow me to determine which participants need a higher eye-blink threshold
%during data processing

%% pop_summary_AR_eeg_detection() %%

F = fieldnames(EEG.reject);
sfields1 = regexpi(F, '\w*E$', 'match');
sfields2 = [sfields1{:}];
rfields  = regexprep(sfields2,'E','');
nfield   = length(sfields2);
histE    = zeros(EEG.nbchan, EEG.trials);
histT    = zeros(1, EEG.trials);

for i = 1:nfield
        fieldnameE = char(sfields2{i});
        fieldnameT = char(rfields{i});
        
        if ~isempty(EEG.reject.(fieldnameE))
                histE = histE | [EEG.reject.(fieldnameE)]; %electrodes
                histT = histT | [EEG.reject.(fieldnameT)]; %trials (epochs)
        end
end

nbin = EEG.EVENTLIST.nbin;
Sumbin = zeros(1,nbin);

for i = 1:nbin
        for j=1:EEG.trials
                if length(EEG.epoch(j).eventlatency) == 1
                        binix = [EEG.epoch(j).eventbini];
                        if iscell(binix)
                                binix = cell2mat(binix);
                        end
                        if ismember(i, binix)
                                Sumbin(i) = Sumbin(i) + histT(j);
                        end
                elseif length(EEG.epoch(j).eventlatency) > 1                        
                        indxtimelock = find(cell2mat(EEG.epoch(j).eventlatency) == 0,1,'first'); % catch zero-time locked type                       
                        if ismember(i, EEG.epoch(j).eventbini{indxtimelock})
                                Sumbin(i) = Sumbin(i) + histT(j);
                        end
                end
        end
end

%% accepted_trials() %%

%Initialize empty matrices for accepted/rejected trials per bin
acce = zeros(1,nbin);
rej  = zeros(1,nbin);

%Loop through each bin to extract the number of accepted/rejected trials in
%each bin
for i = 1:nbin
        rej(i)   = Sumbin(i) ;
        acce(i)  = EEG.EVENTLIST.trialsperbin(i)-rej(i);
end