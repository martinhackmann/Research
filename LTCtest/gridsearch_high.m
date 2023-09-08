%%%%

homeDisch2 = data(:, 2:3);
homeDisch1 = [homeDisch2(:, 1); homeDisch2(:, 2)];
homeDischLim1 = [homeDisch2(11:nOccup, 1); homeDisch2(11:nOccup, 2)];

% variance-covariance of home discharge rates
homeDischVarPrv = data(:, 4:38);
homeDischVarMcd = data(:, 39:73);
homeDischVarMcdCOV = data(1:35, 74:108);
homeDischVar = [homeDischVarPrv, homeDischVarMcdCOV; transpose(homeDischVarMcdCOV), homeDischVarMcd];

homeDischLim = homeDisch2(11:nOccup, :);
phiEffort=vertcat(zeros(10,1),phiPart);


provider_x = @(x)crit_cond2(x, costtau, revenue, delta, mu, Theta, ...
        psi, phiEffort, rho, dischShock_cons, nOccupLim, price, utility, ...
        homeDischLim);
    
applyToGivenRow = @(func, matrix) @(row) func(matrix(row, :))
applyToRows = @(func, matrix) arrayfun(applyToGivenRow(func, matrix), 1:size(matrix,1))'
    

%%%% define grid

%%% number per dimension

gridcount=5;
gridcountmc=5;
alphaparam = linspace(0.02,0.05,gridcount);  %list of places to search for first parameter
betaparam = linspace(0.2,0.25,gridcount);        %list of places to search for second parameter
kappaparam = linspace(0.02,0.075,gridcount);
mcparam = linspace(2.5,5,gridcountmc);

rowstot=gridcount^3*gridcountmc;

[A,B,K,M] = ndgrid(alphaparam,betaparam,kappaparam,mcparam);
Gridmat=[reshape(A,[rowstot,],1),reshape(B,[rowstot,],1),reshape(K,[rowstot,],1),reshape(M,[rowstot,],1)];
%% add starting guesses

Gridmat=[Gridmat; 0.0265    0.2025    0.0323    5.4375]
Gridmat=[Gridmat; 0.031   0.2147    0.035    5.745]
Gridmat=[Gridmat; 0.0357    0.2443    0.0328    6.0745]
Gridmat=[Gridmat; 0.0254,    0.2042,    0.0408,    5.65]
Gridmat=[Gridmat; 0.0254,    0.2042,    0.0408,    5.65]
Gridmat=[Gridmat; 0.0259,    0.2222,    0.0535,    3.0762]



%fitresult=applyToRows(provider_x,Gridmat);


fitresult=ones(length(Gridmat),1);

parfor i=1:length(Gridmat)
 fitresult(i)=provider_x(Gridmat(i,:));
end

[minval, minidx] = min(fitresult);

global xstart
xstart=Gridmat(minidx,:);

%bestalpha = Gridmat(minidx,1);
%bestbeta = Gridmat(minidx,2);
%bestkappa = Gridmat(minidx,3);
%bestmc = Gridmat(minidx,4);

