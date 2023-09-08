%% THIS PROGRAM CALCULATES AND PLOTS PREDICTED DISCHARGE RATES FOR ACTUAL AND COUNTERFACTUAL POLICIES %%

% estimated parameters  
alpha = paramsMin(1); 
beta = paramsMin(2);
gamma1 = 1;
gamma2 = 1;
gamma3 = 1;
kappa = paramsMin(3);
mc = paramsMin(4);

% predictions under actual policy
dispriv_pred = ones(nOccupLim,1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0));

dispriv_med = ones(nOccupLim,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0)) + alpha * effortsnf(11:35);

dp = figure;
plot(occupLim, dispriv_pred, 'LineStyle', '--', 'Color', 'black', 'LineWidth', 3)
hold on;
plot(occupLim, dispriv_med, 'LineStyle', '-', 'Color', 'blue', 'LineWidth', 2)
scatter(occupLim, homeDischLim1(1:25),'Marker','o','MarkerEdgeColor','black','MarkerFaceColor','black')
scatter(occupLim, homeDischLim1(26:50),'Marker','d','MarkerEdgeColor','blue','MarkerFaceColor','blue')
ylim(ylimits)
hold off;
xlabel('occupancy rate', 'FontSize', 16)
ylabel('discharge rate', 'FontSize', 16)
%legend({'pred., private', 'pred., Medicaid', 'obs., private', ...
%    'obs., Medicaid'}, 'location', 'southeast', 'FontSize', 16)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(dp, 'Units', 'Inches')
pos = get(dp, 'Position');
%lgd = legend;
%lgd.NumColumns = 1 ;
set(dp, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
    print(dp, 'dischargepred_actual', '-dpdf', '-r0')
    
    
Figure5=zeros(25,5);
Figure5(:,1)=occupLim;
Figure5(:,2)=dispriv_pred;
Figure5(:,3)=dispriv_med;
Figure5(:,4)=homeDischLim1(1:25);
Figure5(:,5)=homeDischLim1(26:50);

csvwrite('Figure5_' model '.csv', Figure5)    
    

Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0))+ muoccu(11:35,1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0)) + alpha * effortsnf(11:35)+muoccu(11:35,2);   

Pr_priv_extra = ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0))+muoccu(:,1);
    
Pr_med_extra=ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0)) + alpha * effortsnf(1:35)+muoccu(:,2);   

    
    
Runs=10;

elasticities=zeros(2,Runs);


    
% construct other (exogenous) beds history
run('otherbeds_history_05.m')
run('endo_occupancy_06.m')

% Simulate Length of Stay   
run('simulatelos_07.m')

% collect counterfactual predictions
LOStable=zeros(3,8);

LOStable(1,1) = mean(LOS_priv);
LOStable(2,1) = mean(LOS_med);
LOStable(3,1) = mean(occuphist((stead+1):sw));

% effort = (0.00:0.00001:0.02);
effort=(0.00:0.01:1.99);
phieffort_count = vertcat(zeros(10, 1), phiPart);

price_cf = price;
revenue_cf = revenue;

for n = 1:Runs    

% patient elasticity
priceNew(1) = price(1) * 1.01;
priceNew(2) = price(2);

snfresults = providereffort2_muoccu(alpha, beta, kappa, mc, costtau, phieffort_count, ...
    Theta, delta, muoccu, rho, psi, revenue, priceNew, utility, dischShock_cons);

effortsnf_count = effort(snfresults(:,5))';

Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        priceNew(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0))+muoccu(11:35,1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        priceNew(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0)) + alpha * effortsnf_count(11:35)+muoccu(11:35,2);   

Pr_priv_extra = ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        priceNew(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0))+muoccu(:,1);
    
Pr_med_extra=ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        priceNew(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0)) + alpha * effortsnf_count(1:35)+muoccu(:,2);  

run('endo_occupancy_06.m')
run('simulatelos_07.m')

LOStable(1,2) = mean(LOS_priv);
LOStable(2,2) = mean(LOS_med);

patient_elast=(LOStable(1,1)-LOStable(1,2))/(LOStable(1,1)/2+LOStable(1,2)/2)/0.01;


% provider elasticity
revenueNew(1) = revenue(1);
revenueNew(2) = revenue(2) * 1.01;

snfresults = providereffort2_muoccu(alpha, beta, kappa, mc, costtau, phieffort_count, ...
    Theta, delta, muoccu, rho, psi, revenueNew, price, utility, dischShock_cons);

effortsnf_count = effort(snfresults(:,5))';

Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0))+muoccu(11:35,1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0)) + alpha * effortsnf_count(11:35)+muoccu(11:35,2);   

Pr_priv_extra = ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0))+muoccu(:,1);
    
Pr_med_extra=ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa * gamma3), 0)) + alpha * effortsnf_count(1:35)+muoccu(:,2);  

run('endo_occupancy_06.m')
run('simulatelos_07.m')

LOStable(1,3)=mean(LOS_priv);
LOStable(2,3)=mean(LOS_med);

provider_elast=-(LOStable(2,1)-LOStable(2,3))/(LOStable(2,1)/2+LOStable(2,3)/2)/0.01;

elasticities(1,n)=patient_elast;
elasticities(2,n)=provider_elast;

end



csvwrite('LOStable.csv', LOStable)
csvwrite('elasticities.csv', elasticities)




