clear all
clc

%数据路径
DataDir = 'G:\processing\';

%存放一节结果路径
DestDir = 'G:\processing\1stLevel\';

%%被试编号
subjects = [003 008];

%条件名称
CondList = {'F-UF' 'FNA-FRA' 'UFNA-UFRA' 'FN0-FR0' 'UFN0-UFR0' 'FN7-FR7' 'UFN7-UFR7' '7-A' '0-A' '7-0' 'R-N'};

CondNum = length(CondList);

    for ncond = 1:CondNum
        CondPath = char(strcat(DestDir, CondList{ncond}));
        mkdir(CondPath);
        
    end


for ID = subjects
    ID = num2str(ID, '%03d');
    
    OrgDir = char(strcat(DataDir, 'sub-', ID, '\1st_Level\'));
    
    for ncond = 1:CondNum
        CondPath = char(strcat(DestDir, CondList{ncond}));
        ncond000 = num2str(ncond, '%04d');
        conFile = strcat(OrgDir, 'con_', ncond000, '.nii');
        copyfile(conFile, CondPath); 
        OldName = strcat(DestDir, CondList{ncond}, '\con_', ncond000, '.nii');
        NewName = strcat(DestDir, CondList{ncond}, '\sub-', ID, '.nii');
        movefile(OldName, NewName);
    end
       
end