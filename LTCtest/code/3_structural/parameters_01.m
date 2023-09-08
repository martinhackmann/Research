%% THIS PROGRAM SETS PARAMETERS AND OTHER OBJECTS THAT ARE FIXED FOR ALL RUNS OF THE STRUCTURAL ESTIMATION %%

% variance of consumer taste shocks
sigma = 1;  

% weekly discount factor                    
delta = 0.95^(1/52);            

%%% median prices lines 322/323 in 01_analyis_main.do
% weekly revenue
revenue = [7*2.58 7*2.14]; 


% private and Medicaid prices   
global price;
price = [revenue(1) 0];         

% utility (set arbitrarily)
global utility;
u = 3.5;                          
utility = [u, u];

% vectors with occupancy rates
occup = (0.65:0.01:0.99)';
nOccup = size(occup, 1); 
occupLim = occup(11:nOccup);
nOccupLim = size(occupLim, 1);
occupPart = occup(11:nOccup);
nOccupPart = size(occupPart, 1);

% number of payer types
nPayer = 2;

% exogenous discharge rate
% lines 240 and 267 in 2_analysis_quartiles.do
mu = [0.032 0.0147];

% payer type change probability (probability that resident is on Medicaid next period)
%% line 568 in 01_analysis_main.do
psi = [0.011 1];

% bed refill probability (assume prob = 0 for occup < 0.75)
%% See 13_Extradescriptives.do (line 279)
phiData = csvread('../baseline/Refillodds_all.csv');
phiPart = phiData(11:35,3);
phiPart(phiPart < 0) = 0;            

% fraction of new residents who are private payers
% line 33 in 10_Prepare_states_dischargeanalysis0005keepmed.do
rho = 0.78;

% cost parameter (cost fucntion=e^costtau, here e^2)
costtau = 2;

% occupancy transition matrix: import data
% See 13_Extradescriptives.do (line 363)
occupTrans = csvread('../baseline/occupancy_transitions.csv', 1, 0);

%%% drop zeros in columns 1:2 (missing values)
miss=occupTrans(:,1)>0
occupTrans=occupTrans(miss,:);
miss=occupTrans(:,2)>0
occupTrans=occupTrans(miss,:);

occupTrans(:, 1) = occupTrans(:, 1) * 100;
occupTrans(:, 2) = occupTrans(:, 2) * 100;

% total number of observations for each of current occupancy rates
occupNextTotal = zeros(nOccup, 1);
for j = 1:size(occupTrans, 1)
    for o = 1:nOccup
        if occupTrans(j, 1) == 100 * occup(o) && occupTrans(j, 2) ~= 0 && occupTrans(j, 2)>64 && occupTrans(j, 2)<100 
            occupNextTotal(o) = occupNextTotal(o) + occupTrans(j, 3);
        end
    end
end

% for each of current occupancy rates, what fraction does each of next period's occupancy rates have?
for j = 1:size(occupTrans, 1)
    for o = 1:nOccup
        if occupTrans(j, 1) == 100 * occup(o)
            occupTrans(j, 3) = occupTrans(j, 3) / occupNextTotal(o);
        end
    end
end

% put transition probabilities in square matrix
Theta = zeros(nOccup);
for j = 1:size(occupTrans, 1)
    for o1 = 1:nOccup
        for o2 = 1:nOccup
            if 100 * occup(o1) == occupTrans(j, 1) && 100 * occup(o2) == ...
                occupTrans(j, 2)
                Theta(o1, o2) = occupTrans(j, 3);
            end
        end
    end
end

% CDF of occupancy transitions for each current occupancy rate
occupTransCdf = zeros(size(Theta));
for i = 1:size(Theta, 1)
    occupTransCdf(i, 1) = Theta(i, 1);
    for j = 2:size(Theta, 2)
        occupTransCdf(i, j) = occupTransCdf(i, j-1) + Theta(i, j);
    end
end

ThetaPart = Theta(11:nOccup, 11:nOccup);
occupTransPartCdf = zeros(size(ThetaPart));
for i = 1:size(ThetaPart, 1)
    occupTransPartCdf(i, 1) = ThetaPart(i, 1);
    for j = 2:size(ThetaPart, 2)
        occupTransPartCdf(i, j) = occupTransPartCdf(i, j-1) + ThetaPart(i, j);
    end
end

% steady state occupancy distribution
% See 13_Extradescriptives.do (line 341)
occupSteady = csvread('../baseline/occupancy_steadystate.csv', 1, 0);
occupSteadyPdf = occupSteady(:, 2) / sum(occupSteady(:, 2));
occupSteadyCdf = zeros(size(occupSteady, 1), 1);
occupSteadyCdf(1, 1) = occupSteadyPdf(1, 1);
for j = 2:size(occupSteady, 1)
    occupSteadyCdf(j, 1) = occupSteadyPdf(j) + occupSteadyCdf(j-1, 1);
end

occupSteadyPartCdf = occupSteadyCdf(12:36, 1);
occupSteadyCdf = occupSteadyCdf(2:36);

% number of simulation draws
global nSim
nSim = 1000000;

global Numsim
Numsim = 1000000;

% number of time periods (weeks)
global T
T=1000;

% discharge shocks
dischShock0 = -evrnd(0, 1, nOccupLim, nPayer, nSim);

global dischShock_cons;

rng(1000);
dischShock_cons = -evrnd(0, 1, nPayer*2, nSim)';
dischShock_cons(:,3)=dischShock_cons(:,1);
dischShock_cons(:,4)=dischShock_cons(:,2);

% simulation shocks
simu_shock1 = rand(nSim,T);
simu_shock2 = rand(nSim,T);
simu_shock3 = rand(nSim,T);
simu_shock4 = rand(nSim,T);
occushockt = rand(nSim,1);

%%% load occupancy distribution
% See 13_Extradescriptives.do (line 402)
occudist = csvread('../baseline/occuinterdistribution.csv', 1, 0);


%%%%%%%%%%%%%%%%%% Descriptive Figure 2

%%% Figure 2a

occupgraph = occupSteady(:, 1) * 100;
oc = figure;
bar(occupgraph(12:37), occupSteadyPdf(12:37), 'b')
xlabel('occupancy rate', 'FontSize', 16)
ylabel('fraction', 'FontSize', 16)
axis([74 101 0 0.08])
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(oc, 'Units', 'Inches')
pos = get(oc, 'Position');
set(oc, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
print(oc, 'Figure2a', '-dpdf', '-r0')


%%% Figure 2b


occugraph = occudist(:, 1) * 100;
occupdfgraph = occudist(:, 2) / sum(occudist(:, 2));

od = figure;
bar(occugraph(22:42), occupdfgraph(22:42), 'b')
xlabel('percentage point change', 'FontSize', 16)
ylabel('fraction', 'FontSize', 16)
axis([-11 11 0 0.16])
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(od, 'Units', 'Inches')
pos = get(od, 'Position');
set(od, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
print(od, 'Figure2b', '-dpdf', '-r0')

%%% Figure 2c

% endogenous occupancy rates
% see lines 94-133 in ExtraDescriptives.do
arrivpdf = [0.38 0.26 0.14 0.08 0.05 0.03 0.02 0.01 0.01 0.03];
arrivCDF = zeros(1,size(arrivpdf,2));
for i = 1:size(arrivpdf,2)
    arrivCDF(i) = arrivpdf(i);
    for i = 2:size(arrivpdf,2)
        arrivCDF(i) = arrivCDF(i-1) + arrivpdf(i);
    end
end
k = 10;
beds = 100;

%%%% Figure 2c

arrivals=[0 1 2 3 4 5 6 7 8 9];
ar = figure;
bar(arrivals, arrivpdf, 'b')
xlabel('new arrivals in percent of number of beds', 'FontSize', 16)
ylabel('fraction', 'FontSize', 16)
xticklabels({'0', '1', '2', '3', '4', '5', '6', '7', '8', '9+'});
axis([-1 10 0 0.4])
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(ar, 'Units', 'Inches')
pos = get(ar, 'Position');
set(ar, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
print(ar, 'Figure2c', '-dpdf', '-r0')

%%%% Figure 2d

run('impulsegraph.m')

% simulation weeks
sw = 100000;
stead = 5000;
occuphist = zeros(1, sw);
arrivaldraw = rand(1,sw);
payertypedraw = rand(k,sw);

% occupancy shocks
simu_shock_occ = rand(1,sw);

% discharge/payer type transition
dis_shock_sample = rand(beds,sw);
trans_shock_sample = rand(beds,sw);

% Initial occ 90%
occumarkerpost = 27;

% with 56 beds in sample (out of 100) start out with 50 people in there (25 mcaid 25 private)
priv_post = 25;
mcaid_post = 25;
otherbeds_post = round(beds*occup(occumarkerpost))-priv_post-mcaid_post;
