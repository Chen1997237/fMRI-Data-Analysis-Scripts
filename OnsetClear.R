# 清除结果区数据
rm(list = ls())

#设置工作路径
setwd("/Users/nuc/behavioral_gff")

#载入包
library(readxl)
library(tidyverse)
library(xlsx)

# 读入原始数据
Data <- read_excel("3SD.xlsx", sheet = "Sheet1")
myvars <- c("Sub", "label", "ACC", "Duration", "RT", "Onset", "Run")
names(Data) <- myvars

#将正确率为0的试次条件列为13
Data$label = ifelse(Data$ACC == 0 , '13', Data$label)

#将反应时在三个标准差之外的试次列为13
Var2 <- c("Sub", "label")
Data1 <- unite(Data, "Var", all_of(Var2), sep = "", remove = FALSE)
Conditions <- levels(as.factor(Data1$Var))
Data.Blank <- vector()
for (i in Conditions) {
  D.Step <- subset(Data1, Var == i)
  D.Step$label = ifelse(D.Step$RT > ((mean(D.Step$RT) + 3 * sd(D.Step$RT))), '13', D.Step$label)
  D.Step$label = ifelse(D.Step$RT < ((mean(D.Step$RT) - 3 * sd(D.Step$RT))), '13', D.Step$label)
  Data.Blank <- rbind(Data.Blank, D.Step)
}

#计算错误试次的百分比
Data.Cleaned <- subset(Data.Blank, select = -Var)
ErrorNum <- subset(Data.Cleaned, label == 13)
AllNum <- length(Data$Onset)
LastNum <- length(ErrorNum$Onset)
RejectRate <- (LastNum / AllNum) * 100
print(paste("RejectRate =", RejectRate, "%"))


#保存成Excel
write.xlsx(Data.Cleaned, file = "OnsetsCleaned.xlsx")

