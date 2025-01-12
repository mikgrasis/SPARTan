% Implementation of the KDD 2017 paper "SPARTan: Scalable PARAFAC2 for
% Large & Sparse Data", by Ioakeim Perros, Evangelos E. Papalexakis, Fei
% Wang, Richard Vuduc, Elizabeth Searles, Michael Thompson and Jimeng Sun
close all; clear, clc

% First, specify the root directory where the Tensor Toolbox and
% N-way Toolbox folders can be found. The code has been tested using
% Tensor Toolbox v2.6 and N-Way Toolbox v3.30.
rootDir = return_repository_root();
addpath(genpath(fullfile(rootDir,'_toolboxes','tensor_toolbox_2.6')))
addpath(genpath(fullfile(rootDir,'_toolboxes','Nway_Toolbox_3.31')))

% Flag indicating whether parfor capabilites will be exploited
PARFOR_FLAG = 0;
delete(gcp('nocreate'));
if (PARFOR_FLAG)
    parpool; % Set the appropriate number of workers depending on your system
else
    disp('No parallel pool enabled.');
end

K = 100; %number of subjects (K)
J = 100; %number of variables (J)
I = 100; %max number of observations max(I_k)
sparsity = 10^-3; %sparsity of each input matrix X_k
R = 5; %target rank 

[X, totalnnz] = create_parafac2_problem(K, J, R, sparsity, I, PARFOR_FLAG);
fprintf(1, 'Total non-zeros: %d\n', totalnnz);

ALG = 1;
if (ALG==1)
    disp('SPARTan execution');  % if ALG==1, then SPARTan is executed. 
else
    disp('Sparse PARAFAC2 baseline execution'); % if ALG==0, then the baseline is executed
end
Maxiters = 100; % maximum number of iterations
Constraints = [0 0]; % non-negative constraints on both the V and S_k factors
Options = [1e-6 Maxiters 2 0 0 ALG PARFOR_FLAG]; % first argument is convergence criterion

rng('default');
[H, V, W, Q, FIT, IT_TIME] = parafac2_sparse_paper_version(X, R, Constraints, Options);