function crit = crit_cond2(x, costtau, revenue, delta, mu, Theta, psi, ...
    phiEffort, rho, dischShock_cons, nOccupLim, price, ...
    utility, homeDischLim)

    alpha = x(1);
    beta = x(2);
    kappa = x(3);
    mc = x(4);
    
    effort=(0.00:0.01:1.99); 

    snfresults = providereffort2(alpha, beta, kappa, mc, costtau, phiEffort, ...
        Theta, delta, mu, rho, psi, revenue, price, utility, dischShock_cons);
    
    optsnfeffort = effort(snfresults(:,5))';
    optsnfeffortLim = optsnfeffort(11:35);
            
    % predict discharge rates given current parameter estimates

    disPredPrvCond = ones(nOccupLim,1) * beta^2 / kappa / costtau * ...
        mean(max(kappa*price(1) - utility(1) - dischShock_cons(:,1) + ...
        dischShock_cons(:,2), 0));
    disPredMcdCond = ones(nOccupLim,1) * beta^2 / kappa / costtau * ...
        mean(max(kappa*price(2) - utility(2) - dischShock_cons(:,3) + ...
        dischShock_cons(:,4), 0)) + alpha * optsnfeffortLim;


    % least squares criterion for predicted/observed discharge rates

    crit = sum((disPredPrvCond(1:nOccupLim) - homeDischLim(1:nOccupLim, 1)).^2) + ... 
        sum((disPredMcdCond(1:nOccupLim) - homeDischLim(1:nOccupLim, 2)).^2);
        
end