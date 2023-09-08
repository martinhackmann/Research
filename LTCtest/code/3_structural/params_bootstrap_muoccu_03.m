%% THIS PROGRAM GENERATES BOOTSTRAP CONFIDENCE INTERVALS FOR ESTIMATED PARAMETERS %%

nBoot = 3;
paramsBootEst = zeros(nBoot, 4);
paramsBootCent = zeros(nBoot, 4);
effortBoot = zeros(nOccup,nBoot);
homeDischBoot1keep = zeros(size(homeDisch1, 1), nBoot);
meanboot = homeDisch1;
meanboot(36:70)=meanboot(36:70)-meanboot(1:35); %%% transform into raw estimates (private and medicaid difference)

alphaBoot = 0.05;

%rng(1234567)

for b = 1:nBoot
    
    dischShock_cons_boot = -evrnd(0, 1, nPayer*2, nSim)';
    %dischShock0 = -evrnd(0, 1, nOccupLim, nPayer, nSim);
    %dischShock1 = -evrnd(0, 1, nOccupLim, nPayer, nSim);
 
    % draw home discharge rates (regression coefficients) from their
    % distribution    
    homeDischBoot1 = mvnrnd(meanboot, homeDischVar);
    homeDischBoot2 = [homeDischBoot1(1:35)', homeDischBoot1(1:35)'+homeDischBoot1(36:70)'];

    run('gridsearch_bootstrap_muoccu.m')
    
    b
    
    % estimation algorithm for each bootstrap draw
    paramsBootEst(b, :) = estimationalgo_joint2_muoccu(dischShock_cons, nOccup, ...
        nOccupLim, homeDischBoot2, utility, price, revenue, delta, muoccu, ...
        Theta, psi, phiPart, rho, costtau, xstart);
    
    paramsBootCent(b, :) = paramsBootEst(b, :) - paramsMin;
     
    paramsBootEst(b, :)
    
    csvwrite('paramsBootEst.csv',paramsBootEst)
    
end


% calculate confidence intervals and p-values
paramsBootSort = sort(paramsBootEst, 1);
paramsCiUpper = floor((nBoot + 1) * (1 - alphaBoot / 2));
paramsCiLower = ceil((nBoot + 1) * alphaBoot / 2);
sampleParamsLower = paramsBootSort(paramsCiLower, :);
sampleParamsUpper = paramsBootSort(paramsCiUpper, :);
paramsCI = [sampleParamsLower; sampleParamsUpper];
paramsSE = sqrt(var(paramsBootEst));
StrucParameters=[sampleParamsLower; paramsMin; sampleParamsUpper];

rowNames = {'Min','Fit','Max'};
colNames = {'alpha','beta','kappa','mc'};
StrucParametersTable = array2table(StrucParameters,'RowNames',rowNames,'VariableNames',colNames)

csvwrite('StrucParameters.csv',StrucParameters)
writetable(StrucParametersTable)

