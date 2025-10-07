# 读取数据
VHR<-read.csv("/Users/lbw/Desktop/defense_VHR.csv",head=T,stringsAsFactors=F)
defense<-read.csv("/Users/lbw/Desktop/defense_system_count.csv",head=T,stringsAsFactors=F)
library(dplyr)
result <- VHR %>%
  left_join(defense, by = "MAG") 
write.csv(result, file = "/Users/lbw/Desktop/defense_system_VHR.csv")
