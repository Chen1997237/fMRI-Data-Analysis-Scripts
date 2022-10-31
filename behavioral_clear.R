##### 前期准备#####

#安装所需要的程序包，去掉 # 并修改程序包名称即可使用

#install.packages("readxl")
#install.packages("bruceR")
#install.packages("tidyr")

# 清除结果区数据
rm(list = ls())

# 设置存放数据的路径
setwd("/Users/nuc/behavioral_gff")

##### 导入并原始数据并进行整理#####

# 读入原始数据
library(readxl)
Data.raw <- read_excel("RawData.xlsx", sheet = "Sheet1")

# 从原始数据中指定需要的部分并整理数据
library(plyr)
myvars <- c("Sub", "label", "ACC", "RT")
names(Data.raw) <- myvars

### 保留反应正确试次###
#D.Corr <- subset(Data.raw, ACC == 1 & RT >= 150)
D.Corr <- Data.raw
#### 剔除反应时异常（三个标准差之外）的试次###
library(tidyr)
Var2SD <- c("Sub", "label")
D.In2SD <- unite(D.Corr, "Var", all_of(Var2SD), sep = "", remove = FALSE)
Conditions <- levels(as.factor(D.In2SD$Var))
D.Blank <- vector()
for (i in Conditions) {
  D.Step1 <- subset(D.In2SD, Var == i)
  D.Step2 <- D.Step1[D.Step1$RT < (mean(D.Step1$RT) + 3 * sd(D.Step1$RT)), ]
  D.Step3 <- D.Step2[D.Step2$RT > (mean(D.Step1$RT) - 3 * sd(D.Step1$RT)), ]
  D.Blank <- rbind(D.Blank, D.Step3)
}

### 计算被剔除数据的百分比###
AllNum <- length(Data.raw$Sub)
LastNum <- length(D.Blank$Sub)
RejectRate <- (1 - round(LastNum / AllNum, 4)) * 100
print(paste("RejectRate =", RejectRate, "%"))

#保存数据
cleanvar <- c("Sub", "label", "ACC", "RT")
CleanData <- subset(D.Blank, select = cleanvar)

library(xlsx)
write.xlsx(CleanData, file = "CleanData.xlsx", row.names = TRUE)
