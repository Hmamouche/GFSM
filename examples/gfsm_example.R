# This file contains an application of the GFSM method on stock-and-watson-2012 macroeconomic dataset. We try to select predictors variables for each target variable (3 variables) using different reduction size.

require(compiler)
enableJIT(3)
library(parallel)

source("examples/read_meta_data.R")

no_cores <- detectCores() - 1

#----------- Select variables for one target variable ----------------#
gfsm_selection_inner <- function (output_dir, target_name, target_index, prediction_type, nk, data, matrix, threshold, data_dir){
    
    out_dir = paste0(output_dir,target_name,"_GFSM_K=",nk,".csv")
    p_gfsm = gfsm (data, matrix, target_index, threshold, clus = FALSE, nbre_vars = nk)

    if (ncol(data.frame(p_gfsm)) > 0)
        p_gfsm = data.frame (data[,target_index], p_gfsm)

    else
        p_gfsm = data.frame (data[,target_name])

    colnames(p_gfsm)[1] = target_name
    # Set metadata
    command = paste0 ('awk \'/^#/ && !/^# *predict/\' ', data_dir)
    system(paste0(command,' > ', out_dir))

    cat ("# predict;", file=out_dir, append=TRUE)
    cat (target_name, file=out_dir, append=TRUE, sep='\n')
    cat ("# prediction_type;", file=out_dir, append=TRUE)
    cat (paste0(prediction_type), file=out_dir, append=TRUE, sep='\n')
    cat (paste0("# method; GFSM_", "(n_components=",nk,")"),file=out_dir, append=TRUE, sep='\n')
    
    ## Store the selected variables
    write.table(p_gfsm, out_dir, row.names = FALSE, na = "",col.names = TRUE, sep = ";", append = TRUE)
}

#----------- Select variables for all target variable of an input file ----------------#
gfsm_selection <- function (data_dir){
    ## read the dataset
    data = read.csv(data_dir,check.names=FALSE, header = TRUE, dec = '.',sep=";", comment.char = "#")
    
    # read meta-data
    meta_data = read_meta_data(data_dir)

    colnames = colnames(data)

    # Graphs directory
    graph_dir = paste0("results/causality_graphs/",meta_data$data_name)
    graphs = list.files(path = graph_dir, all.files = FALSE)

    output_dir = paste0("results/feature_selection/")
    number_of_variables = meta_data$max_attributes
    threshold = 0.95

    graph_dir = paste0("results/causality_graphs/",meta_data$data_name,"_","GrangerCausalityGraph.csv")
    matrix = read.table(graph_dir,check.names=FALSE, header = TRUE,row.names = 1, dec = '.',sep=";", comment.char = "#")
    
    # Execute the method  for each target variable
    for (target_name in meta_data$target_names){
        for(j in 1:length(colnames))
            if (colnames[j] == target_name) {
                target_index = j
                break;
            }

        mclapply(1:meta_data$max_attributes, function(i) try(gfsm_selection_inner(output_dir, target_name, target_index, meta_data$prediction_type, i, data, matrix, threshold, data_dir)), mc.cores=no_cores, mc.preschedule = FALSE)
    }
}

#----------- MAIN ----------------#
args = commandArgs(trailingOnly=TRUE)

if (length(args) < 1 || length(args) > 1){
    print ("Error: number of arguments incorrect.")
    quit()
}

# Create directories in they not exist
if (!file.exists ("results/feature_selection"))
    dir.create (file.path ("results/feature_selection"))

if (!file.exists ("results/causality_graphs"))
    dir.create (file.path ("results/causality_graphs"))

# Data directory
data_dir = args[1]

# First, we compute the graph of causalities
# If the graph exists already in the "results/causality_graphs" directory, then this instruction is not necessary
source("src/causality_graph.R")
#compute_causality_graph (data_dir)

# Then, we can then apply the GFSM method
source("src/gfsm.R")
gfsm_selection (data_dir)

