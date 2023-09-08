function solutionSNF = providereffort2_comp01(alpha, beta, kappa, mc, costtau, phi, ...
    Theta, delta, mu, rho, psi, revenue, price, utility, dischShock_cons, comp)

    profit = revenue - mc;
    
    % probability of discharge due to exogenous reasons and patient effort
    probDisch = mu + beta^2 / (costtau * kappa) * mean(max(kappa * ...
        price - utility - dischShock_cons(:,1) + dischShock_cons(:,2), 0));
    
    nOccup = size(Theta, 1);
    
    valueSnfNon = zeros(nOccup, 1);
    valueSnfPrv = zeros(nOccup, 1);
    valueSnfMcd = zeros(nOccup, 1);

    valueSnfNonOld = valueSnfNon;
    valueSnfPrvOld = valueSnfPrv;
    valueSnfMcdOld = valueSnfMcd;

    tol = 1e-8;
    metric = tol + 1000;
    
    effort=(0.00:0.01:1.99); 
   
    while metric > tol

        valueSnfPrv = (profit(1) - effort.^costtau + ... %flow payoff
            delta * Theta * ((1 - psi(1)) * valueSnfPrvOld + psi(1) * ...
            (valueSnfMcdOld + comp)) * max(1 - probDisch(1) - alpha * effort, 0) + ... % no discharge
            delta * Theta * ((phi .* (rho * valueSnfPrvOld + (1 - rho) * ...
            (valueSnfMcdOld + comp))) + (1-phi) .* valueSnfNonOld) * ...
            min(probDisch(1) + alpha * effort, 1));  % discharge
 
        [valueSnfPrv,effortpriv]=max(valueSnfPrv,[],2); 
        
        valueSnfMcd = (profit(2) - effort.^costtau + ... %flow payoff
            delta * Theta * (valueSnfMcdOld) * max(1 - probDisch(2) - ...
            alpha * effort, 0) + ... % no discharge
            delta * Theta * ((phi .* (rho * valueSnfPrvOld + (1 - rho) * ...
            (valueSnfMcdOld + comp))) + (1-phi) .* valueSnfNonOld) * ...
            min(probDisch(2) + alpha * effort, 1)); % discharge
        
        [valueSnfMcd, effortmed]=max(valueSnfMcd,[],2); 
        
        valueSnfNon = delta * Theta * (((1 - phi) .* valueSnfNonOld) + ...
            (phi .* (rho * valueSnfPrvOld + (1 - rho) * (valueSnfMcdOld + comp))));
        
        metricAll = zeros(3, 1);
        metricAll(1) = max(abs(valueSnfNon - valueSnfNonOld));
        metricAll(2) = max(abs(valueSnfPrv - valueSnfPrvOld));
        metricAll(3) = max(abs(valueSnfMcd - valueSnfMcdOld));    
        metric = max(metricAll);

        valueSnfNonOld = valueSnfNon;
        valueSnfPrvOld = valueSnfPrv;
        valueSnfMcdOld = valueSnfMcd;

    end

    solutionSNF = [valueSnfPrv valueSnfMcd valueSnfNon effortpriv effortmed];
    
end