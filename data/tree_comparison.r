library(ape)
library(phytools)
# library(phangorn) # for next time

prefix <- "testing2204"

true_tree <- read.nexus(paste0(prefix, "/", prefix, "_true.nex"))
# Independent Data Tree
mcc_tree <- read.nexus(paste0(prefix, "/", prefix, "_mcc.nex"))
# Dependent Data Tree
# [not used here]


# Robinson-Foulds distance
rf_distance <- multiRF(c(true_tree, mcc_tree)) # include next tree here

# OTHER METRICS TO CONSIDER
# Normalised RF distance
# Quartet distance
# Branch Score distance
# Root-to-tip distance comparison
# Clade Recovery

results <- list(
    RF = rf_distance
)
print(rf_distance)