library(ape)
library(phytools)
library(phangorn)

metrics <- list(
    RF = function(tr1, tr2) RF.dist(tr1, tr2)
    # OTHER METRICS TO CONSIDER
    # Normalised RF distance
    # Quartet distance
    # Branch Score distance
    # Root-to-tip distance comparison
    # Clade Recovery
)

compute_metrics <- function(tree_list, ref_tree, metrics) {
    lapply(metrics, function(f){
        vapply(tree_list, function(tr) f(ref_tree, tr), numeric(1))
    })
}

args <- commandArgs(trailingOnly = TRUE)
prefix <- args[1]
burnin_frac <- 0.1

true_tree <- read.nexus(paste0(prefix, "/", prefix, "_true.nex"))
# Independent Data Tree
independent_trees <- read.nexus(paste0(prefix, "/", prefix, "_independent.trees"))
n <- length(independent_trees)
start <- floor(n * burnin_frac) + 1
independent_trees <- independent_trees[start:n]
# Dependent Data Tree
dependent_trees <- read.nexus(paste0(prefix, "/", prefix, "_dependent.trees"))
dependent_trees <- dependent_trees[start:n]


results <- list(
    independent = compute_metrics(independent_trees, true_tree, metrics),
    dependent = compute_metrics(dependent_trees, true_tree, metrics)
)

# Convert results into a dataframe for csv output
df <- do.call(rbind, lapply(names(results), function(dataset) {
    metrics_df <- as.data.frame(results[[dataset]])
    metrics_df$tree_id <- seq_len(nrow(metrics_df))
    metrics_df$dataset <- dataset
    metrics_df
}))
write.csv(df, paste0(prefix, "/", prefix, "_tree_comparison_results.csv"), row.names = FALSE)