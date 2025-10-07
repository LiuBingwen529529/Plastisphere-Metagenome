# 安装必要包
if (!require("minpack.lm")) install.packages("minpack.lm")
if (!require("ggplot2")) install.packages("ggplot2")
library(minpack.lm)
library(ggplot2)

# 数据
df <- read.csv("/Users/lbw/Desktop/defensesystem_ARG.csv",stringsAsFactors=F, header = T)
df <- read.csv("/Users/lbw/Desktop/defensesystem_VFG.csv",stringsAsFactors=F, header = T)

# 定义指数衰减模型
exp_decay <- function(x, a, b, c) {
  a * exp(-b * x) + c
}

# 初始参数估计（重要！）
# a ≈ y峰值 - 基线值 ≈ 48 - 3 = 45
# b ≈ 衰减速率：从x0到x1变化率 ≈ ln(48/39) ≈ 0.21
# c ≈ 尾部平均值 ≈ 2
init_params <- list(a = 45, b = 0.21, c = 2)

# 拟合模型（使用更稳健的Levenberg-Marquardt算法）
fit <- nlsLM(
  y ~ exp_decay(x, a, b, c),
  data = df,
  start = init_params,
  control = nls.lm.control(maxiter = 500)
)

# 结果汇总
summary(fit)
coe <- coef(fit)
cat(sprintf("\n拟合方程: y = %.2f * exp(-%.4f * x) + %.2f\n", coe['a'], coe['b'], coe['c']))

# 计算R²
predicted <- predict(fit)
rsq <- 1 - sum((df$y - predicted)^2) / sum((df$y - mean(df$y))^2)
cat(sprintf("拟合优度 R² = %.4f\n", rsq))

# 可视化
ggplot(df, aes(x, y)) +
  geom_point(size = 1.5, color = "black") +
  geom_smooth(
    method = "nls",
    formula = y ~ a * exp(-b * x) + c,
    method.args = list(start = init_params),
    se = FALSE,
    color = "blue"
  ) +
  labs(title = sprintf("指数衰减拟合: y = %.1f * e^{-%.3f*x} + %.1f", 
                       coe['a'], coe['b'], coe['c']),
       subtitle = sprintf("R² = %.3f", rsq),
       x = "x", y = "y") +
  theme_bw() +
  theme(
    # 移除所有网格线
    panel.grid.major = element_blank(),  # 移除主要网格线
    panel.grid.minor = element_blank(),  # 移除次要网格线
    # 可选：调整背景和边框
    panel.background = element_rect(fill = "white", colour = "black"),  # 白色背景+黑色边框
    plot.background = element_rect(fill = "white")  # 白色绘图区域背景
  ) +
  geom_hline(yintercept = coe['c'], linetype = "dashed", color = "gray") +
  annotate("text", x = max(df$x), y = coe['c'], 
           label = sprintf("基线 = %.1f", coe['c']), vjust = -1)

# 残差分析
residuals <- df$y - predicted
plot(predicted, residuals, main = "残差分析",
     xlab = "预测值", ylab = "残差")
abline(h = 0, col = "red")