#Onset extraction
#批量导出onsets和duration以便后续的批处理

#设置工作路径为数据存放路径
setwd('/Volumes/File/keyangou/pipeline_scripts/onsets_GXX')

#加载需要的包
library(readxl)

#导入原始数据
data <- read_excel('huizong1.xlsx', sheet = 'Sheet1')

#建立矩阵
onset_num = 8 ##每个被试的条件数*2（分别是每个条件的onset和duration）

#每个被试有几个run
run_num=4

#被试数量
sub_num=9 

#27改成每个run的试次数目
onset = matrix(,onset_num*run_num*sub_num,27)
#1不用改
name = matrix(,onset_num*run_num*sub_num,1) 

#循环进行所有被试的onsets和duration抽取
allsub = unique(data$Subject)

k=0

for (nsub in allsub) 
{
  
  
  subdata = subset(data,data$Subject==nsub)
  
  
  allrun = unique(subdata$Run)
  
  for (nrun in allrun){
    
    rundata = subset(subdata,subdata$Run==nrun)
    
    ###这里分别是onset和duration提取
    #onset：有几个条件就设置几行
    name[(k)*onset_num*run_num+(nrun-1)*onset_num+1,1] = as.character(paste("sub",nsub,"_run",nrun,"_DIR_onset",sep=""))
    name[(k)*onset_num*run_num+(nrun-1)*onset_num+2,1] = as.character(paste("sub",nsub,"_run",nrun,"_INDIR_onset",sep=""))
    name[(k)*onset_num*run_num+(nrun-1)*onset_num+3,1] = as.character(paste("sub",nsub,"_run",nrun,"_FS_onset",sep=""))
    name[(k)*onset_num*run_num+(nrun-1)*onset_num+4,1] = as.character(paste("sub",nsub,"_run",nrun,"_ERROR_onset",sep=""))
    #duration：有几个条件就设置几行
    name[(k)*onset_num*run_num+(nrun-1)*onset_num+5,1] = as.character(paste("sub",nsub,"_run",nrun,"_DIR_duration",sep=""))
    name[(k)*onset_num*run_num+(nrun-1)*onset_num+6,1] = as.character(paste("sub",nsub,"_run",nrun,"_INDIR_duration",sep=""))
    name[(k)*onset_num*run_num+(nrun-1)*onset_num+7,1] = as.character(paste("sub",nsub,"_run",nrun,"_FS_duration",sep=""))
    name[(k)*onset_num*run_num+(nrun-1)*onset_num+8,1] = as.character(paste("sub",nsub,"_run",nrun,"_ERROR_duration",sep=""))
    
    
    ###########################################
    
    Normal_data=subset(rundata,rundata$question.RT!=0 | rundata$question.ACC!=0)  ##去除错误/无响应的试次
    
    DIR_data = subset(Normal_data,Normal_data$cond=='DIR')
    INDIR_data = subset(Normal_data,Normal_data$cond=='INDIR')
    FS_data = subset(Normal_data,Normal_data$cond=='FS')
    
    Errordata=subset(rundata,rundata$question.ACC==0 | rundata$question.ACC==0)  ##挑出错误/无响应的试次
    
    ##########################################
    
    onset[(k)*onset_num*run_num+(nrun-1)*onset_num+1,1:nrow(DIR_data)] = DIR_data$Onsets 
    onset[(k)*onset_num*run_num+(nrun-1)*onset_num+2,1:nrow(INDIR_data)] = INDIR_data$Onsets
    onset[(k)*onset_num*run_num+(nrun-1)*onset_num+3,1:nrow(FS_data)] = FS_data$Onsets
    
    onset[(k)*onset_num*run_num+(nrun-1)*onset_num+5,1:nrow(DIR_data)] = DIR_data$Duration
    onset[(k)*onset_num*run_num+(nrun-1)*onset_num+6,1:nrow(INDIR_data)] = INDIR_data$Duration
    onset[(k)*onset_num*run_num+(nrun-1)*onset_num+7,1:nrow(FS_data)] = FS_data$Duration
    
    if (nrow(Errordata)!=0){
      onset[(k)*onset_num*run_num+(nrun-1)*onset_num+4,1:nrow(Errordata)] = Errordata$Onsets
    }
    
    if (nrow(Errordata)!=0){
      onset[(k)*onset_num*run_num+(nrun-1)*onset_num+8,1:nrow(Errordata)] = Errordata$Duration
    }
    
    
    ##############################
    
    
  }
  k=k+1
}

data = cbind(name,onset)

write.table(data,file="onset.txt",quote=F,row.names=F,col.names=F,sep="\t")