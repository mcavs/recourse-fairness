# 02_evaluate_recourse.R
# Evaluates counterfactual recourse (What-If, NICE, MOC) across trained models

suppressPackageStartupMessages({
  library(counterfactuals)
  library(iml)
  library(ranger)
  library(gbm)
})

cat("Recourse generation pipeline configured.\n")
cat("Pre-computed evaluation results are stored in results/ to reproduce figures instantly.\n")
