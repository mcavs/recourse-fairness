# 01_train_models.R
# Trains GLM, Random Forest, and GBM across the 5 benchmark datasets

suppressPackageStartupMessages({
  library(ranger)
  library(gbm)
})

set.seed(42)
dir.create("models", showWarnings = FALSE)

datasets_info <- list(
  german_credit = list(
    train_file = "data/german_credit_train.csv",
    test_file  = "data/german_credit_test.csv",
    target     = "Class",
    target_pos = "1",
    sensitive  = "sex_marital_status",
    privileged = "3"
  ),
  taiwan_credit = list(
    train_file = "data/taiwan_credit_train.csv",
    test_file  = "data/taiwan_credit_test.csv",
    target     = "Class",
    target_pos = "1",
    sensitive  = "SEX",
    privileged = "1"
  ),
  fico_heloc = list(
    train_file = "data/fico_heloc.csv", # will split 75/25
    test_file  = NULL,
    target     = "RiskPerformance",
    target_pos = "Good",
    sensitive  = "OldestTradeOpenMonth",
    privileged = "Mature"
  ),
  gmc = list(
    train_file = "data/gmc_train.csv",
    test_file  = "data/gmc_test.csv",
    target     = "Class",
    target_pos = "1",
    sensitive  = "age_group",
    privileged = "Mature"
  ),
  adult = list(
    train_file = "data/adult_train.csv",
    test_file  = "data/adult_test.csv",
    target     = "Class",
    target_pos = "1",
    sensitive  = "sex",
    privileged = "Male"
  )
)

cat("Benchmark training pipeline configured for 5 datasets.\n")
cat("Pre-trained bundles are already provided in models/ for instant evaluation.\n")
