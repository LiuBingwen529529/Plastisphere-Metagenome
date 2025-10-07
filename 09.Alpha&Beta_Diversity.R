# 加载包
library(vegan)
library(ggplot2)

# 1. 数据加载
df <- read.csv("/Users/lbw/Desktop/combined_rpkm.csv", row.names = 1)
df_t <- t(df)  # 行为样本，列为MAGs

# 2. Alpha多样性计算
alpha_index <- data.frame(
  Sample = colnames(df),
  Shannon = diversity(df, index = "shannon", MARGIN = 2),
  Simpson = diversity(df, index = "simpson", MARGIN = 2),
  Richness = specnumber(df, MARGIN = 2),
  Pielou = diversity(df, index = "shannon", MARGIN = 2) / log(specnumber(df, MARGIN = 2))  # Pielou公式
)
write.csv(alpha_index, file = "/Users/lbw/Desktop/alpha_idex.csv")

# 3. Beta多样性分析（PCoA）
bray_dist <- vegdist(df_t, method = "bray")
pcoa_result <- cmdscale(bray_dist, k = 3, eig = TRUE)
explained_var <- round(pcoa_result$eig / sum(pcoa_result$eig) * 100, 2)
pcoa_scores <- as.data.frame(pcoa_result$points)
colnames(pcoa_scores) <- c("PCoA1", "PCoA2", "PCoA3")
write.csv(pcoa_scores, file = "/Users/lbw/Desktop/pcoa_scores.csv")

# 4. 合并分组信息
group_info <- read.csv("/Users/lbw/Desktop/group_2.csv")
pcoa_scores <- merge(pcoa_scores, group_info, by = "Sample")
pcoa_scores <- read.csv("/Users/lbw/Desktop/pcoa_scores.csv")

# 5. PERMANOVA检验
permanova_result <- adonis2(bray_dist ~ group, data = group_info, permutations = 999)
permanova_text <- paste0("PERMANOVA: R² = ", round(permanova_result$R2[1], 3),
                         ", p = ", ifelse(permanova_result$`Pr(>F)`[1] < 0.001, "<0.001", round(permanova_result$`Pr(>F)`[1], 3)))

# 6. pcoa plot
ggplot(pcoa_scores, aes(PCoA1, PCoA2, color = group)) +
  geom_point(size = 2) +
  stat_ellipse(level = 0.95, linetype = 2) +
  # 调整浅绿色为低饱和度版本 (#B0E0B0)，保持浅紫色 (#D8BFD8)
  scale_color_manual(values = c("#B0E0B0", "#D8BFD8")) +
  labs(
    x = paste0("PCoA1 (", explained_var[1], "%)"),
    y = paste0("PCoA2 (", explained_var[2], "%)")
  ) +
  # 添加PERMANOVA统计文本到图内部（右上角）
  annotate("text",
           x = max(pcoa_scores$PCoA1) * 0.9, 
           y = max(pcoa_scores$PCoA2) * 0.95,
           label = permanova_text,
           size = 3.5, color = "gray30", hjust = 1) +
  theme_minimal(base_size = 12) +  # 整体字体缩小
  theme(
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.8),
    panel.grid = element_blank(),
    legend.title = element_blank(),
    legend.position = "right",
    # 添加刻度线和坐标轴优化
    axis.ticks = element_line(color = "black", linewidth = 0.5),      # 显示刻度线
    axis.ticks.length = unit(0.2, "cm"),                              # 刻度线长度
    axis.line = element_line(color = "black", linewidth = 0.5),       # 坐标轴线
    axis.text = element_text(size = 10, color = "black"),              # 刻度标签字体
    axis.title = element_text(size = 11, face = "bold"),               # 坐标轴标题
    plot.subtitle = element_blank()  # 移除原subtitle位置文字
  )


