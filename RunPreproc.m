%-----------------------------------------------------------------------
% SPM批处理脚本
%预处理
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%%清屏&清空工作区变量
clc
clear
spm fmri

%SPM路径
SPMPath = 'D:\spm12\spm12';

%%数据路径
datadir = 'G:\processing';

%%被试编号
subjects = [008 009 010 011 012 013 014];
        
%需要处理的run
RunList = {'run1' 'run2' 'run3' 'run4' 'run5' 'run6' 'run7' 'run8'};

%%建立循环
for ID = subjects
    ID = num2str(ID, '%03d');
    
    %结构像路径
    anatPath = char(strcat(datadir, '\sub-', ID, '\anat'));
    %读取结构像
    T1w = cellstr(spm_select('ExtFPListRec', anatPath, '^?_.*\.nii'));
    %功能像路径
    funcPath = char(strcat(datadir, '\sub-', ID, '\func'));
    
    %%%%时间层校正
    clear matlabbatch;
    
    for nrun = 1:length(RunList)
        nrun = num2str(nrun);
        
        matlabbatch{1}.spm.temporal.st.scans = {cellstr(spm_select('ExtFPListRec', [funcPath '\run' nrun '\'], 'run.*nii'))}';
        matlabbatch{1}.spm.temporal.st.nslices = 40; %扫描层数
        matlabbatch{1}.spm.temporal.st.tr = 2;  %TR
        matlabbatch{1}.spm.temporal.st.ta = 1.95;  %TA
        matlabbatch{1}.spm.temporal.st.so = [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40]; %扫描顺序
        matlabbatch{1}.spm.temporal.st.refslice = 2; %参考层
        matlabbatch{1}.spm.temporal.st.prefix = 'a';
        
        spm_jobman('run', matlabbatch);
        
    end
        
    %%%%头动校正
    clear matlabbatch;
    
    for nrun = 1:length(RunList)
        nrun = num2str(nrun);
        
        matlabbatch{1}.spm.spatial.realign.estwrite.data = {cellstr(spm_select('ExtFPListRec', [funcPath '\run' nrun '\'], 'a.*nii'))}'; %经过时间层校正的图像
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
        
        spm_jobman('run', matlabbatch);
        
    end
        
    %结构像与功能像对准
    clear matlabbatch;
    
    for nrun = 1:length(RunList)
        nrun = num2str(nrun);
        
        matlabbatch{1}.spm.spatial.coreg.estwrite.ref = cellstr(spm_select('ExtFPListRec', [funcPath '\run' nrun '\'], 'mean.*nii'))'; %头动校正的平均图像
        matlabbatch{1}.spm.spatial.coreg.estwrite.source = T1w;
        matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
        
        spm_jobman('run', matlabbatch);
        
    end
        
        %组织分割
        
        clear matlabbatch;
        
        matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(spm_select('ExtFPListRec', [anatPath], 'r.*nii'))'; %对齐过的结构像
        matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[SPMPath '\tpm\TPM.nii,1']};
        matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
        matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[SPMPath '\tpm\TPM.nii,2']};
        matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
        matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[SPMPath '\tpm\TPM.nii,3']};
        matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[SPMPath '\tpm\TPM.nii,4']};
        matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[SPMPath '\tpm\TPM.nii,5']};
        matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[SPMPath '\tpm\TPM.nii,6']};
        matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
        matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
        matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
            NaN NaN NaN];
        
        spm_jobman('run', matlabbatch);
        
    %配准到MNI152
    clear matlabbatch;
        
    for nrun = 1:length(RunList)
    nrun = num2str(nrun);
        
        DeformF = spm_select('list', [anatPath], 'y.*nii'); %形变场图，结构像文件夹下y开头的.nii文件
        matlabbatch{1}.spm.spatial.normalise.write.subj.def = {strcat([anatPath], '\', DeformF)}';
        
        data_r = [];  %定义一个空矩阵用来装所有的功能像
        rList = spm_select('ExtFPListRec', [funcPath '\run' nrun '\'], 'ra.*nii'); %经过头动校正的功能像
        rListS = cellstr(rList);
        data_r = [data_r;rListS]; %将所有功能像粘成一列
        
        rList = []; rListS = [];  %清除此两个变量的值，为下一循环准备
        
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = data_r;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
            90 90 108];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        spm_jobman('run', matlabbatch);
        
    end

        
    %空间平滑
    clear matlabbatch;
        
    for nrun = 1:length(RunList)
    nrun = num2str(nrun);
    
    
        data_w = [];  %定义一个空矩阵用来装所有的功能像
        wList = spm_select('ExtFPListRec', [funcPath '\run' nrun '\'], 'wra.*nii'); %经过标准化的功能像
        wListS = cellstr(wList);
        data_w = [data_w;wListS]; %将所有功能像粘成一列
        
        wList = []; wListS = [];  %清除此两个变量的值，为下一循环准备
    
        matlabbatch{1}.spm.spatial.smooth.data = data_w;
        matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';
        
        spm_jobman('run', matlabbatch);

    end

end