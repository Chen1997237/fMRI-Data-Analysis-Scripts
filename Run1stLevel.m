%-----------------------------------------------------------------------
%SPM批处理脚本
%一阶分析
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%%清屏&清空工作区变量
clc
clear
spm fmri

%%数据路径
datadir = 'G:\processing';

%%被试编号
subjects = [008 009 010 011 012 013 014];
        
%需要处理的run
RunList = {'run1' 'run2' 'run3' 'run4' 'run5' 'run6' 'run7' 'run8'};

%条件编号
CondList = {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' '13'};

%建立被试循环
for ID = subjects
    ID = num2str(ID, '%03d');
    
    %检查每个被试文件夹下是否有'1st_Level'文件夹，如果没有，则新建一个
    SubOutput = char(strcat(datadir, '\sub-', ID, '\1st_Level'));
    if ~exist(SubOutput)
            mkdir(SubOutput);
    end
    
    %扫描和预处理的参数设置
    matlabbatch{1}.spm.stats.fmri_spec.dir = {SubOutput}; %设置一阶分析存放路径
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs'; %视onset计算方法而定，一般都设置为secs
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2; %TR时间
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 40; %扫描层数
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 2; %做时间层校正时的参考层数

    %进行run之间的循环
    for nrun = 1:length(RunList)
        
        clear Files FileList FilePath;
        
        %预处理之后的图像路径
        FilePath = char(strcat(datadir, '\sub-', ID, '\func\run', string(nrun)));
        FileList = dir(fullfile(FilePath,'swra*.nii'));
        
        for nfile = 1:length(FileList)
            Files(nfile) = {fullfile(FilePath,FileList(nfile).name)};
        end
        %读取图像
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).scans = cellstr(Files)';
        
        %读取onset
        onsetspath = strcat(datadir, '\sub-', ID, '\func\onset_run', string(nrun), '.xlsx');
        onsets = readtable(onsetspath); 
        
        %条件循环
        cond_num = length(CondList);
        for ncond = 1:cond_num
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).name = CondList{ncond};
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).onset = onsets.onset(onsets.label==ncond);
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).duration = onsets.duration(onsets.label==ncond);
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).orth = 1;
        end
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).regress = struct('name', {}, 'val', {});
        
        %把头动参数加入模型
        motionpath = strcat(datadir, '\sub-', ID, '\func\run', string(nrun), '\');
        motion_file = spm_select('list', motionpath, 'rp.*txt');
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).multi_reg = cellstr(strcat(motionpath, motion_file));
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).hpf = 128;
        
    end
        
    %参数估计
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(SubOutput,'SPM.mat')}; %载入模型.mat文件
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
      
    %%建立对比
    matlabbatch{3}.spm.stats.con.spmmat = {fullfile(SubOutput,'SPM.mat')}; %载入模型.mat文件
    %对比1
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'F-UF';  %对比名称
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 1 1 1 1 1 -1 -1 -1 -1 -1 -1 0 0 0 0 0 0 0];  %对比权重
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';  %重复到其他的run
    %对比2
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'FNA-FRA';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';
    %对比3
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'UFNA-UFRA';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'replsc';
    %对比4
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'FN0-FR0';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'replsc';
    %对比5
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'UFN0-UFR0';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'replsc';
    %对比6
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'FN7-FR7';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 -1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'replsc';
    %对比7
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'UFN7-UFR7';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 0 0 0 -1 0 0 1 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'replsc';
    %对比8
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = '7-A';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [-1 0 1 -1 0 1 -1 0 1 -1 0 1 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'replsc';
    %对比9
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = '0-A';
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [-1 1 0 -1 1 0 -1 1 0 -1 1 0 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'replsc';
    %对比10
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = '7-0';
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [0 -1 1 0 -1 1 0 -1 1 0 -1 1 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'replsc';
    %对比11
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'R-N';
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.weights = [1 1 1 -1 -1 -1 1 1 1 -1 -1 -1 0 0 0 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'replsc';
    
    matlabbatch{3}.spm.stats.con.delete = 0;
        
    spm_jobman('run', matlabbatch);

end
