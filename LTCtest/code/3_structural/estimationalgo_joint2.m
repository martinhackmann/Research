% estimation algorithm (do once for point estimates and [nBoot] times for 
% confidence intervals

function [paramsMin, effortsnf] = estimationalgo_joint2(dischShock_cons, ...
    nOccup, nOccupLim, homeDisch2, utility, price, revenue, delta, mu, ...
    Theta, psi, phiPart, rho, costtau, xstart)
    
    homeDischLim = homeDisch2(11:nOccup, :);
    phiEffort=vertcat(zeros(10,1),phiPart);

    % minimize least squares criterion wrt parameters
    provider_x = @(x)crit_cond2(x, costtau, revenue, delta, mu, Theta, ...
        psi, phiEffort, rho, dischShock_cons, nOccupLim, price, utility, ...
        homeDischLim);
    
    
    x0=xstart;
    
    
    
    
    
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

    
    paramsMin = fmincon(provider_x, x0, A, b, Aeq, beq, lb, ub, nlincon, options);
    

    % recover optimal effort
    effort=(0.00:0.01:1.99); 
    snfresults = providereffort2(paramsMin(1), paramsMin(2), paramsMin(3), ...
        paramsMin(4), costtau, phiEffort, Theta, delta, mu, rho, psi, ...
        revenue, price, utility, dischShock_cons);
    effortsnf = effort(snfresults(:,5))';

end