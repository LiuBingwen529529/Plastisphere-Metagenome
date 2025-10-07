# 读取数据
df <- read.delim("/Users/lbw/Desktop/defense_system_summary.tsv", header = TRUE, check.names = FALSE)

# 检查MAG总数
total_mags <- nrow(df)
cat("总MAG数量:", total_mags, "\n")

# 任务1: 计算每个防御系统类型的出现比例
type_proportions <- data.frame(
  Type = colnames(df)[2:(ncol(df)-1)],  # 排除第一列(Bin)和最后一列(Total_Systems)
  Proportion = colMeans(df[, 2:(ncol(df)-1)] > 0) * 100
)

# 按比例降序排列
type_proportions <- type_proportions[order(-type_proportions$Proportion), ]

# 输出结果
cat("\n=== 每个防御系统类型在MAG中的出现比例 ===\n")
print(head(type_proportions, 20))  # 显示前20个
write.csv(type_proportions, "defense_type_proportions.csv", row.names = FALSE)

# 任务2: 统计每个防御系统数量的MAG分布
defense_counts <- table(df$Total_Systems)
defense_distribution <- data.frame(
  Defense_Systems = as.numeric(names(defense_counts)),
  MAG_Count = as.vector(defense_counts),
  Proportion = as.vector(defense_counts) / total_mags * 100
)

# 按防御系统数量排序
defense_distribution <- defense_distribution[order(defense_distribution$Defense_Systems), ]

# 输出结果
cat("\n=== 每个防御系统数量的MAG分布 ===\n")
print(defense_distribution)
write.csv(defense_distribution, "/Users/lbw/Desktop/defense_count_distribution.csv", row.names = FALSE)

# 可视化防御系统数量分布
library(ggplot2)
ggplot(defense_distribution, aes(x = Defense_Systems, y = MAG_Count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_text(aes(label = MAG_Count), vjust = -0.3, size = 3.5) +
  labs(title = "MAGs by Number of Defense Systems",
       x = "Number of Defense Systems",
       y = "Number of MAGs") +
  theme_minimal() +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())

ggsave("defense_count_distribution.png", width = 10, height = 6, dpi = 300)

# 任务3: 计算每个防御系统类型在MAG中的平均数量
type_averages <- data.frame(
  Type = colnames(df)[2:(ncol(df)-1)],
  Average_Per_MAG = colMeans(df[, 2:(ncol(df)-1)])
)

# 按平均值降序排列
type_averages <- type_averages[order(-type_averages$Average_Per_MAG), ]

# 输出结果
cat("\n=== 每个防御系统类型在MAG中的平均数量 ===\n")
print(head(type_averages, 20))  # 显示前20个
write.csv(type_averages, "/Users/lbw/Desktop/defense_type_averages.csv", row.names = FALSE)

# 额外分析: 防御系统多样性
# 计算每个MAG的防御系统类型数(不是总数)
df$Type_Count <- rowSums(df[, 2:(ncol(df)-1)] > 0)

# 计算总体平均值
cat("\n=== 总体统计 ===\n")
cat("平均每个MAG的防御系统总数:", mean(df$Total_Systems), "\n")
cat("平均每个MAG的防御系统类型数:", mean(df$Type_Count), "\n")
cat("拥有至少1个防御系统的MAG比例:", mean(df$Total_Systems > 0) * 100, "%\n")

# 保存完整结果
write.csv(df, "full_defense_data_with_type_count.csv", row.names = FALSE)

# 输出热门防御系统
top_systems <- head(type_proportions, 10)
cat("\nTop 10防御系统类型 (按出现比例):\n")
print(top_systems)
