function crit = matchmedicaid_discharge_home(x, costtau, revenue, delta, mu, Theta, psi, ...
    phiEffort, rho, dischShock_cons, nOccupLim, price, ...
    utility, homeDischLim, alpha, beta, kappa,mc,occupSteadyPdf)

    utiltemp=utility;
    utiltemp(2)=utility(2)+x;
    
    mutemp=mu;
    mutemp(2)=0.031-0.0038;
    
    effort=(0.00:0.01:1.99); 

    snfresults = providereffort2(alpha, beta, kappa, mc, costtau, phiEffort, ...
        Theta, delta, mutemp, rho, psi, revenue, price, utiltemp, dischShock_cons);
    
    optsnfeffort = effort(snfresults(:,5))';
    optsnfeffortLim = optsnfeffort(11:35);
            
    % predict discharge rates given current parameter estimates

    disPredPrvCond = ones(nOccupLim,1) * beta^2 / kappa / costtau * ...
        mean(max(kappa*price(1) - utiltemp(1) - dischShock_cons(:,1) + ...
        dischShock_cons(:,2), 0));
    disPredMcdCond = ones(nOccupLim,1) * beta^2 / kappa / costtau * ...
        mean(max(kappa*price(2) - utiltemp(2) - dischShock_cons(:,3) + ...
        dischShock_cons(:,4), 0)) + alpha * optsnfeffortLim;


    % least squares criterion for predicted/observed discharge rates

    crit = (0.0038-(disPredMcdCond'*occupSteadyPdf(12:36))/sum(occupSteadyPdf(12:36)))^2 + ...
           (0.0038+mutemp(2)-0.031)^2;
        
end