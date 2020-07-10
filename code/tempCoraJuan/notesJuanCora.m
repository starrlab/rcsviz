extract time domain data on off/on med time window


DataSelection %% should whobe flexible and generalizable (criteria, input setting)
    % symptoms
    tremor
    diskinesia
    
    % meds (specific to patients)
    med.Rytary
    med.baclofen
    ...
    
    TimeWindow (e.g. morning, btw 8:30 and 9:30, ... flexible input types)
        

e.g. with meds   
first med in the morning, first am
last med of day, last PM

windowVar = medtime x (x +/- minutes); around med time, 
(15 min before, 60 min after) (before, after (most likely non symmetrical))

go inot each folder
    time
    extract BG
    Ecog at time of med
    sensing settings (sr, ...)
    events within twindow
    TableAllData = save('RCS0XRmedEffectAllData.mat')
 
% output is .mat file with compiled infor for 1 side of 1 patient
RCS0XRmedEffectAllData.mat
RCS0XLmedEffectAllData.mat
RCS0XRLmedEffectAllData.mat = [RCS0XRmedEffectAllData.mat;RCS0XLmedEffectAllData.mat]

I have a few questions:
	?	why is the data length different between files/rows since we are taking the same window around med time.
	?	why some data only have 1 value not a vector with brain signals.
	?	in the event isn't there somewhere the symptoms? I thought that when pt add time of med they have to add Sx assessments? would be good to have that.

%%%%%%%%%%%%%%%%
% Function to extract Montage