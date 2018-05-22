library (stats)
library(cluster)
library (kernlab)
library (factoextra)

#' GFSM method using the PAM clustering technique
#' @details select variables of a given multivariate time series with a target variable.
#' @param F Numerical dataframe
#' @param gmat Numerical dataframe, the matrix of pairwise causalities of variables of F
#' @param targetIndex Integer, the position of the target variable in the dataframe F (e.g., 1 if it is in the first column)
#' @param threshold a threshold of causality, 0.9 by default
#' @param clus Logical, False by default for selecting k variables where k is an input, and True for selecting a natural number of variables
#' @param k the reduction size, i.e., the number of variables to select

#' @return a dataFrame of selected variables

gfsm <- function (F,gmat, targetIndex,threshold = 0.9, clus = FALSE, nbre_vars) {
    
    # in case of nbre_vars = 1, we return just one variable based on causality to the target
    if (nbre_vars == 1){
        max_caus = 1
        for (i in 2:nrow (gmat))
            if (gmat[i, targetIndex] > gmat[max_caus, targetIndex])
                max_caus = i
        GSM = data.frame (F[,max_caus])
        colnames (GSM) = colnames (F)[max_caus]
        return (GSM)
    }
    
  #### First, we eliminate variables that do not cause the target according to the threshold
  gsmCluster = c()
  delet = c()
  n = 1
  m = 1
  for (i in 1:ncol(gmat)){
    if (i == targetIndex)
      target = m
    if (i != targetIndex)
      if (gmat[i,targetIndex] < threshold) {
        delet[n] = i
        n = n + 1
      }
    else
      m = m + 1
  }

  ### Applying the PAM methode for the clustering task
  if ((length(delet) + 1) == ncol(F))
    return (data.frame())
  
  if (length(delet) > 0)
  {
    gmat = gmat[-delet, -delet]
    F = F[,-delet]
  } 
  x = gmat[-target, -target]
  
  ## determine the optimal number of cluster in case of clus = TRUE
  if(clus == TRUE) {
      kmax = nrow(x)-1
      if (kmax < 2)
        return (F[,-target])
  
      a=fviz_nbclust(x, pam, method = "silhouette",k.max = kmax)
      k = which.max(a$data[,2])
  }
  else
    k = nbre_vars

  if (k < ncol(x))
  {
    for (l in 2:ncol(x))
      for(m in 1: (l-1))
        x[l,m] = x[m,l] = 1 - max(x[l,m], x[m,l])

      clusters = pam (as.dist (x), diss = TRUE, k)
      clusteringVector = clusters$cluster

      classes = data.frame()
      for (j in 1:k) {
        l = 1
        for ( i in 1:ncol(x))
          if (clusteringVector[i] == j) {
            classes[l,j] = i
            if (classes[l,j] >= target)
            {
              classes[l,j] = classes[l,j] + 1
            }
            l = l + 1
          }
      }
      ### choose the best variable from each cluster
      for (j in 1:k) {
        bestInGroup = 1;
        if (ncol(classes) >= j) {
          caus = gmat[classes[1,j],target];
          
          for (l in 2:length(classes[,j])) {
            if(is.na(classes[l,j]) == FALSE) {
              if (gmat[classes[l,j],target] > caus) {
                caus = gmat[classes[l,j],target];
                bestInGroup = l;
              }
            }
          }
           gsmCluster[j] = classes[bestInGroup,j];
        }
      }
      GSM = F [,gsmCluster]
  }
  else
    GSM =  F[,-target]
  
   return (GSM)
}

