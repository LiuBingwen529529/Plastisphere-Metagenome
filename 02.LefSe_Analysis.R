
# 加载依赖包
library(microeco)
library(tidytree)
library(ggtree)
library(ggplot2)

# 设置工作目录并加载数据文件
otu_table <- read.csv("/Users/lbw/Desktop/otu_table.csv", row.names =1, stringsAsFactors =FALSE, check.names =FALSE, header =TRUE)
group <- read.csv("/Users/lbw/Desktop/group.csv", row.names = 1, stringsAsFactors = FALSE)
tax <- read.csv("/Users/lbw/Desktop/tax.csv", row.names = 1, stringsAsFactors = FALSE, check.names = FALSE, header = TRUE)

# 创建数据集用于 LEfSe 分析
dataset <- microtable$new(sample_table = group, # 分组信息
                          otu_table = otu_table, # OTU 表
                          tax_table = tax) # 分类信息

# 进行 LEfSe 分析
lefse_result <- trans_diff$new(dataset = dataset, # 输入的微生物组数据集
                               method ="lefse", # 使用 LEfSe 方法
                               group = "group", # 指定分组列
                               alpha = 0.05, # 显著性水平
                               lefse_subgroup = NULL) # 子组分类（如果有的话）)

# 导出 LEfSe 分析结果
write.csv(lefse_result$res_diff,"/Users/lbw/Desktop/lefse_result.csv")

# 绘制前20个LDA值最高的差异特征的柱状图
LDA_20 <- lefse_result$plot_diff_bar(use_number = 1:50,
                                     width = 0.7,
                                     c("#8E0F31","#75D5DF","#EB8E47","#a1a2cb","#6d6f6e","#41915c","#376eae"),
                                     group_order = c("PP","PET","PVC","PLA","PHA","Water","Sediment"))
LDA_20

LDA_50<-lefse_result$plot_diff_cladogram(use_taxa_num = 100,#显示丰度最高的40个分类群
                                         use_feature_num = 50, #显示30个差异特征
                                         clade_label_level = 4, #用字母标记标签的分类层级，5表示目，4表示科。
                                         group_order = c("PP","PET","PVC","PLA","PHA","Water","Sediment"),#组间排序
                                         color = c("#8E0F31","#75D5DF","#EB8E47","#a1a2cb","#6d6f6e","#41915c","#376eae"),#颜色
                                         select_show_labels = c("p_Nitrospirota","p_Proteobacteria","p_Bacteroidota"," p_Myxococcota"," p_Acidobacteriota"," p_Desulfobacterota_E","p_Actinobacteriota"),
                                         only_select_show = FALSE,# 设置为TRUE，可以只展示select_show_labels选择的分类单元标签
                                         sep = "|",#识别的辨识字符间隔
                                         branch_size = 6,
                                         alpha = 0.2,
                                         clade_label_size = 2)
LDA_50


