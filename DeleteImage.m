% PreDeleteData

clear
clc

imgdir = 'G:\processing'; %% Nifti file folder
SubList = dir(fullfile(imgdir,'sub*')); % text that can recognize folders for all participants

for subj = 1:length(SubList)
    SubList(subj).name
    subjpath = dir(fullfile(imgdir,SubList(subj).name));
    RunList = dir(fullfile(imgdir,SubList(subj).name, 'func/', 'run*'));% text that can recognize folders for all runs
    
    for run = 1:length(RunList)

                funcpath = fullfile(imgdir,SubList(subj).name,'func/',RunList(run).name);
                anatpath = fullfile(imgdir,SubList(subj).name,'anat/');
                
                % List file names that you want to delete
                meanfile = dir(fullfile(funcpath,'mean*.nii')); % text that can recognize files you want to delete
                rpfile = dir(fullfile(funcpath,'rp*.txt'));
                wwwfile = dir(fullfile(funcpath,'mask.*'));
                afile = dir(fullfile(funcpath,'a*.nii'));
                rafile = dir(fullfile(funcpath,'ra*.nii'));
                wrafile = dir(fullfile(funcpath,'wra*.nii'));
                sssfile = dir(fullfile(funcpath,'swra*.nii'));
                matfile = dir(fullfile(funcpath,'*.mat')); 
                
                matfile1 = dir(fullfile(anatpath,'*.mat')); 
                c1file = dir(fullfile(anatpath,'c1*.nii')); 
                c2file = dir(fullfile(anatpath,'c2*.nii')); 
                c3file = dir(fullfile(anatpath,'c3*.nii')); 
                c4file = dir(fullfile(anatpath,'c4*.nii')); 
                c5file = dir(fullfile(anatpath,'c5*.nii')); 
                mfile = dir(fullfile(anatpath,'m*.nii')); 
                rfile = dir(fullfile(anatpath,'r*.nii')); 
                y_file = dir(fullfile(anatpath,'y_*.nii')); 
                
                
                
                cd(funcpath);
                % Change this part according to folder name part
                if ~isempty(meanfile)
                    delete(meanfile.name);
                end
                if ~isempty(rpfile)
                    delete(rpfile.name);
                end
                if ~isempty(wwwfile)
                    delete(wwwfile.name);
                end
                if ~isempty(afile)
                    delete(afile.name);
                end
                if ~isempty(rafile)
                    delete(rafile.name);
                end
                if ~isempty(wrafile)
                    delete(wrafile.name);
                end
                
                if ~isempty(sssfile)
                    delete(sssfile.name);
                end
                if ~isempty(matfile)
                    delete(matfile.name);
                end
                
                cd(anatpath);
               % Change this part according to folder name part
                 if ~isempty(matfile1)
                    delete(matfile1.name);
                end
                if ~isempty(c1file)
                    delete(c1file.name);
                end
                if ~isempty(c2file)
                    delete(c2file.name);
                end
                if ~isempty(c3file)
                    delete(c3file.name);
                end
                if ~isempty(c4file)
                    delete(c4file.name);
                end
                if ~isempty(c5file)
                    delete(c5file.name);
                end
                
                if ~isempty(mfile)
                    delete(mfile.name);
                end
                if ~isempty(rfile)
                    delete(rfile.name);
                end
                if ~isempty(y_file)
                    delete(y_file.name);
                end
    end
end
cd(imgdir);

