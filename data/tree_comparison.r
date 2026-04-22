library(ape)
library(phytools)
library(phangorn)

metrics <- list(
    RF = function(tr1, tr2) RF.dist(tr1, tr2),
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

# prefix, for now is hardcoded, but should be an argument in calling this program
prefix <- "testing2204"
burnin_frac <- 0.1

true_tree <- read.nexus(paste0(prefix, "/", prefix, "_true.nex"))
# Independent Data Tree
independent_trees <- read.nexus(paste0(prefix, "/", prefix, ".trees"))
n <- length(trees)
start <- floor(n * burnin_frac) + 1
post_burnin_trees <- trees[start:n]
# Dependent Data Tree
# 

results <- list(
    independent = compute_metrics(independent_trees, true_tree, metrics)
    # dependent one as well
)

# Convert results into a dataframe for csv output
df <- do.call(rbind, lapply(names(results), function(dataset) {
    metrics_df <- as.data.frame(results[[dataset]])
    metrics_df$tree_id <- seq_len(nrow(metrics_df))
    metrics_df$dataset <- dataset
    metrics_df
}))
write.csv(df, paste0(prefix, "/", prefix, "_tree_comparison_results.csv"), row.names = FALSE)