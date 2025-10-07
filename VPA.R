# 加载必要的包
library(vegan)
library(tidyverse)
install.packages("tidyverse")

# 加载文件
ARG_var <-read.csv("/Users/lbw/Desktop/summarizedARG_with_class.csv",head=T,stringsAsFactors=F,row.names = 1)
VFG_var <-read.csv("/Users/lbw/Desktop/summarized_VFG_chiplot.csv",head=T,stringsAsFactors=F,row.names = 1)

Bac_exp <-read.csv("/Users/lbw/Desktop/combined_rpkm.csv",head=T,stringsAsFactors=F,row.names = 1)
Vir_exp <-read.csv("/Users/lbw/Desktop/vOTUs_rpkm.csv",head=T,stringsAsFactors=F,row.names = 1)
Env_exp <-read.csv("/Users/lbw/Desktop/merged_alpha 2.csv",head=T,stringsAsFactors=F,row.names = 1)
MGE_exp <-read.csv("/Users/lbw/Desktop/filtered_MGE_rpkm.csv",head=T,stringsAsFactors=F,row.names = 1)

# 合并所有解释变量（按列合并）
full_explain <- cbind(
  Bac_exp, 
  Vir_exp,
  Env_exp,
  MGE_exp
)

# 重命名列名以标识来源（可选但推荐）
colnames(full_explain) <- c(
  paste0("Bac_", colnames(Bac_exp)),
  paste0("Vir_", colnames(Vir_exp)),
  paste0("Env_", colnames(Env_exp)),
  paste0("MGE_", colnames(MGE_exp))
)

# 标准化连续变量（跳过分类变量）
full_explain_scaled <- full_explain %>%
  mutate(across(where(is.numeric), scale))

# Hellinger转换（适合组成数据）
arg_hel <- decostand(ARG_var, "hellinger")
vfg_hel <- decostand(VFG_var, "hellinger")

# 创建分组索引（根据列名前缀）
groups <- list(
  Bacteria = grep("Bac_", colnames(full_explain_scaled)),
  Viral = grep("Vir_", colnames(full_explain_scaled)),
  Abiotic = grep("Env_", colnames(full_explain_scaled)),
  MGEs = grep("MGE_", colnames(full_explain_scaled))
)

# 对ARG进行方差分解
varpart_arg <- varpart(
  Y = arg_hel,
  X = full_explain_scaled[, groups$Bacteria],
  full_explain_scaled[, groups$Viral],
  full_explain_scaled[, groups$Abiotic]
)

print(varpart_arg)
print(varpart_vfg)

# 提取调整后的R²值
adjR2_arg <- varpart_arg$part$adj.r.squared
adjR2_vfg <- varpart_vfg$part$adj.r.squared

# 创建结果汇总表
results_df <- data.frame(
  Component = c("Bacteria", "Viral", "Abiotic",
                "Shared"),
  ARG_Explained = c(adjR2_arg["indfract1"], adjR2_arg["indfract2"],
                    adjR2_arg["indfract3"],
                    adjR2_arg["fract0"])
)
 
