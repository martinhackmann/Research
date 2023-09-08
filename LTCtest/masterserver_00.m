%% THIS PROGRAM GENERATES STRUCTURAL ESTIMATES FOR HACKMANN, POHL, AND ZIEBARTH (2022) %%

clear;
% folder in the GitHub repo that contains the code and input files for the structural estimation; XXX depends on user
%cd XXX/3_structural
cd '/u/home/h/hackmann/Projects/LTCincentives';
%addpath(XXX/3_structural);
%addpath('C:/Users/Martin Hackmann/Documents/GitHub/LTCincentives/code/3_structural');
rng(123456)

%% set fixed parameters and other objects for all runs
run('parameters_01.m')

%% 1. baseline estimates (full sample)
cd baseline

% import estimated home discharge rates and their variance-covariance matric
data = csvread('lagoccu_individual_home_4smedold_65IIIVarCov.csv', 1, 0);

%% adjust private/medicaid discharge rate 85-95
%%data(:,3)=data(:,3)-mean(data(22:31,2))+0.027679;
%%data(:,2)=data(:,2)-mean(data(22:31,2))+0.027679;

global xstart;
xstart=[0.0271,    0.9423,    0.0369,    5.4197];
global ylimits;
ylimits=[0.01 0.04];
global ylimitsextra;
ylimitsextra=[0.01 0.05];
% estimate structural parameters and confidence intervals
run('estimate_params_02.m')

% predicted discharges and policy simulations
run('predictions_04.m')


%% 2. estimates excluding first quartile
cd ..
cd quart1	

% import estimated home discharge rates and their variance-covariance matric
data = csvread('../../../Results/1_weekly_4states/output/lagoccu_individual_home_4smedold_65IIINO1Q.csv', 1, 0);

% estimate structural parameters and confidence intervals
run('estimate_params_02.m')

% predicted discharges and policy simulations
run('predictions_04.m')


%% 3. estimates excluding second quartile
cd ..
cd quart2
ylimits=[0.01 0.05];
% import estimated home discharge rates and their variance-covariance matric
data = csvread('../../../Results/1_weekly_4states/output/lagoccu_individual_home_4smedold_65IIINO12Q.csv', 1, 0);

xstart=[0.0357,    1.22,    0.038,    6.0745];

% estimate structural parameters and confidence intervals
run('estimate_params_02.m')

% predicted discharges and policy simulations
run('predictions_04.m')

