%% THIS PROGRAM GENERATES STRUCTURAL ESTIMATES FOR HACKMANN, POHL, AND ZIEBARTH (2022) %%

clear;

parpool(12, 'IdleTimeout', Inf)

% folder in the repo that contains the code and input files for the structural estimation; XXX depends on user
cd /u/home/h/hackmann/Projects/LTCincentives_test/
addpath('/u/home/h/hackmann/Projects/LTCincentives_test/code/3_structural')
rng(1234567)

disp('Prepare Analysis')
disp('base')

%% set fixed parameters and other objects for all runs
cd output/3_structural/baseline

run('parameters_01.m')

%% 1. baseline estimates (full sample)

global model
model='base';
% import estimated home discharge rates and their variance-covariance matric
% constructed in 6_export_fig3_homedischarge_VarCov.do
data = csvread('lagoccu_individual_home_4smedold_65IIIVarCov.csv', 1, 0);

%%%% gridsearch over starting value
tic
run('gridsearch.m')
toc

global ylimits;
ylimits=[0.01 0.04];
global ylimitsextra;
ylimitsextra=[0.01 0.05];
%%% exog. discharge rates
global mu;
% lines 240 and 267 in 2_analysis_quartiles.do
mu= [0.0318505 0.0146464];
% estimate structural parameters and confidence intervals
run('estimate_params_02.m')

% predicted discharges and policy simulations


run('predictions_04.m')

run('discharge_experiment.m')

run('Consumer_Dynamics.m')


%% 2. estimates excluding first quartile
cd ..
cd quart1	
model='quart1'


run('parameters_01.m')

% import estimated home discharge rates and their variance-covariance matric
data = csvread('lagoccu_individual_home_4smedold_65IIINO1Q.csv', 1, 0);

%%%% gridsearch over starting value
tic
run('gridsearch.m')
toc

%%% exog. discharge rates
global mu;
mu= [0.0331017 0.014787];
% estimate structural parameters and confidence intervals
run('estimate_params_02.m')

% predicted discharges and policy simulations
model='quart1'
run('predictions_04.m')


%% 3. estimates excluding second quartile
cd ..
cd quart2
model='quart2'

run('parameters_01.m')

ylimits=[0.01 0.05];
% import estimated home discharge rates and their variance-covariance matric
data = csvread('lagoccu_individual_home_4smedold_65IIINO12Q.csv', 1, 0);

%%%% gridsearch over starting value
tic
run('gridsearch.m')
toc

%%% exog. discharge rates
mu= [0.0374803 0.0154008];

% estimate structural parameters and confidence intervals
run('estimate_params_02.m')

% predicted discharges and policy simulations
model='quart2'
run('predictions_04.m')


%%% 4. Exog discharge rates varying in occupancy

cd ..
cd baseline
% constructed in 6_export_fig3_homedischarge_VarCov.do
data = csvread('lagoccu_individual_home_4smedold_65IIIVarCov.csv', 1, 0);

cd ..
cd quartoccu
model='quartoccu'


run('parameters_01.m')

%% adjust private/medicaid discharge rate 85-95

global ylimits;
ylimits=[0.01 0.04];
global ylimitsextra;
ylimitsextra=[0.01 0.05];

%%% exog. discharge rates as a function of occupancy
global mu;

mudata= csvread('lagoccu_discharge_residual.csv', 1, 0);

global muoccu
muoccu=mudata(:, 2:3);

%%%% gridsearch over starting value
tic
run('gridsearch_muoccu.m')
toc


% estimate structural parameters and confidence intervals
run('estimate_params_muoccu_02.m')

% predicted discharges and policy simulations
model='quartoccu'
run('predictions_muoccu_04.m')

