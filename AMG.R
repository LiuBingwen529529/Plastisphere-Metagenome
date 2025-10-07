# 加载文件
gene_ko <-read.csv("/Users/lbw/Desktop/gene_ko.csv",stringsAsFactors=F, header = F, col.names = c("gene", "ko1", "ko2"))
ko_pathway <-read.csv("/Users/lbw/Desktop/ko_pathway.csv",stringsAsFactors=F, header = F, col.names = c("ko", "path"))
filtered_rpkm <-read.csv("/Users/lbw/Desktop/filtered_rpkm.csv",stringsAsFactors=F, header = T)
filteredAMG_host <- read.csv("/Users/lbw/Desktop/filteredAMG_host.csv",stringsAsFactors=F, header = T)
vir_host <- read.csv("/Users/lbw/Desktop/combined_unique.csv",stringsAsFactors=F, header = T)

# 处理gene_ko
gene_ko$ko <- ifelse(is.na(gene_ko$ko1) |gene_ko$ko1 == "", 
                     gene_ko$ko2, 
                     gene_ko$ko1)
gene_ko <- gene_ko[, c("gene", "ko")]

# 加上pathway
library(dplyr)
gene_ko_pathway <- gene_ko %>%
  left_join(ko_pathway, by = "ko") 
write.csv(gene_ko_pathway, file = "/Users/lbw/Desktop/gene_ko_pathway.csv")

# 拆分多路径为单独的行
library(tidyr)
split_data <- separate_rows(gene_ko_pathway, path, sep = ";")
# 统计每个path的基因数量
path_counts <- as.data.frame(table(split_data$path))
colnames(path_counts) <- c("Path", "Gene_Count")
# 按基因数量降序排序
path_counts <- path_counts[order(-path_counts$Gene_Count), ]
write.csv(path_counts, file = "/Users/lbw/Desktop/path_counts.csv")

# 合并split_data和基因丰度
split_rpkm <- split_data %>%
  left_join(filtered_rpkm, by = "gene") 
write.csv(split_rpkm, file = "/Users/lbw/Desktop/split_rpkm.csv")


# 不同path的丰度
# 确定样本列范围（从第四列开始到最后一列）
sample_cols <- colnames(split_rpkm)[4:ncol(split_rpkm)]

# 按path分组并计算每个样本的总和
path_abundance <- split_rpkm %>%
  group_by(path) %>%
  summarise(across(all_of(sample_cols), sum, na.rm = TRUE)) %>%
  ungroup()
write.csv(path_abundance, file = "/Users/lbw/Desktop/path_abundance.csv")


# AMG和host的对应关系
split_host <- seperate_rows(filteredAMG_host, gene, seq = ";")
split_host <- separate_rows(split_host, virus, sep = ";")
write.csv(split_host, file = "/Users/lbw/Desktop/split_host.csv")
expanded_merged <- split_host %>%
  left_join(vir_host, by = "virus")
write.csv(expanded_merged, file = "/Users/lbw/Desktop/expanded_merged.csv")
