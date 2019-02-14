# A Causality Based Feature Selection Approche for Multivariate Time Series Forecasting
Implementation of the GFSM (Granger causality Featur Selection Method): 
    
Hmamouche, Y.; Casali, A.; Lakhal, L. Causality based feature selection approach for multivariate time series forecasting. In Proceedings of the International Conference on Advances in Databases, Knowledge, and Data Applications, Barcelona, Spain, 21–25 May 2017

# Prerequisites
This implementation requires the R software and other R packages.
After installing R, these packages can be installed manually from http://cran.us.r-project.org, or using the requirements.R script as follows:
    
    Rscript requirements.R
    
    
# An example
The code of the GFSM algorithm is located in src/gfsm.R. But it requires the causality matrix of the multivariate time series.
Thus, another script for computing matrix is src/in causality_graph.R.
The provided example (selecting predictors for variables of stock-and-watson-2012 datasets) can be executed as follows:
    
    sh main.sh

# Authors
* Youssef Hmamouche
