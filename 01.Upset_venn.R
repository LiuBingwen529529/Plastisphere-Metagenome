library(UpSetR)
library(tidyr)

# 读取数据
comm<-read.csv("/Users/lbw/Desktop/venn_S.csv",head=T,stringsAsFactors=F,row.names=1)
comm$Sediment <- ifelse(rowSums(comm) > 0, 1, 0)
write.csv(comm, file = "/Users/lbw/Desktop/venn_S.csv")

# 合并0-1矩阵
df2 <-read.csv("/Users/lbw/Desktop/venn_test.csv",head=T,stringsAsFactors=F,row.names=1)
df2 <- df2[, rev(c("PP", "PET", "PVC", "PLA", "PHA", "Water", "Sediment"))]
p <- upset(df2,
           sets= names(df2),   
           keep.order = TRUE,
           nintersects=15,  #展示多少交集   
           point.size=3.5,   
           order.by = "freq", # 排序方式
           decreasing = TRUE,  
           line.size = 0.8,  
           sets.bar.color= "#3b7961",  #左下方柱状图的颜色设置  
           main.bar.col= "#2a83a2",  #上方柱状图的颜色设置
           matrix.color= "black",  
           text.scale = c(3, 2.5, 2, 2, 3, 2),  
           sets.x.label = "Set Size", #左下方柱状图的标题  
           mainbar.y.label  = "Intersection size", #上方柱状图的y轴标题
           queries = list(list(query = elements,       
                          params = list("PP", "PET", "PVC", "PLA", "PHA", "Water", "Sediment"),       
                          color = "#d66a35",       
                          active = TRUE)))
print(p)


