%% THIS PROGRAM ESTIMATES STRUCTURAL PARAMETERS %%

% observed home discharge rates
homeDisch2 = data(:, 2:3);
homeDisch1 = [homeDisch2(:, 1); homeDisch2(:, 2)];
homeDischLim1 = [homeDisch2(11:nOccup, 1); homeDisch2(11:nOccup, 2)];

% variance-covariance of home discharge rates
homeDischVarPrv = data(:, 4:38);
homeDischVarMcd = data(:, 39:73);
homeDischVarMcdCOV = data(1:35, 74:108);
homeDischVar = [homeDischVarPrv, homeDischVarMcdCOV; transpose(homeDischVarMcdCOV), homeDischVarMcd];

% estimate parameters and effort function
[paramsMin, effortsnf] = estimationalgo_joint2(dischShock_cons, ...
    nOccup, nOccupLim, homeDisch2, utility, price, revenue, delta, mu, ...
    Theta, psi, phiPart, rho, costtau, xstart);


disp(paramsMin)

% bootstrap confidence intervals
run('params_bootstrap_03.m')

% save parameters
estCI = [paramsMin', paramsSE', paramsCI'];

BigT=table(estCI(:,1),estCI(:,2),estCI(:,3),estCI(:,4),'VariableNames',{'Estimate','StandardError','ConfIntLB','ConfIntUB'},'RowNames',{'alpha' 'beta' 'kappa' 'weeklyMC'})
writetable(BigT,['structural_est_' model '.xlsx'],'Sheet',1);

