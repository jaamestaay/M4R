library(ape)
library(phytools)
library(phangorn)
library(coda)

values <- list(
    RF = function(data) RF.dist(data$true, data$trees),
    CladeRecovery = function(data) {
        support <- prop.clades(data$true, data$trees)
        support <- support[!is.na(support)]
        support <- support/length(data$trees)
    },
    ESS = function(data) {
        effectiveSize(data$log)
    }
)

metrics <- list(
    meanRF = function(values) mean(values$RF),
    varRF = function(values) var(values$RF),
    meanNRF = function(values) mean(values$RF/length(values$RF)),
    varNRF = function(values) var(values$RF/length(values$RF)),
    HighSupportCladesProp = function(values) {
        mean(values$CladeRecovery > 0.9)
    }, # Proportion of Internal Nodes well supported by posterior
    likelihoodESS = function(values) values$ESS["likelihood"],
    priorESS = function(values) values$ESS["prior"],
    treeLikelihoodESS = function(values) values$ESS["treeLikelihood"]
    # OTHER METRICS TO CONSIDER
    # Quartet distance
    # Branch Score distance
    # Root-to-tip distance comparison
)

compute_metrics <- function(tree_list, ref_tree, log, values, metrics) {
  data <- list(
        true = ref_tree,
        trees = tree_list,
        log = log
    )
  raw <- list()
  for (value in names(values)) {
    raw[[value]] <- values[[value]](data)
  }
  summary <- list()
  for (metric in names(metrics)) {
    summary[[metric]] <- metrics[[metric]](raw)
  }
  return (summary)
}

args <- commandArgs(trailingOnly = TRUE)
outdir <- args[1]
prefix <- args[2]
burnin_frac <- 0.1

# functions to post process
post_process_trees <- function(filename, burnin_frac) {
    trees <- read.nexus(filename)
    n <- length(trees)
    start <- ceiling(n * burnin_frac)
    trees <- trees[start:n]
    return (trees)
}

post_process_log <- function(filename, burnin_frac) {
    log <- read.table(filename, header=TRUE, comment.char = "#")
    n <- nrow(log)
    start <- ceiling(n * burnin_frac)
    log <- log[start:n, ]
    mcmc_obj <- as.mcmc(log)
    return (log)
}


# 060526 change this to accommodate for ALL trees 
true_tree <- read.nexus(paste0(outdir, "/", prefix, "/true.nex"))
# Independent Data Tree
independent_trees <- post_process_trees(
    paste0(outdir, "/", prefix, "/independent.trees"), burnin_frac
)
independent_log <- post_process_log(
    paste0(outdir, "/", prefix, "/independent.log"), burnin_frac
)
# Dependent Data Trees
treefiles <- list.files(
    path = paste0(outdir, "/", prefix),
    pattern = "^dependent_\\d+\\.trees$",
    full.names = TRUE
)
dependent_trees <- lapply(treefiles, function(f) {
    post_process_trees(f, burnin_frac)
})
logfiles <- list.files(
    path = paste0(outdir, "/", prefix),
    pattern = "^dependent_\\d+\\.log$",
    full.names = TRUE
)
dependent_logs <- lapply(logfiles, function(f) {
    post_process_log(f, burnin_frac)
})

site_dep_params <- list(
    c(0.2, 3.75),
    c(0.5, 6),
    c(0.7, 10),
    c(0.9, 30)
)
tier_params <- c(2, 3, 4)
get_params <- function(idx, site_dep_params, tier_params) {
    m <- length(tier_params)
    i <- (idx - 1) %/% m + 1
    j <- (idx - 1) %% m + 1
    list(
        prob = site_dep_params[[i]][1],
        mean = site_dep_params[[i]][2],
        tier = tier_params[j]
    )
}

# Independent Metric Extraction with Parameters
indep_metrics <- compute_metrics(independent_trees, true_tree, independent_log, values, metrics)
indep_df <- as.data.frame(indep_metrics)
indep_df$dataset <- "independent"
indep_df$prob <- NA
indep_df$mean <- NA
indep_df$tier <- 1
indep_df$id <- 0

# Dependent Metric Extraction with Parameters
dep_results <- lapply(seq_along(dependent_trees), function(k) {
    trees_k <- dependent_trees[[k]]
    log_k <- dependent_logs[[k]]
    res <- compute_metrics(trees_k, true_tree, log_k, values, metrics)
    df <- as.data.frame(res)
    params <- get_params(k, site_dep_params, tier_params)
    df$dataset <- "dependent"
    df$prob <- params$prob
    df$mean <- params$mean
    df$tier <- params$tier
    df$id <- k
    return (df)
})

# Combine, convert results into a dataframe for csv output
dep_df <- do.call(rbind, dep_results)
final_df <- rbind(indep_df, dep_df)
write.csv(
    final_df,
    file = paste0(outdir, "/", prefix, "/tree_comparison_results.csv"),
    row.names = FALSE
)
