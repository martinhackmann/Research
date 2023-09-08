% estimation algorithm (do once for point estimates and [nBoot] times for 
% confidence intervals

function [paramsMin, effortsnf] = estimationalgo_joint2_muoccu(dischShock_cons, ...
    nOccup, nOccupLim, homeDisch2, utility, price, revenue, delta, muoccu, ...
    Theta, psi, phiPart, rho, costtau, xstart)
    
    homeDischLim = homeDisch2(11:nOccup, :);
    phiEffort=vertcat(zeros(10,1),phiPart);

    % minimize least squares criterion wrt parameters
    provider_x = @(x)crit_cond2_muoccu(x, costtau, revenue, delta, muoccu, Theta, ...
        psi, phiEffort, rho, dischShock_cons, nOccupLim, price, utility, ...
        homeDischLim);
    
    x0 = [0.0271,    0.9423,    0.0369,    5.4197];
    x0=xstart;
    %x0=[0.0197,    1.0408,    0.0616 ,   7.9893];
    %x0=[0.0211,    0.9023,    0.0369,    3.8197];
    %x0=[0.0197,    0.9686,    0.0440,    3.8745];
    %x0=[0.0237,    0.9686,    0.0440,    2.0745];
    
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = zeros(size(x0));
    ub = [];
    nlincon = [];
    options = optimoptions(@fmincon, 'MaxIterations', 100, ...
        'Display', 'iter', 'OptimalityTolerance', 1e-20, 'ConstraintTolerance', 1e-20);
    optionsminsearch = optimset('Display','iter','MaxIter', 50);
    

    %%x1=fminsearch(provider_x, x0,optionsminsearch);
    paramsMin = fmincon(provider_x, x0, A, b, Aeq, beq, lb, ub, nlincon, options);
    %% paramsMin=fminsearch(provider_x, x2,optionsminsearch);

    % recover optimal effort
    effort=(0.00:0.01:1.99); 
    snfresults = providereffort2_muoccu(paramsMin(1), paramsMin(2), paramsMin(3), ...
        paramsMin(4), costtau, phiEffort, Theta, delta, muoccu, rho, psi, ...
        revenue, price, utility, dischShock_cons);
    effortsnf = effort(snfresults(:,5))';

end