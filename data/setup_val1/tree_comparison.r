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
    },
    NumberofTaxa = function(data) {
        data$true$Nnode + 1 # 1 more than number of internal nodes/bifurcations
    }
)

metrics <- list(
    meanRF = function(values) mean(values$RF),
    varRF = function(values) var(values$RF),
    meanNRF = function(values) {
        maxRF = 2 * (values$NumberofTaxa - 3)
        mean(values$RF/maxRF)
    },
    varNRF = function(values) {
        maxRF = 2 * (values$NumberofTaxa - 3)
        var(values$RF/maxRF)
    },
    HighSupportCladesProp = function(values) {
        mean(values$CladeRecovery > 0.9)
    }, # Proportion of Internal Nodes well supported by posterior
    likelihoodESS = function(values) values$ESS["likelihood"],
    priorESS = function(values) values$ESS["prior"],
    jointESS = function(values) values$ESS["joint"]
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
    return (mcmc_obj)
}

true_tree <- read.nexus(paste0(outdir, "/", prefix, "/true.nex"))
# Independent Data Tree
independent_trees <- post_process_trees(
    paste0(outdir, "/", prefix, "/independent.trees"), burnin_frac
)
independent_log <- post_process_log(
    paste0(outdir, "/", prefix, "/independent.log"), burnin_frac
)

# Independent Metric Extraction with Parameters
indep_metrics <- compute_metrics(independent_trees, true_tree, independent_log, values, metrics)
indep_df <- as.data.frame(indep_metrics)
indep_df$dataset <- "independent"
indep_df$prob <- 0
indep_df$mean <- 0
indep_df$tier <- 1
indep_df$id <- 0

# Combine, convert results into a dataframe for csv output
write.csv(
    indep_df,
    file = paste0(outdir, "/", prefix, "/tree_comparison_results.csv"),
    row.names = FALSE
)
