function solutionSNF=providereffort2_muoccu(alpha, beta, kappa, mc, costtau, phi, ...
    Theta, delta, muoccu, rho, psi, revenue, price, utility, dischShock_cons)

    profit = revenue - mc;
    
    % probability of discharge due to exogenous reasons and patient effort
    probDischP = muoccu(:,1) + beta^2 / (costtau * kappa) * mean(max(kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2), 0));
    
    probDischM = muoccu(:,2) + beta^2 / (costtau * kappa) * mean(max(kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2), 0));
    
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
 
    
    %x%
    while metric > tol

        valueSnfPrv = (profit(1) - effort.^costtau + ... %flow payoff
            repmat(delta * Theta * ((1 - psi(1)) * valueSnfPrvOld + psi(1) * ...
            (valueSnfMcdOld)),1,length(effort)).* max(1 - probDischP - alpha * effort, 0) + ... % no discharge
            repmat(delta * Theta * ((phi .* (rho * valueSnfPrvOld + (1 - rho) * ...
            (valueSnfMcdOld))) + (1-phi) .* valueSnfNonOld),1,length(effort)).* ...
            min(probDischP + alpha * effort, 1));  % discharge
 
        [valueSnfPrv,effortpriv]=max(valueSnfPrv,[],2); 
        
        valueSnfMcd = (profit(2) - effort.^costtau + ... %flow payoff
            repmat(delta * Theta * valueSnfMcdOld,1,length(effort)).* max(1 - probDischM - ...
            alpha * effort, 0) + ... % no discharge
            repmat(delta * Theta * ((phi .* (rho * valueSnfPrvOld + (1 - rho) * ...
            (valueSnfMcdOld))) + (1-phi) .* valueSnfNonOld),1,length(effort)).* ...
            min(probDischM + alpha * effort, 1)); % discharge
        
        [valueSnfMcd, effortmed]=max(valueSnfMcd,[],2); 
        
        valueSnfNon = delta * Theta * (((1 - phi) .* valueSnfNonOld) + ...
            (phi .* (rho * valueSnfPrvOld + (1 - rho) * (valueSnfMcdOld))));
        
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