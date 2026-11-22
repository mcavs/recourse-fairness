# 04_statistical_tests.R
# Replicates non-parametric Friedman tests reported in Section 4 of the paper

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
})

cat("=================================================================\n")
cat("1. Section 4.1: Friedman Tests across Model Classes\n")
cat("=================================================================\n")

df5 <- read.csv("results/counterfactual_fairness_evaluation_5metrics_n50.csv")

# Directional Disparity formulation
df5 <- df5 %>%
  mutate(
    Priv_Prox = case_when(
      Dataset == "german_credit" ~ G1_Proximity,
      Dataset == "taiwan_credit" ~ G2_Proximity,
      Dataset == "fico_heloc"    ~ G2_Proximity,
      Dataset == "gmc"           ~ G1_Proximity,
      Dataset == "adult"         ~ G1_Proximity
    ),
    Unpriv_Prox = case_when(
      Dataset == "german_credit" ~ G2_Proximity,
      Dataset == "taiwan_credit" ~ G1_Proximity,
      Dataset == "fico_heloc"    ~ G1_Proximity,
      Dataset == "gmc"           ~ G2_Proximity,
      Dataset == "adult"         ~ G2_Proximity
    ),
    Priv_Spars = case_when(
      Dataset == "german_credit" ~ G1_Sparsity,
      Dataset == "taiwan_credit" ~ G2_Sparsity,
      Dataset == "fico_heloc"    ~ G2_Sparsity,
      Dataset == "gmc"           ~ G1_Sparsity,
      Dataset == "adult"         ~ G1_Sparsity
    ),
    Unpriv_Spars = case_when(
      Dataset == "german_credit" ~ G2_Sparsity,
      Dataset == "taiwan_credit" ~ G1_Sparsity,
      Dataset == "fico_heloc"    ~ G1_Sparsity,
      Dataset == "gmc"           ~ G2_Sparsity,
      Dataset == "adult"         ~ G2_Sparsity
    ),
    Priv_Min = case_when(
      Dataset == "german_credit" ~ G1_Minimality,
      Dataset == "taiwan_credit" ~ G2_Minimality,
      Dataset == "fico_heloc"    ~ G2_Minimality,
      Dataset == "gmc"           ~ G1_Minimality,
      Dataset == "adult"         ~ G1_Minimality
    ),
    Unpriv_Min = case_when(
      Dataset == "german_credit" ~ G2_Minimality,
      Dataset == "taiwan_credit" ~ G1_Minimality,
      Dataset == "fico_heloc"    ~ G1_Minimality,
      Dataset == "gmc"           ~ G2_Minimality,
      Dataset == "adult"         ~ G2_Minimality
    ),
    Proximity_Gap  = pmax(0, Unpriv_Prox - Priv_Prox),
    Sparsity_Gap   = pmax(0, Unpriv_Spars - Priv_Spars),
    Minimality_Gap = pmax(0, Unpriv_Min - Priv_Min)
  )

# RQ1: Model class comparison (blocked by Dataset x CE_Method)
df5$Block_RQ1 <- paste(df5$Dataset, df5$CE_Method, sep = "_")
cat("\nFriedman Test: Proximity Gap across Model Classes\n")
print(friedman.test(Proximity_Gap ~ Model | Block_RQ1, data = df5))

cat("\nFriedman Test: Sparsity Gap across Model Classes\n")
print(friedman.test(Sparsity_Gap ~ Model | Block_RQ1, data = df5))

cat("\nFriedman Test: Minimality Gap across Model Classes\n")
print(friedman.test(Minimality_Gap ~ Model | Block_RQ1, data = df5))


cat("\n=================================================================\n")
cat("2. Section 4.2: Friedman Tests across CE Search Paradigms\n")
cat("=================================================================\n")

# RQ2: Explanation paradigm comparison (blocked by Dataset x Model)
df5$Block_RQ2 <- paste(df5$Dataset, df5$Model, sep = "_")
cat("\nFriedman Test: Proximity Gap across CE Paradigms\n")
print(friedman.test(Proximity_Gap ~ CE_Method | Block_RQ2, data = df5))

cat("\nFriedman Test: Sparsity Gap across CE Paradigms\n")
print(friedman.test(Sparsity_Gap ~ CE_Method | Block_RQ2, data = df5))

cat("\nFriedman Test: Minimality Gap across CE Paradigms\n")
print(friedman.test(Minimality_Gap ~ CE_Method | Block_RQ2, data = df5))


cat("\n=================================================================\n")
cat("3. Section 4.3: Friedman Tests across Bias Mitigation Strategies\n")
cat("=================================================================\n")

base_sub <- df5 %>%
  select(Dataset, Model, CE_Method, Proximity_Gap, Sparsity_Gap, Minimality_Gap) %>%
  mutate(Mitigation = "Baseline")

mit_df <- read.csv("results/mitigated_counterfactual_fairness_evaluation_n50.csv") %>%
  filter(Mitigation != "None_Baseline") %>%
  select(Dataset, Model, CE_Method, Mitigation, Proximity_Gap, Sparsity_Gap, Minimality_Gap)

comb_rq3 <- bind_rows(base_sub, mit_df)
comb_rq3$Block_RQ3 <- paste(comb_rq3$Dataset, comb_rq3$Model, comb_rq3$CE_Method, sep = "_")

cat("\nFriedman Test: Proximity Gap across Bias Mitigations (All 45 Blocks)\n")
print(friedman.test(Proximity_Gap ~ Mitigation | Block_RQ3, data = comb_rq3))

cat("\nFriedman Test: Sparsity Gap across Bias Mitigations (All 45 Blocks)\n")
print(friedman.test(Sparsity_Gap ~ Mitigation | Block_RQ3, data = comb_rq3))

cat("\nFriedman Test: Minimality Gap across Bias Mitigations (All 45 Blocks)\n")
print(friedman.test(Minimality_Gap ~ Mitigation | Block_RQ3, data = comb_rq3))
