###加载包
library(vegan)
library(ggplot2)

###读取数据
otu <- read.csv('/Users/lbw/Desktop/vOTUs_rpkm.csv', row.names = 1)
otu <- data.frame(lapply(otu, function(x) as.numeric(as.character(x))))
otu <- data.frame(t(otu)) 
otu <- ifelse(otu >= 1, 1, 0)####rpkm大于1则为1，小于1则为0


###定义函数
rem_0 <- function(df , num = 1){
  if (num == 1) {#清空一行为零的数据
    df$sum <- rowSums(df)
    df$sum[df$sum == 0] <- NA
    df <- na.omit(df)
    df <- df[,-ncol(df)]
  }
  else if (num == 0) {#清空一列为零的数据
    df <- data.frame(t(df))
    df$sum <- rowSums(df)
    df$sum[df$sum == 0] <- NA
    df <- na.omit(df)
    df <- df[,-ncol(df)]
    df <- data.frame(t(df))
  }
}


####画图
otu <- rem_0(otu,num = 0)
sp <- specaccum(otu, method = 'random')
data <- data.frame(observe = sp$richness, site = 1:nrow(otu),sd = sp[["sd"]])
p <- ggplot(data, aes(site, observe))+
    geom_ribbon(aes(ymin = observe - sd, ymax =observe + sd), fill = "#20B2AA",alpha = 0.3)+
    geom_line(color = "#20B2AA")+
    theme_classic()+
    labs(x = "Sample size", y = "Number of Species")+
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          legend.position = "none")
p

###画图2
plot(sp, ci.type = 'poly', col = 'blue', lwd = 2, ci.lty = 0, ci.col = 'lightblue')
boxplot(sp, col = '#FFC0CB', add = TRUE, pch = '+')

