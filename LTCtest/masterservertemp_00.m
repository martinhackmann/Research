%% THIS PROGRAM GENERATES STRUCTURAL ESTIMATES FOR HACKMANN, POHL, AND ZIEBARTH (2022) %%

clear;

parpool(12, 'IdleTimeout', Inf)

% folder in the GitHub repo that contains the code and input files for the structural estimation; XXX depends on user
%cd XXX/3_structural
cd '/u/home/h/hackmann/Projects/LTCincentives_old';
%addpath(XXX/3_structural);
addpath('/u/home/h/hackmann/Projects/LTCincentives_old');
rng(1234567)

disp('Prepare Analysis')
disp('base')

%% set fixed parameters and other objects for all runs
run('parameters_01.m')

%% 1. baseline estimates (full sample)
cd baseline

% import estimated home discharge rates and their variance-covariance matric
data = csvread('../lagoccu_individual_home_4smedold_65IIIVarCov.csv', 1, 0);

%% adjust private/medicaid discharge rate 85-95
%%data(:,3)=data(:,3)-mean(data(22:31,2))+0.027679;
%%data(:,2)=data(:,2)-mean(data(22:31,2))+0.027679;

%%%% gridsearch over starting value
tic
run('gridsearch.m')
toc

%global xstart;
%xstart=[0.0271,    0.2071,    0.0435,    5.4197];
global ylimits;
ylimits=[0.01 0.04];
global ylimitsextra;
ylimitsextra=[0.01 0.05];
%%% exog. discharge rates
global mu;
mu= [0.0318505 0.0146464];
% estimate structural parameters and confidence intervals
run('estimate_params_02.m')
%run('estimate_params_noboot_02.m')

% predicted discharges and policy simulations
run('predictions_04.m')

%run('discharge_experiment.m')

%run('Consumer_Dynamics.m')


%% 2. estimates excluding first quartile
cd ..
cd quart1	

% import estimated home discharge rates and their variance-covariance matric
data = csvread('../lagoccu_individual_home_4smedold_65IIINO1Q.csv', 1, 0);

%%%% gridsearch over starting value


tic
%run('gridsearch.m')
toc

%%% exog. discharge rates
global mu;
mu= [0.0331017 0.014787];
% estimate structural parameters and confidence intervals
%run('estimate_params_02.m')

% predicted discharges and policy simulations
%run('predictions_04.m')


%% 3. estimates excluding second quartile
cd ..
cd quart2
ylimits=[0.01 0.05];
% import estimated home discharge rates and their variance-covariance matric
data = csvread('../lagoccu_individual_home_4smedold_65IIINO12Q.csv', 1, 0);

%%%% gridsearch over starting value

tic
%run('gridsearch.m')
toc

%%% exog. discharge rates
mu= [0.0374803 0.0154008];

% estimate structural parameters and confidence intervals
%run('estimate_params_02.m')

% predicted discharges and policy simulations
%run('predictions_04.m')


%%% 4. Exog discharge rates varying in occupancy

cd ..
cd quartoccu

data = csvread('../lagoccu_individual_home_4smedold_65IIIVarCov.csv', 1, 0);

%% adjust private/medicaid discharge rate 85-95
%%data(:,3)=data(:,3)-mean(data(22:31,2))+0.027679;
%%data(:,2)=data(:,2)-mean(data(22:31,2))+0.027679;


%global xstart;
%xstart=[0.0254,    0.2042,    0.0408,    5.65];



global ylimits;
ylimits=[0.01 0.04];
global ylimitsextra;
ylimitsextra=[0.01 0.05];

%%% exog. discharge rates as a function of occupancy
global mu;

mudata= csvread('../lagoccu_discharge_residual.csv', 1, 0);

global muoccu
muoccu=mudata(:, 2:3);

%%%% gridsearch over starting value
tic
%run('gridsearch_muoccu.m')
toc


% estimate structural parameters and confidence intervals
%run('estimate_params_muoccu_02.m')

% predicted discharges and policy simulations
%run('predictions_muoccu_04.m')

