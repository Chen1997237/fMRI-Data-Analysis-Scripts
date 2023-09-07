##### 将E-Prime导出来的行为数据 #####
##### 自动整理成BIDS格式 #####
##### by Feipeng Chen, 2023-09-06 ######
##### chen455237@foxmail.com ####

### 自定义函数：输入sub和run，返回整理好的时间文件
OnsetCleaning = function(sub, run){
  filename <- paste('sub-',sub,'run',run,'discrimination.xlsx',sep = "",collapse = "NULL")
  df <- read_excel(filename, sheet = "Sheet1")
  df %>%
    ## 长宽格式数据转换：将doudong.OnsetTime和syllable.OnsetTime合并成一列（为了将试次间间隔（ISI）也算做一个条件）
    pivot_longer(c(doudong.OnsetTime, syllable.OnsetTime), 
                 names_to = 'OnsetType', values_to = 'OnsetTime', values_drop_na = FALSE) %>%
    ## 将ACC的数据格式从数字转换成文本以便于逻辑判断
    mutate_at(vars("question.ACC"), as.character) %>%
    ## 新增一列，列名叫trial_type，试次的条件根据条件判断决定
    mutate(
      ## 条件判断
      trial_type = case_when(
        # 若ACC为0（反应错误），且OnsetType为syllable.OnsetTime，则该试次的条件为7
        question.ACC == "0" & OnsetType == "syllable.OnsetTime" ~ "7",
        # 若stim为l开头，且ACC为1，且OnsetType为syllable.OnsetTime，则该试次的条件为1（以此类推）
        if_all(stim, ~ str_detect(.x, "^l")) & question.ACC == "1" & OnsetType == "syllable.OnsetTime" ~ "1",
        if_all(stim, ~ str_detect(.x, "^n")) & question.ACC == "1" & OnsetType == "syllable.OnsetTime" ~ "2",
        if_all(stim, ~ str_detect(.x, "^m")) & question.ACC == "1" & OnsetType == "syllable.OnsetTime" ~ "3",
        if_all(stim, ~ str_detect(.x, "^c")) & question.ACC == "1" & OnsetType == "syllable.OnsetTime" ~ "4",
        if_all(stim, ~ str_detect(.x, "^re")) & question.ACC == "1" & OnsetType == "syllable.OnsetTime" ~ "5",
        # 若OnsetType为doudong.OnsetTime，则该试次的条件为6（空屏）
        OnsetType == "doudong.OnsetTime" ~ "6",
        .default = "other"
      ),
      ## 计算onset和duration（新增两列，列名为onset和duration）
      # onset由刺激出现时间减去指导语消失时间确定
      onset = (OnsetTime - introduction.OffsetTime)/1000-16,
      # duration固定为2.6（根据自己的实验改）
      duration = 2.56
    )%>%
    ## 选择onset, duration, trial_type这三列
    select(onset, duration, trial_type) %>% 
    ## 保存为Excel
    writexl::write_xlsx(paste('sub-',sub,'run',run,'onset.xlsx',sep = "",collapse = "NULL"))
}