# FC_geodesic-matlab
MatLab implementation of code given in [FC_geodesic repository](https://github.com/makto-toruk/FC_geodesic) created by user [@makto_turuk](https://github.com/makto-toruk). The code has been written and tested in MATLAB_R2021a.

## Table of Contents
* [Functional Connectivity Matrices](#functional-connectivity-matrices)
* [Data](#data)
* [Code](#data)
* [Launch](#launch)
* [Figures](#figures)


## Functional Connectivity Matrices
This code enables the user to find correlation structures between two brain regions captured in a fuctional connectivity (FC) matrix. The reference paper for comparing FC matrices can be found [here](https://www.sciencedirect.com/science/article/pii/S1053811919309899). 

## Data
Test data from the original FC_geodesic repository is available in the `data/condition1` folder. Testing to ensure similarity between the original Python code and this MatLab implemenation has been done. The data includes two FC matrices (with keys `LR1` and `RL1`) of size `300 x 300` for `N = 20` subjects.

## Code
This repository contains the following classes
* `distance_FC.m`
* `distance_matrix_requestor.m`
* `accuracy_requestor.m`

[`distance_FC.m`](https://github.com/amarvi1/FC_geodesic-matlab/blob/main/utils/distance_FC/distance_FC.m) is the main code, which computes either the geodesic distance or Pearson dissimilarity between two FC matrices. 

`distance_matrix_requestor.m` and `accuracy_requestor.m` are available in the `utils/FC_analyzer` folder [here](https://github.com/amarvi1/FC_geodesic-matlab/tree/main/utils/FC_analyzer). Use these to compute the accuracy of the geodesic or Pearson methods and plot the results.

## Launch
To use the `distance_FC` class, run the following commands:
```
dist = distance_FC(FC1, FC2);

% geodesic distance
d_geodesic = dist.geodesic();

% pearson dissimilarity
d_pearson = dist.pearson();
```

For the `distance_matrix_requestor` and `accuracy_requestor` class calculations, run the following: 
```
dr = distance_matrix_requestor(condition1, condition2, DIR, trim_method, kROI);
dr.make_distance_requests;

ar = accuracy_requestor(condition1, condition2, DIR, trim_method, kROI);
ar.make_accuracy_requests;

% plot the results
ar.plot_results;
```

## Figures
HTML figures for the reference paper are provided in the `figures` folder [here](https://github.com/amarvi1/FC_geodesic-matlab/tree/main/figures), provided by the original repository linked above. HTML figures allow for better visibility in a 3-dimensional space. 
