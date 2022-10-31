
subjects = [008 009];

for ID = subjects;
    
    subID = num2str(ID, '%03d');
    

 r=1;
 s=0;
 s=s+1;
spm_name = ['F:\processing\sub-', subID, '\1st_Level_basline\SPM.mat'];
roi_file = ['F:\processing\2st_Level\fullfactor\Interaction_speaker_x_language_9_57_12_roi.mat'];

D  = mardo(spm_name);

R  = maroi(roi_file);

Y  = get_marsy(R, D, 'mean');
% Get contrasts from original design
xCon = get_contrasts(D);
% Estimate design on ROI data
E = estimate(D, Y);
% Put contrasts from original design back into design object
E = set_contrasts(E, xCon);
% get design betas
b = betas(E);
B(:,(ID-1)*r+s)=b;
end