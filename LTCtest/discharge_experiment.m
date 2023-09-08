
%%%% adjust Medicaid patient utility to match experiment discharge rates    

%avg_med=(dispriv_med'*occupSteadyPdf(12:36))/sum(occupSteadyPdf(12:36));

alpha = paramsMin(1); 
beta = paramsMin(2);
kappa = paramsMin(3);
mc = paramsMin(4);

%effort = (0.00:0.005:1.99);
effort=(0.00:0.01:1.99);
phiEffort = vertcat(zeros(10, 1), phiPart);
phieffort_count = vertcat(zeros(10, 1), phiPart);
homeDischLim = homeDisch2(11:nOccup, :);


Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0))+mu(1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf(11:35)+mu(2);   

Pr_priv_extra = ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0))+mu(1);
    
Pr_med_extra=ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf(1:35)+mu(2);   



%%%% objectuive function to find differential medicaid utility

medicaidu_x = @(x)matchmedicaid_discharge_home(x, costtau, revenue, delta, mu, Theta, psi,phiEffort, rho, dischShock_cons, nOccupLim, price, ...
    utility, homeDischLim, alpha, beta, kappa,mc,occupSteadyPdf);


x0=[0];
 A = [];
 b = [];
 Aeq = [];
 beq = [];
 lb = zeros(size(x0));
 ub = [];
 nlincon = [];
 options = optimoptions(@fmincon, 'MaxIterations', 100, ...
        'Display', 'iter', 'OptimalityTolerance', 1e-20, 'ConstraintTolerance', 1e-20);

deltau= fmincon(medicaidu_x, x0, A, b, Aeq, beq, lb, ub, nlincon, options);

utility(2)=utility(2)+deltau;

%%% Find exogenous discharge rate

mu(2)=0.031-0.0038;

diffloop=1

while diffloop>0.1
 
snfresults = providereffort2(alpha, beta, kappa, mc, costtau, phieffort_count, ...
    Theta, delta, mu, rho, psi, revenue, price, utility, dischShock_cons);

effortsnf_count = effort(snfresults(:,5))';

Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0))+mu(1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf_count(11:35)+mu(2);     
    
    
run('otherbeds_history_05.m')

run('endo_occupancy_06')

%% Simulate Length of Stay   

run('simulatelos_endo_08.m')

diffloop=abs(mean(LOS_med)-33)   
mu(2)=mu(2)+0.75*(-1/mean(LOS_med)+1/33);   
disp(diffloop)
disp(mu(2))
end

BigT=table(utility(2),mu(2),'VariableNames',{'Utility','ExogD'})

writetable(BigT,'parameters_experiment.xlsx','Sheet',1);
 
%%% provider effort

snfresults = providereffort2(alpha, beta, kappa, mc, costtau, phieffort_count, ...
    Theta, delta, mu, rho, psi, revenue, price, utility, dischShock_cons);

effortsnf_count = effort(snfresults(:,5))';

dispriv_pred = ones(nOccupLim,1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0));

dispriv_med = ones(nOccupLim,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf_count(11:35);
    
avg_med_base=(dispriv_med'*occupSteadyPdf(12:36))/sum(occupSteadyPdf(12:36));  


Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf_count(11:35)+mu(2);   
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct other (exogenous) beds history
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run('otherbeds_history_05.m')

run('endo_occupancy_06')

%% Simulate Length of Stay   

run('simulatelos_endo_08.m')

%% Counterfactuals

%effort = (0.00:0.00001:0.02);
effort=(0.00:0.01:1.99);
phieffort_count = vertcat(zeros(10, 1), phiPart);




%%% counterfactuals

%%% load value functions

valueSnfMcdOld = snfresults(:,2);
valueSnfPrvOld = snfresults(:,1);
valueSnfNonOld = snfresults(:,3);

profit = revenue - mc;
    
    % probability of discharge due to exogenous reasons and patient effort
probDisch = mu + beta^2 / (costtau * kappa) * mean(max(kappa * ...
        price - utility - dischShock_cons(:,1) + dischShock_cons(:,2), 0));
    
nOccup = size(Theta, 1);

%%%% perdiod 3 incentives

dinc3=165.83/36*214/100;

valueSnfMcd3 = (profit(2) - effort.^costtau + ... %flow payoff
            delta * Theta * valueSnfMcdOld * max(1 - probDisch(2) - ...
            alpha * effort, 0) + ... % no discharge
            delta * Theta * ((phiEffort .* (rho * valueSnfPrvOld + (1 - rho) * ...
            valueSnfMcdOld)) + (1-phiEffort) .* valueSnfNonOld) * ...
            min(probDisch(2) + alpha * effort, 1)) + ...
            delta*min(probDisch(2)-mu(2)+ alpha * effort,1)*dinc3 ; % discharge
               
[valueSnfMcd3max,effortmed3]=max(valueSnfMcd3,[],2);    
        
effort3=effort(effortmed3)';

Pr_med3 = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effort3(11:35)+mu(2);  
    
avg_med=(Pr_med'*occupSteadyPdf(12:36))/sum(occupSteadyPdf(12:36))-mu(2);      
    
avg_med3=(Pr_med3'*occupSteadyPdf(12:36))/sum(occupSteadyPdf(12:36))-mu(2);    

%%%% period 2 incentives

dinc2=236.35/36*214/100;

valueSnfMcd2 = (profit(2) - effort.^costtau + ... %flow payoff
            delta * Theta * valueSnfMcd3max * max(1 - probDisch(2) - ...
            alpha * effort, 0) + ... % no discharge
            delta * Theta * ((phiEffort .* (rho * valueSnfPrvOld + (1 - rho) * ...
            valueSnfMcdOld)) + (1-phiEffort) .* valueSnfNonOld) * ...
            min(probDisch(2) + alpha * effort, 1)) + ...
            delta*min(probDisch(2)-mu(2)+ alpha * effort,1)*dinc2 ; % discharge

[valueSnfMcd2max,effortmed2]=max(valueSnfMcd2,[],2);    
        
effort2=effort(effortmed2)';

Pr_med2 = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effort2(11:35)+mu(2); 
    
avg_med2=(Pr_med2'*occupSteadyPdf(12:36))/sum(occupSteadyPdf(12:36))-mu(2); 

%%%% period 1 incentives

dinc1=(641+406.7)/2/36*214/100;

valueSnfMcd1 = (profit(2) - effort.^costtau + ... %flow payoff
            delta * Theta * valueSnfMcd2max * max(1 - probDisch(2) - ...
            alpha * effort, 0) + ... % no discharge
            delta * Theta * ((phiEffort .* (rho * valueSnfPrvOld + (1 - rho) * ...
            valueSnfMcdOld)) + (1-phiEffort) .* valueSnfNonOld) * ...
            min(probDisch(2) + alpha * effort, 1)) + ...
            delta*min(probDisch(2)-mu(2)+ alpha * effort,1)*dinc1 ; % discharge

[valueSnfMcd1max,effortmed1]=max(valueSnfMcd1,[],2);    
        
effort1=effort(effortmed1)';

Pr_med1 = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effort1(11:35)+mu(2); 
    
avg_med1=(Pr_med1'*occupSteadyPdf(12:36))/sum(occupSteadyPdf(12:36))-mu(2); 

%%%% Graphics

Pr_Homebase=Pr_med-mu(2);
Pr_Home3=Pr_med3-mu(2);
Pr_Home2=Pr_med2-mu(2);
Pr_Home1=Pr_med1-mu(2);


dp = figure;
plot(occupLim, Pr_Homebase, 'LineStyle', '-', 'Color', 'blue', 'LineWidth', 3)
hold on;
plot(occupLim, Pr_Home3, 'LineStyle', '--', 'Color', 'blue', 'LineWidth', 2)
scatter(occupLim, Pr_Home2,'Marker','o','MarkerEdgeColor','blue','MarkerFaceColor','blue')
scatter(occupLim, Pr_Home1,'Marker','d','MarkerEdgeColor','blue','MarkerFaceColor','blue')
ylim([0.0002 0.02])
hold off;
xlabel('occupancy rate', 'FontSize', 16)
ylabel('discharge rate', 'FontSize', 16)
legend({'Baseline', '>30 days', '15-30 days', ...
    '<15 days'}, 'location', 'northwest', 'FontSize', 16)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(dp, 'Units', 'Inches')
pos = get(dp, 'Position');
lgd = legend;
set(dp, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
    print(dp, 'FigureF1', '-dpdf', '-r0')
    

panelB=zeros(2,2);

%%% resultsd from experiment in Jones (1986)
panelB(1,1) = 0.0038;
panelB(2,1) = 0.007;

%%% own results
panelB(1,2) = avg_med_base;
panelB(2,2) = avg_med1;

BigT=table(panelB(:,1),panelB(:,2),'VariableNames',{'Experiment','Model'},'RowNames',{'ControlGroup' 'TreatmentGroup'})

writetable(BigT,'PanelB_experiment.xlsx','Sheet',1);

    
    