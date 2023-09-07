
#### 调用自定义函数OnsetCleaning来进行时间点的计算和整理
rm(list = ls())

## 设置工作路径和载入包
setwd("/Users/nuc/Desktop/Onset")
library(tidyverse)
library(writexl)
library(readxl)
source("OnsetCleaning.R")

## 逐被试和run之间循环
for (s in c(19, 20)) {
  for (r in c(3, 4)) {
    OnsetCleaning(s, r)
  }
}
