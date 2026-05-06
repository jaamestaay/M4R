library(ape)
library(phytools)
library(phangorn)

values <- list(
    RF = function(true, trees) RF.dist(true, trees),
    CladeRecovery = function(true, trees) {
        support <- prop.clades(true, trees)
        support <- support[!is.na(support)]
        support <- support/length(trees)
    }
)

metrics <- list(
    meanRF = function(values) mean(values$RF),
    varRF = function(values) var(values$RF),
    meanNRF = function(values) mean(values$RF/length(values$RF)),
    varNRF = function(values) var(values$RF/length(values$RF)),
    HighSupportCladesProp = function(values) {
        mean(values$CladeRecovery > 0.9)
    } # Proportion of Internal Nodes well supported by posterior
    # OTHER METRICS TO CONSIDER
    # Quartet distance
    # Branch Score distance
    # Root-to-tip distance comparison
)

compute_metrics <- function(tree_list, ref_tree, values, metrics) {
  raw <- list()
  for (value in names(values)) {
    raw[[value]] <- values[[value]](ref_tree, tree_list)
  }
  summary <- list()
  for (metric in names(metrics)) {
    summary[[metric]] <- metrics[[metric]](raw)
  }
  return summary
}

args <- commandArgs(trailingOnly = TRUE)
prefix <- args[1]
burnin_frac <- 0.1

# 060526 change this to accommodate for ALL trees 
true_tree <- read.nexus(paste0(prefix, "/", prefix, "_true.nex"))
# Independent Data Tree
independent_trees <- read.nexus(paste0(prefix, "/", prefix, "_independent.trees"))
n <- length(independent_trees)
start <- floor(n * burnin_frac) + 1
independent_trees <- independent_trees[start:n]
# Dependent Data Tree
dependent_trees <- read.nexus(paste0(prefix, "/", prefix, "_dependent.trees"))
dependent_trees <- dependent_trees[start:n]

# 060526 change this to accommodate for ALL trees 
results <- list(
    independent = compute_metrics(independent_trees, true_tree, values, metrics),
    dependent = compute_metrics(dependent_trees, true_tree, values, metrics)
)

# 060526 change this to accommodate for ALL trees 
# Convert results into a dataframe for csv output
df <- do.call(rbind, lapply(names(results), function(dataset) {
    metrics_df <- as.data.frame(results[[dataset]])
    metrics_df$tree_id <- seq_len(nrow(metrics_df))
    metrics_df$dataset <- dataset
    metrics_df
}))
write.csv(df, paste0(prefix, "/", prefix, "_tree_comparison_results.csv"), row.names = FALSE)