# generate_all_figures_5datasets_wide.R
library(ggplot2)
library(dplyr)
library(tidyr)

dset_order <- c('German\nCredit', 'Taiwan\nCredit', 'FICO\nHELOC', 'Give Me\nCredit', 'Adult\nIncome')

df5 <- read.csv('results/counterfactual_fairness_evaluation_5metrics_n50.csv')

df5 <- df5 %>%
  mutate(
    Priv_Prox = case_when(
      Dataset == 'german_credit' ~ G1_Proximity,
      Dataset == 'taiwan_credit' ~ G2_Proximity,
      Dataset == 'fico_heloc'    ~ G2_Proximity,
      Dataset == 'gmc'           ~ G1_Proximity,
      Dataset == 'adult'         ~ G1_Proximity
    ),
    Unpriv_Prox = case_when(
      Dataset == 'german_credit' ~ G2_Proximity,
      Dataset == 'taiwan_credit' ~ G1_Proximity,
      Dataset == 'fico_heloc'    ~ G1_Proximity,
      Dataset == 'gmc'           ~ G2_Proximity,
      Dataset == 'adult'         ~ G2_Proximity
    ),
    Priv_Spar = case_when(
      Dataset == 'german_credit' ~ G1_Sparsity,
      Dataset == 'taiwan_credit' ~ G2_Sparsity,
      Dataset == 'fico_heloc'    ~ G2_Sparsity,
      Dataset == 'gmc'           ~ G1_Sparsity,
      Dataset == 'adult'         ~ G1_Sparsity
    ),
    Unpriv_Spar = case_when(
      Dataset == 'german_credit' ~ G2_Sparsity,
      Dataset == 'taiwan_credit' ~ G1_Sparsity,
      Dataset == 'fico_heloc'    ~ G1_Sparsity,
      Dataset == 'gmc'           ~ G2_Sparsity,
      Dataset == 'adult'         ~ G2_Sparsity
    ),
    Priv_Mini = case_when(
      Dataset == 'german_credit' ~ G1_Minimality,
      Dataset == 'taiwan_credit' ~ G2_Minimality,
      Dataset == 'fico_heloc'    ~ G2_Minimality,
      Dataset == 'gmc'           ~ G1_Minimality,
      Dataset == 'adult'         ~ G1_Minimality
    ),
    Unpriv_Mini = case_when(
      Dataset == 'german_credit' ~ G2_Minimality,
      Dataset == 'taiwan_credit' ~ G1_Minimality,
      Dataset == 'fico_heloc'    ~ G1_Minimality,
      Dataset == 'gmc'           ~ G2_Minimality,
      Dataset == 'adult'         ~ G2_Minimality
    ),
    Gap_Prox = pmax(0, Unpriv_Prox - Priv_Prox),
    Gap_Spar = pmax(0, Unpriv_Spar - Priv_Spar),
    Gap_Mini = pmax(0, Unpriv_Mini - Priv_Mini)
  )

metric_levels_lower <- c('proximity', 'sparsity', 'minimality')

# Global x-axis range dummy dataset to enforce exact identical x scales across Fig 2, 3, 4
dummy_scales <- data.frame(
  Metric = factor(c('proximity', 'proximity', 'sparsity', 'sparsity', 'minimality', 'minimality'),
                  levels = metric_levels_lower),
  x_val = c(0, 0.13, 0, 2.0, 0, 2.8),
  y_coord = c(1, 1, 1, 1, 1, 1)
)

# =============================================================
# FIGURE 1 (Paper Figure 2): Models across 5 datasets
# =============================================================
df_rq1 <- df5 %>%
  mutate(
    Model = ifelse(Model == 'Random_Forest', 'RF', Model),
    Dataset_Label = factor(case_when(
      Dataset == 'german_credit' ~ 'German\nCredit',
      Dataset == 'taiwan_credit' ~ 'Taiwan\nCredit',
      Dataset == 'fico_heloc'    ~ 'FICO\nHELOC',
      Dataset == 'gmc'           ~ 'Give Me\nCredit',
      Dataset == 'adult'         ~ 'Adult\nIncome'
    ), levels = dset_order),
    Model_Label = factor(Model, levels = c('GLM', 'RF', 'GBM'))
  )

stats1 <- df_rq1 %>%
  pivot_longer(cols = c(Gap_Prox, Gap_Spar, Gap_Mini),
               names_to = 'Metric', values_to = 'Val') %>%
  mutate(Metric = factor(case_when(
    Metric == 'Gap_Prox' ~ 'proximity',
    Metric == 'Gap_Spar' ~ 'sparsity',
    Metric == 'Gap_Mini' ~ 'minimality'
  ), levels = metric_levels_lower)) %>%
  group_by(Dataset_Label, Model_Label, Metric) %>%
  summarise(
    Mean = mean(Val, na.rm = TRUE),
    SD = sd(Val, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    SD = ifelse(is.na(SD), 0, SD),
    xmin_sd = pmax(0, Mean - SD),
    xmax_sd = Mean + SD,
    has_band = Mean > 0
  )

plot_data1 <- stats1
model_offsets <- c('GLM' = -0.18, 'RF' = 0.00, 'GBM' = 0.18)
plot_data1$dset_num <- as.numeric(plot_data1$Dataset_Label)
plot_data1$y_coord <- plot_data1$dset_num + model_offsets[as.character(plot_data1$Model_Label)]

palette_model_nejm <- c('GLM' = '#0072B5', 'RF' = '#E18727', 'GBM' = '#7876B1')

p1 <- ggplot() +
  geom_vline(xintercept = 0, linetype = 'solid', color = 'grey80', linewidth = 0.5) +
  geom_blank(data = dummy_scales, aes(x = x_val, y = y_coord)) +
  geom_segment(data = filter(plot_data1, has_band),
               aes(x = xmin_sd, xend = xmax_sd, y = y_coord, yend = y_coord, color = Model_Label),
               linewidth = 1.9, lineend = 'round', alpha = 0.30) +
  geom_segment(data = plot_data1, 
               aes(x = 0, xend = Mean, y = y_coord, yend = y_coord, color = Model_Label),
               linewidth = 0.60, alpha = 0.85) +
  geom_point(data = plot_data1, 
             aes(x = Mean, y = y_coord, color = Model_Label), 
             size = 1.9, alpha = 0.95) +
  facet_wrap(~ Metric, scales = 'free_x') +
  scale_y_continuous(breaks = 1:5, labels = levels(plot_data1$Dataset_Label),
                     limits = c(0.55, 5.45), expand = c(0, 0)) +
  scale_color_manual(values = palette_model_nejm,
                     guide = guide_legend(override.aes = list(size = 2.5, linewidth = 0.8))) +
  labs(x = 'Recourse Disparity Burden Against Unprivileged Subgroup', y = NULL) +
  theme_bw(base_size = 8.5) +
  theme(
    legend.position = 'bottom',
    legend.title = element_blank(),
    legend.text = element_text(size = 8, face = 'plain'),
    legend.key.size = unit(0.70, 'lines'),
    legend.margin = margin(t = -2, b = 0),
    strip.text = element_text(size = 9, face = 'plain'),
    strip.background = element_rect(fill = 'grey95'),
    panel.spacing.x = unit(0.9, 'lines'),
    axis.title.x = element_text(face = 'plain', size = 8),
    axis.text = element_text(face = 'plain', size = 7.5),
    axis.text.y = element_text(face = 'plain', size = 7.5, lineheight = 0.85),
    panel.grid.minor = element_blank(),
    plot.margin = margin(t = 2, r = 4, b = 2, l = 4)
  )

ggsave('figures/fig_rq1_model_recourse_gaps.pdf', p1, width = 6.8, height = 2.45)
ggsave('figures/fig_rq1_model_recourse_gaps.png', p1, width = 6.8, height = 2.45, dpi = 300)
cat('Figure 2 saved.\n')

# =============================================================
# FIGURE 2 (Paper Figure 3): CE Methods across 5 datasets
# =============================================================
df_rq2 <- df5 %>%
  mutate(
    CE_Method = ifelse(CE_Method == 'WhatIf', 'What-If', CE_Method),
    Dataset_Label = factor(case_when(
      Dataset == 'german_credit' ~ 'German\nCredit',
      Dataset == 'taiwan_credit' ~ 'Taiwan\nCredit',
      Dataset == 'fico_heloc'    ~ 'FICO\nHELOC',
      Dataset == 'gmc'           ~ 'Give Me\nCredit',
      Dataset == 'adult'         ~ 'Adult\nIncome'
    ), levels = dset_order),
    CE_Label = factor(CE_Method, levels = c('What-If', 'NICE', 'MOC'))
  )

stats2 <- df_rq2 %>%
  pivot_longer(cols = c(Gap_Prox, Gap_Spar, Gap_Mini),
               names_to = 'Metric', values_to = 'Val') %>%
  mutate(Metric = factor(case_when(
    Metric == 'Gap_Prox' ~ 'proximity',
    Metric == 'Gap_Spar' ~ 'sparsity',
    Metric == 'Gap_Mini' ~ 'minimality'
  ), levels = metric_levels_lower)) %>%
  group_by(Dataset_Label, CE_Label, Metric) %>%
  summarise(
    Mean = mean(Val, na.rm = TRUE),
    SD = sd(Val, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    SD = ifelse(is.na(SD), 0, SD),
    xmin_sd = pmax(0, Mean - SD),
    xmax_sd = Mean + SD,
    has_band = Mean > 0
  )

plot_data2 <- stats2
ce_offsets <- c('What-If' = -0.18, 'NICE' = 0.00, 'MOC' = 0.18)
plot_data2$dset_num <- as.numeric(plot_data2$Dataset_Label)
plot_data2$y_coord <- plot_data2$dset_num + ce_offsets[as.character(plot_data2$CE_Label)]

palette_ce_npg <- c('What-If' = '#E64B35', 'NICE' = '#00A087', 'MOC' = '#3C5488')

p2 <- ggplot() +
  geom_vline(xintercept = 0, linetype = 'solid', color = 'grey80', linewidth = 0.5) +
  geom_blank(data = dummy_scales, aes(x = x_val, y = y_coord)) +
  geom_segment(data = filter(plot_data2, has_band),
               aes(x = xmin_sd, xend = xmax_sd, y = y_coord, yend = y_coord, color = CE_Label),
               linewidth = 1.9, lineend = 'round', alpha = 0.30) +
  geom_segment(data = plot_data2, 
               aes(x = 0, xend = Mean, y = y_coord, yend = y_coord, color = CE_Label),
               linewidth = 0.60, alpha = 0.85) +
  geom_point(data = plot_data2, 
             aes(x = Mean, y = y_coord, color = CE_Label), 
             size = 1.9, alpha = 0.95) +
  facet_wrap(~ Metric, scales = 'free_x') +
  scale_y_continuous(breaks = 1:5, labels = levels(plot_data2$Dataset_Label),
                     limits = c(0.55, 5.45), expand = c(0, 0)) +
  scale_color_manual(values = palette_ce_npg,
                     guide = guide_legend(override.aes = list(size = 2.5, linewidth = 0.8))) +
  labs(x = 'Recourse Disparity Burden Against Unprivileged Subgroup', y = NULL) +
  theme_bw(base_size = 8.5) +
  theme(
    legend.position = 'bottom',
    legend.title = element_blank(),
    legend.text = element_text(size = 8, face = 'plain'),
    legend.key.size = unit(0.70, 'lines'),
    legend.margin = margin(t = -2, b = 0),
    strip.text = element_text(size = 9, face = 'plain'),
    strip.background = element_rect(fill = 'grey95'),
    panel.spacing.x = unit(0.9, 'lines'),
    axis.title.x = element_text(face = 'plain', size = 8),
    axis.text = element_text(face = 'plain', size = 7.5),
    axis.text.y = element_text(face = 'plain', size = 7.5, lineheight = 0.85),
    panel.grid.minor = element_blank(),
    plot.margin = margin(t = 2, r = 4, b = 2, l = 4)
  )

ggsave('figures/fig_rq2_methods_lollipop.pdf', p2, width = 6.8, height = 2.45)
ggsave('figures/fig_rq2_methods_lollipop.png', p2, width = 6.8, height = 2.45, dpi = 300)
cat('Figure 3 saved.\n')

# =============================================================
# FIGURE 3 (Paper Figure 4): Mitigations across 5 datasets (All 3 CE Methods: What-If, NICE, MOC)
# =============================================================
df_mit <- read.csv('results/mitigated_counterfactual_fairness_evaluation_n50.csv')
df_base <- read.csv('results/counterfactual_fairness_evaluation_5metrics_n50.csv') %>%
  mutate(Mitigation = 'baseline')

df_rq3_raw <- bind_rows(df_base, df_mit) %>%
  mutate(
    Priv_Prox = case_when(
      Dataset == 'german_credit' ~ G1_Proximity,
      Dataset == 'taiwan_credit' ~ G2_Proximity,
      Dataset == 'fico_heloc'    ~ G2_Proximity,
      Dataset == 'gmc'           ~ G1_Proximity,
      Dataset == 'adult'         ~ G1_Proximity
    ),
    Unpriv_Prox = case_when(
      Dataset == 'german_credit' ~ G2_Proximity,
      Dataset == 'taiwan_credit' ~ G1_Proximity,
      Dataset == 'fico_heloc'    ~ G1_Proximity,
      Dataset == 'gmc'           ~ G2_Proximity,
      Dataset == 'adult'         ~ G2_Proximity
    ),
    Priv_Spar = case_when(
      Dataset == 'german_credit' ~ G1_Sparsity,
      Dataset == 'taiwan_credit' ~ G2_Sparsity,
      Dataset == 'fico_heloc'    ~ G2_Sparsity,
      Dataset == 'gmc'           ~ G1_Sparsity,
      Dataset == 'adult'         ~ G1_Sparsity
    ),
    Unpriv_Spar = case_when(
      Dataset == 'german_credit' ~ G2_Sparsity,
      Dataset == 'taiwan_credit' ~ G1_Sparsity,
      Dataset == 'fico_heloc'    ~ G1_Sparsity,
      Dataset == 'gmc'           ~ G2_Sparsity,
      Dataset == 'adult'         ~ G2_Sparsity
    ),
    Priv_Mini = case_when(
      Dataset == 'german_credit' ~ G1_Minimality,
      Dataset == 'taiwan_credit' ~ G2_Minimality,
      Dataset == 'fico_heloc'    ~ G2_Minimality,
      Dataset == 'gmc'           ~ G1_Minimality,
      Dataset == 'adult'         ~ G1_Minimality
    ),
    Unpriv_Mini = case_when(
      Dataset == 'german_credit' ~ G2_Minimality,
      Dataset == 'taiwan_credit' ~ G1_Minimality,
      Dataset == 'fico_heloc'    ~ G1_Minimality,
      Dataset == 'gmc'           ~ G2_Minimality,
      Dataset == 'adult'         ~ G2_Minimality
    ),
    Gap_Prox = pmax(0, Unpriv_Prox - Priv_Prox),
    Gap_Spar = pmax(0, Unpriv_Spar - Priv_Spar),
    Gap_Mini = pmax(0, Unpriv_Mini - Priv_Mini)
  )

df_rq3 <- df_rq3_raw %>%
  mutate(
    Dataset_Label = factor(case_when(
      Dataset == 'german_credit' ~ 'German\nCredit',
      Dataset == 'taiwan_credit' ~ 'Taiwan\nCredit',
      Dataset == 'fico_heloc'    ~ 'FICO\nHELOC',
      Dataset == 'gmc'           ~ 'Give Me\nCredit',
      Dataset == 'adult'         ~ 'Adult\nIncome'
    ), levels = dset_order),
    Mitigation_Label = factor(case_when(
      Mitigation == 'baseline' ~ 'Baseline',
      Mitigation == 'reweight' ~ 'Reweight',
      Mitigation == 'resample_uniform' ~ 'Uniform Resample',
      Mitigation == 'resample_preferential' ~ 'Preferential Resample'
    ), levels = c('Baseline', 'Reweight', 'Uniform Resample', 'Preferential Resample'))
  )

stats3 <- df_rq3 %>%
  pivot_longer(cols = c(Gap_Prox, Gap_Spar, Gap_Mini),
               names_to = 'Metric', values_to = 'Val') %>%
  mutate(Metric = factor(case_when(
    Metric == 'Gap_Prox' ~ 'proximity',
    Metric == 'Gap_Spar' ~ 'sparsity',
    Metric == 'Gap_Mini' ~ 'minimality'
  ), levels = metric_levels_lower)) %>%
  group_by(Dataset_Label, Mitigation_Label, Metric) %>%
  summarise(
    Mean = mean(Val, na.rm = TRUE),
    SD = sd(Val, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    SD = ifelse(is.na(SD), 0, SD),
    xmin_sd = pmax(0, Mean - SD),
    xmax_sd = Mean + SD,
    has_band = Mean > 0
  )

plot_data3 <- stats3
mit_offsets <- c('Baseline' = -0.27, 'Reweight' = -0.09, 'Uniform Resample' = 0.09, 'Preferential Resample' = 0.27)
plot_data3$dset_num <- as.numeric(plot_data3$Dataset_Label)
plot_data3$y_coord <- plot_data3$dset_num + mit_offsets[as.character(plot_data3$Mitigation_Label)]

palette_mit <- c(
  'Baseline' = '#7F7F7F',
  'Reweight' = '#D95F02',
  'Uniform Resample' = '#7570B3',
  'Preferential Resample' = '#1B9E77'
)

p3 <- ggplot() +
  geom_vline(xintercept = 0, linetype = 'solid', color = 'grey80', linewidth = 0.5) +
  geom_blank(data = dummy_scales, aes(x = x_val, y = y_coord)) +
  geom_segment(data = filter(plot_data3, has_band),
               aes(x = xmin_sd, xend = xmax_sd, y = y_coord, yend = y_coord, color = Mitigation_Label),
               linewidth = 1.9, lineend = 'round', alpha = 0.30) +
  geom_segment(data = plot_data3, 
               aes(x = 0, xend = Mean, y = y_coord, yend = y_coord, color = Mitigation_Label),
               linewidth = 0.60, alpha = 0.85) +
  geom_point(data = plot_data3, 
             aes(x = Mean, y = y_coord, color = Mitigation_Label), 
             size = 1.9, alpha = 0.95) +
  facet_wrap(~ Metric, scales = 'free_x') +
  scale_y_continuous(breaks = 1:5, labels = levels(plot_data3$Dataset_Label),
                     limits = c(0.55, 5.45), expand = c(0, 0)) +
  scale_color_manual(values = palette_mit,
                     guide = guide_legend(override.aes = list(size = 2.5, linewidth = 0.8))) +
  labs(x = 'Recourse Disparity Burden Against Unprivileged Subgroup', y = NULL) +
  theme_bw(base_size = 8.5) +
  theme(
    legend.position = 'bottom',
    legend.title = element_blank(),
    legend.text = element_text(size = 8, face = 'plain'),
    legend.key.size = unit(0.70, 'lines'),
    legend.margin = margin(t = -2, b = 0),
    strip.text = element_text(size = 9, face = 'plain'),
    strip.background = element_rect(fill = 'grey95'),
    panel.spacing.x = unit(0.9, 'lines'),
    axis.title.x = element_text(face = 'plain', size = 8),
    axis.text = element_text(face = 'plain', size = 7.5),
    axis.text.y = element_text(face = 'plain', size = 7.5, lineheight = 0.85),
    panel.grid.minor = element_blank(),
    plot.margin = margin(t = 2, r = 4, b = 2, l = 4)
  )

ggsave('figures/fig_rq3_mitigation_gaps.pdf', p3, width = 6.8, height = 2.45)
ggsave('figures/fig_rq3_mitigation_gaps.png', p3, width = 6.8, height = 2.45, dpi = 300)
cat('Figure 4 saved.\n')
