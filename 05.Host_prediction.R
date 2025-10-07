# 读取数据
crisper <-read.csv("/Users/lbw/Desktop/crisper.csv",head=T,stringsAsFactors=F)
tRNA <-read.csv("/Users/lbw/Desktop/tRNA.csv",head=T,stringsAsFactors=F)
homology <-read.csv("/Users/lbw/Desktop/homology.csv",head=T,stringsAsFactors=F)
crisper <- crisper[, c("Virus", "MAGs")]
tax <-read.csv("/Users/lbw/Desktop/tax.csv",head=T,stringsAsFactors=F)


# 合并去重
combined_data <- rbind(crisper, tRNA, homology)
combined_unique <- unique(combined_data)
write.csv(combined_unique, file = "/Users/lbw/Desktop/combined_unique.csv")

# 添加注释信息
library(dplyr)
result <- combined_unique %>%
  left_join(tax, by = "MAGs") %>%
  rename(tax = Phylum)
write.csv(result, file = "/Users/lbw/Desktop/result.csv")

# 统计Weight形成edgetable
df <-read.csv("/Users/lbw/Desktop/result.csv",head=T,stringsAsFactors=F)
df_with_weight <- df %>%
  group_by(Virus, tax) %>%
  mutate(weight = n()) %>%
  ungroup()
df_with_weight <- df_with_weight %>% select(-c(MAGs, X))
df_with_weight <- unique(df_with_weight)
write.csv(df_with_weight, file = "/Users/lbw/Desktop/df_with_weight.csv")

# 做node_table
library(dplyr)
new_df <- bind_rows(
  combined_unique %>% 
    distinct(Virus) %>% 
    rename(name = Virus) %>% 
    mutate(type = "Virus"),
  
  combined_unique %>% 
    distinct(MAGs) %>% 
    rename(name = MAGs) %>% 
    mutate(type = "MAGs")
) %>% 
  arrange(type, name)  # 按类型和名称排序
write.csv(new_df, file = "/Users/lbw/Desktop/node_table_2.csv")

new_df <- bind_rows(
  df_with_weight %>% 
    distinct(Virus) %>% 
    rename(name = Virus) %>% 
    mutate(type = "virus"),
  
  df_with_weight %>% 
    distinct(tax) %>% 
    rename(name = tax) %>% 
    mutate(type = "tax")
) %>% 
  arrange(type, name)  # 按类型和名称排序
write.csv(new_df, file = "/Users/lbw/Desktop/node_table.csv")

# 添加lifestyle
node <-read.csv("/Users/lbw/Desktop/node_table.csv",head=T,stringsAsFactors=F)
lifestyle <-read.csv("/Users/lbw/Desktop/lifestyle.csv",head=T,stringsAsFactors=F)
node_lif <- node %>%
  left_join(lifestyle, by = "node") 
write.csv(node_lif, file = "/Users/lbw/Desktop/node_life.csv")






# 统计specialist(第一张/combined_unique)
combined_unique <-read.csv("/Users/lbw/Desktop/combined_unique.csv",head=T,stringsAsFactors=F)
library(dplyr)
result <- combined_unique %>%
  group_by(Virus) %>%
  summarise(Count = n()) %>%
  mutate(Type = ifelse(Count == 1, "specialist", "generalist"))
type_summary <- result %>%
  group_by(Type) %>%
  summarise(Total = n())
print(type_summary)






# 统计病毒所属的门(第二张)
df_with_weight <-read.csv("/Users/lbw/Desktop/df_with_weight.csv",head=T,stringsAsFactors=F)
# 统计 tax 列每个类别的出现次数
library(dplyr)
tax_count <- df_with_weight %>%
  group_by(tax) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count))  # 按出现次数降序排列
print(tax_count)
write.csv(tax_count, file = "/Users/lbw/Desktop/tax_count.csv")

#添加lifestyle
df_with_weight <- df_with_weight %>%
  left_join(lifestyle, by = "Virus") 
write.csv(df_with_weight, file = "/Users/lbw/Desktop/df_with_weight.csv")
library(tidyr)
# 按 tax 分组，统计各 Lifestyle 数量
result <- df_with_weight %>%
  group_by(tax, Lifestyle) %>%
  summarise(Count = n(), .groups = "drop") %>%  # 分组统计
  pivot_wider(                                  # 转换为宽表格
    names_from = Lifestyle,
    values_from = Count,
    values_fill = 0                            # 缺失值填充为 0
  ) %>%
  arrange(tax)                                  # 按 tax 字母顺序排序

write.csv(result, file = "/Users/lbw/Desktop/phylum_lifestyle.csv")

# 添加specialist
combined_unique <-read.csv("/Users/lbw/Desktop/combined_unique.csv",head=T,stringsAsFactors=F)

result <- combined_unique %>%
  group_by(Virus) %>%             # 按 Virus 分组
  summarise(Count = n()) %>%       # 计算出现次数
  mutate(Type = ifelse(Count == 1, "specialist", "generalist")) %>%  # 分类
  arrange(Virus)

df_with_weight <- df_with_weight %>%
  left_join(result, by = "Virus") 

spe_result <- df_with_weight %>%
  group_by(tax, Type) %>%
  summarise(Count = n(), .groups = "drop") %>%  # 分组统计
  pivot_wider(                                  # 转换为宽表格
    names_from = Type,
    values_from = Count,
    values_fill = 0                            # 缺失值填充为 0
  ) %>%
  arrange(tax)                                  # 按 tax 字母顺序排序
write.csv(spe_result, file = "/Users/lbw/Desktop/phylum_specialist.csv")

# 统计每个门的hostMAG数量
node_table <-read.csv("/Users/lbw/Desktop/node_table_2.csv",head=T,stringsAsFactors=F)
tax <-read.csv("/Users/lbw/Desktop/tax.csv",head=T,stringsAsFactors=F)
host_count <- node_table %>%
  left_join(tax, by = "MAGs") 

library(dplyr)
phylum_counts <- host_count %>%
  group_by(Phylum) %>%
  summarise(tax_Count = n()) %>%
  arrange(desc(tax_Count))#hostMAG

tax_count <- tax %>%
  group_by(Phylum) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count))#allAMG

host_ratio <- phylum_counts %>%
  left_join(tax_count, by = "Phylum") 

host_ratio$ratio <- host_ratio$tax_Count / host_ratio$Count
write.csv(host_ratio, file = "/Users/lbw/Desktop/host_ratio.csv")

# 统计网络拓扑结构
# 安装加载依赖包
install.packages("bipartite")
library(bipartite)

# 转换为邻接矩阵
adj_matrix <- matrix(as.numeric(table(df_with_weight$tax, df_with_weight$Virus)),nrow = nrow(table(df_with_weight$tax, df_with_weight$Virus)),dimnames = dimnames(table(df_with_weight$tax, df_with_weight$Virus)))

# 计算网络指标（如连接性、模块性、嵌套性等）
network_metrics <- networklevel (adj_matrix, index = c("connectance", "nestedness", "modularity"))

# 输出结果
print(network_metrics)
