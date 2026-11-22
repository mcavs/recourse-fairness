# Does Predictive Fairness Imply Recourse Fairness? An Empirical Study Across Model Classes and Search Paradigms

This repository contains the replication code, curated benchmark datasets, pre-trained predictive models, and experimental evaluation results for the empirical study auditing counterfactual recourse fairness across machine learning model classes, counterfactual search paradigms, and pre-processing algorithmic fairness interventions.

---

## Repository Structure

```
recourse-fairness/
├── data/                       # Pre-processed benchmark datasets
│   ├── german_credit_train.csv
│   ├── german_credit_test.csv
│   ├── taiwan_credit_train.csv
│   ├── taiwan_credit_test.csv
│   ├── fico_heloc.csv
│   ├── gmc_train.csv
│   ├── gmc_test.csv
│   ├── adult_train.csv
│   └── adult_test.csv
├── models/                     # Pre-trained baseline model bundles (GLM, RF, GBM)
│   ├── german_credit_models.rds
│   ├── taiwan_credit_models.rds
│   ├── fico_heloc_models.rds
│   ├── gmc_models.rds
│   └── adult_models.rds
├── models_mitigated/           # Pre-trained models under bias mitigations
│   ├── german_credit_mitigated_models.rds
│   ├── taiwan_credit_mitigated_models.rds
│   ├── fico_heloc_mitigated_models.rds
│   ├── gmc_mitigated_models.rds
│   └── adult_mitigated_models.rds
├── results/                    # Pre-computed evaluation records
│   ├── counterfactual_fairness_evaluation_5metrics_n50.csv
│   ├── mitigated_counterfactual_fairness_evaluation_n50.csv
│   ├── individual_recourse_evaluations_n50.csv
│   └── pred_fairness_all_60.csv
├── figures/                    # Generated vector figures for the paper
│   ├── fig_recourse_illustration.pdf
│   ├── fig_rq1_model_recourse_gaps.pdf
│   ├── fig_rq2_methods_lollipop.pdf
│   └── fig_rq3_mitigation_gaps.pdf
└── scripts/                    # R execution scripts
    ├── 01_train_models.R
    ├── 02_evaluate_recourse.R
    ├── 03_generate_figures.R
    └── 04_statistical_tests.R
```

---

## Evaluated Benchmark Datasets

| Dataset | Sample Size ($n$) | Features ($d$) | Protected Attribute | Privileged Subgroup | Unprivileged Subgroup |
|:---|:---:|:---:|:---|:---|:---|
| German Credit | 800 | 20 | sex_marital | Male Single | Female / Non-Single |
| Taiwan Credit | 7,000 | 23 | SEX | Male | Female |
| FICO HELOC | 7,000 | 23 | OldestTrade | Mature (>= 180 mos.) | Young (< 180 mos.) |
| Give Me Credit | 25,000 | 10 | age | Mature (>= 35 yrs.) | Young (< 35 yrs.) |
| Adult Income | 32,561 | 12 | sex | Male | Female |

---

## Reproducing Paper Figures and Tables Instantly

To reproduce the exact figures and statistical tests without re-running computationally intensive counterfactual optimizations (which require multi-objective evolutionary search over thousands of adverse profiles), pre-computed results are provided in the `results/` folder.

### 1. Generating Figures

Run the following command from the repository root:

```bash
Rscript scripts/03_generate_figures.R
```

This generates:
* `figures/fig_rq1_model_recourse_gaps.pdf`: Cross-model class recourse disparity comparisons (Figure 2).
* `figures/fig_rq2_methods_lollipop.pdf`: Counterfactual search paradigm comparison across What-If, NICE, and MOC (Figure 3).
* `figures/fig_rq3_mitigation_gaps.pdf`: Downstream impact of Reweight, Uniform Resampling, and Preferential Resampling on recourse equity (Figure 4).

### 2. Running Non-Parametric Statistical Tests

Run the following command to replicate the paired Friedman tests:

```bash
Rscript scripts/04_statistical_tests.R
```

This script verifies:
1. Section 4.1: Model class invariance across Proximity, Sparsity, and Minimality gaps.
2. Section 4.2: Algorithmic paradigm comparisons establishing MOC equity.
3. Section 4.3: Disparity differences across bias mitigation interventions.

---

## Re-running End-to-End Pipeline

To train the models from raw data and recompute recourse explanations:

1. **Requirements:**
   * R (>= 4.2)
   * Packages: `ranger`, `gbm`, `counterfactuals`, `iml`, `fairmodels`, `DALEX`, `pROC`, `dplyr`, `tidyr`, `ggplot2`

   Install dependencies in R:
   ```R
   install.packages(c("ranger", "gbm", "counterfactuals", "iml", "fairmodels", "DALEX", "pROC", "dplyr", "tidyr", "ggplot2"))
   ```

2. **Model Training:**
   ```bash
   Rscript scripts/01_train_models.R
   ```

3. **Recourse Evaluation:**
   ```bash
   Rscript scripts/02_evaluate_recourse.R
   ```
