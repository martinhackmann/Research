%% THIS PROGRAM CALCULATES AND PLOTS PREDICTED DISCHARGE RATES FOR ACTUAL AND COUNTERFACTUAL POLICIES %%

% estimated parameters  
alpha = paramsMin(1); 
beta = paramsMin(2);



kappa = paramsMin(3);
mc = paramsMin(4);

% predictions under actual policy
dispriv_pred = ones(nOccupLim,1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0));

dispriv_med = ones(nOccupLim,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf(11:35);

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
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(dp, 'Units', 'Inches')
pos = get(dp, 'Position');
set(dp, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
    print(dp, 'Figure5', '-dpdf', '-r0')

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

%%%% save point estimates for figures

Figure5=zeros(25,5);
Figure5(:,1)=occupLim;
Figure5(:,2)=dispriv_pred;
Figure5(:,3)=dispriv_med;
Figure5(:,4)=homeDischLim1(1:25);
Figure5(:,5)=homeDischLim1(26:50);

csvwrite(['Figure5_' model '.csv'], Figure5)
    
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

snfresults = providereffort2(alpha, beta, kappa, mc, costtau, phieffort_count, ...
    Theta, delta, mu, rho, psi, revenue, priceNew, utility, dischShock_cons);

effortsnf_count = effort(snfresults(:,5))';

Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        priceNew(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0))+mu(1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        priceNew(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf_count(11:35)+mu(2);   

Pr_priv_extra = ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        priceNew(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0))+mu(1);
    
Pr_med_extra=ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        priceNew(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf_count(1:35)+mu(2);  

run('endo_occupancy_06.m')
run('simulatelos_07.m')

LOStable(1,2) = mean(LOS_priv);
LOStable(2,2) = mean(LOS_med);

patient_elast=(LOStable(1,1)-LOStable(1,2))/(LOStable(1,1)/2+LOStable(1,2)/2)/0.01;


% provider elasticity
revenueNew(1) = revenue(1);
revenueNew(2) = revenue(2) * 1.01;

snfresults = providereffort2(alpha, beta, kappa, mc, costtau, phieffort_count, ...
    Theta, delta, mu, rho, psi, revenueNew, price, utility, dischShock_cons);

effortsnf_count = effort(snfresults(:,5))';

Pr_priv = ones(nOccupPart, 1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0))+mu(1);
    
Pr_med = ones(nOccupPart,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf_count(11:35)+mu(2);   

Pr_priv_extra = ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        price(1) - utility(1) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0))+mu(1);
    
Pr_med_extra=ones(nOccup,1) * beta * mean(max((beta * (kappa * ...
        price(2) - utility(2) - dischShock_cons(:,1) + dischShock_cons(:,2))) / ...
        (2 * kappa), 0)) + alpha * effortsnf_count(1:35)+mu(2);  

run('endo_occupancy_06.m')
run('simulatelos_07.m')

LOStable(1,3)=mean(LOS_priv);
LOStable(2,3)=mean(LOS_med);

provider_elast=-(LOStable(2,1)-LOStable(2,3))/(LOStable(2,1)/2+LOStable(2,3)/2)/0.01;

elasticities(1,n)=patient_elast;
elasticities(2,n)=provider_elast;

end

csvwrite(['elasticities_' model '.csv'], elasticities)


%%%% Robustness Patient Incentives (alternative price variation)

run('robustness_patientincentives.m')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COUNTERFACTUAL POLICY: COMMON PRICES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

price_cf(2) = price(1);
revenue_cf(2) = revenue(1);

Dischargehome_counter=[beta^2/kappa/costtau*mean(max(kappa*price_cf(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)), ...
    beta^2/kappa/costtau*mean(max(kappa*price_cf(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))];

snfresults = providereffort2(alpha, beta, kappa, mc, costtau, phieffort_count, ...
    Theta, delta, mu, rho, psi, revenue_cf, price_cf, utility, dischShock_cons);

effortsnf_count=effort(snfresults(:,5))';

Pr_priv=ones(nOccupPart,1)*(mu(1)+beta^2/kappa/costtau*mean(max(kappa*price_cf(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)));
Pr_med=ones(nOccupPart,1)*(mu(2)+beta^2/kappa/costtau*mean(max(kappa*price_cf(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))) ...
    +paramsMin(1)*effortsnf_count(11:35);  

Pr_priv_extra=ones(nOccup,1)*(mu(1)+beta^2/kappa/costtau*mean(max(kappa*price_cf(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)));
Pr_med_extra=ones(nOccup,1)*(mu(2)+beta^2/kappa/costtau*mean(max(kappa*price_cf(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))) ...
    +paramsMin(1)*effortsnf_count(1:35); 

dispriv_pred=ones(nOccupLim,1)*beta^2/kappa/costtau*mean(max(kappa*price_cf(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0));
dispriv_med=ones(nOccupLim,1)*beta^2/kappa/costtau*mean(max(kappa*price_cf(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0)) ...
    +paramsMin(1)*effortsnf_count(11:35);

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
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(dp, 'Units', 'Inches')
pos = get(dp, 'Position');
set(dp, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
    print(dp, 'Figure6a', '-dpdf', '-r0')
    
    
Figure6a=zeros(25,5);
Figure6a(:,1)=occupLim;
Figure6a(:,2)=dispriv_pred;
Figure6a(:,3)=dispriv_med;
Figure6a(:,4)=homeDischLim1(1:25);
Figure6a(:,5)=homeDischLim1(26:50);

csvwrite(['Figure6a_' model '.csv'], Figure6a)   
      
run('endo_occupancy_06.m')        
run('simulatelos_07.m')

LOStable(1,4) = mean(LOS_priv);
LOStable(2,4) = mean(LOS_med);
LOStable(3,4) = mean(occuphist((stead+1):sw));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COUNTERFACTUAL POLICY: 2% MEDICAID WITH UP FRONT 
%% COMPENSATION: ENDOGENOUS OCCUPANCY RATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

upFront = 0.02;

price_cf(2) = 0;
revenue_cf(2) = (1 - upFront) * revenue(2);

LOStable(1,6)=LOStable(1,1);
LOStable(2,6)=LOStable(2,1);

diff = 2;
tol = 0.01;

Thetaendo = Theta;

while diff > tol
  
    comp=LOStable(2,1)*(upFront*revenue(2));

    snfresults_upfront = providereffort2_comp01(alpha, beta, kappa, mc, costtau, phieffort_count, ...
        Thetaendo, delta, mu, rho, psi, revenue_cf, price_cf, utility, dischShock_cons, comp);
    
    effortsnf_count=effort(snfresults_upfront(:,5))';

    Pr_priv=ones(nOccupPart,1)*(mu(1)+beta^2/kappa/costtau*mean(max(kappa*price_cf(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)));
    Pr_med=ones(nOccupPart,1)*(mu(2)+beta^2/kappa/costtau*mean(max(kappa*price_cf(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))) ...
        +paramsMin(1)*effortsnf_count(11:35);  

    Pr_priv_extra=ones(nOccup,1)*(mu(1)+beta^2/kappa/costtau*mean(max(kappa*price_cf(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)));
    Pr_med_extra=ones(nOccup,1)*(mu(2)+beta^2/kappa/costtau*mean(max(kappa*price_cf(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))) ...
        +paramsMin(1)*effortsnf_count(1:35);  

    run('endo_occupancy_06.m')
    run('simulatelos_endo_08.m')

    diff=abs(mean(LOS_med)-LOStable(2,6));

    LOStable(1,6)=mean(LOS_priv);
    LOStable(2,6)=mean(LOS_med);

    diff;
    mean(LOS_med);

    Thetaendo=occup_endo;

end

run('endo_occupancy_06.m')

LOStable(3,6)=mean(occuphist((stead+1):sw));

dispriv_pred=ones(nOccupLim,1)*beta^2/kappa/costtau*mean(max(kappa*price_cf(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0));
dispriv_med=ones(nOccupLim,1)*beta^2/kappa/costtau*mean(max(kappa*price_cf(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0)) ...
    +paramsMin(1)*effortsnf_count(11:35);

plot(occupLim, dispriv_pred, 'LineStyle', '--', 'Color', 'black', 'LineWidth', 3)
hold on;
plot(occupLim, dispriv_med, 'LineStyle', '-', 'Color', 'blue', 'LineWidth', 2)
scatter(occupLim, homeDischLim1(1:25),'Marker','o','MarkerEdgeColor','black','MarkerFaceColor','black')
scatter(occupLim, homeDischLim1(26:50),'Marker','d','MarkerEdgeColor','blue','MarkerFaceColor','blue')
ylim(ylimits)
hold off;
xlabel('occupancy rate', 'FontSize', 16)
ylabel('discharge rate', 'FontSize', 16)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(dp, 'Units', 'Inches')
pos = get(dp, 'Position');
set(dp, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
    print(dp, 'Figure6c', '-dpdf', '-r0')

    
Figure6c=zeros(25,5);
Figure6c(:,1)=occupLim;
Figure6c(:,2)=dispriv_pred;
Figure6c(:,3)=dispriv_med;
Figure6c(:,4)=homeDischLim1(1:25);
Figure6c(:,5)=homeDischLim1(26:50);

csvwrite(['Figure6c_' model '.csv'], Figure6c)      
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COUNTERFACTUAL POLICY: 10% MEDICAID WITH UP FRONT 
%% COMPENSATION: ENDOGENOUS OCCUPANCY RATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

upFront = 0.1;

price_cf(2) = 0;
revenue_cf(2) = (1 - upFront) * revenue(2);

LOStable(1,7)=LOStable(1,1);
LOStable(2,7)=LOStable(2,1);

diff = 2;
tol = 0.01;

Thetaendo = Theta;

while diff > tol
  
    comp=LOStable(2,1)*(upFront*revenue(2));

    snfresults_upfront = providereffort2_comp01(alpha, beta, kappa, mc, costtau, phieffort_count, ...
        Thetaendo, delta, mu, rho, psi, revenue_cf, price_cf, utility, dischShock_cons, comp);
    
    effortsnf_count=effort(snfresults_upfront(:,5))';

    Pr_priv=ones(nOccupPart,1)*(mu(1)+beta^2/kappa/costtau*mean(max(kappa*price_cf(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)));
    Pr_med=ones(nOccupPart,1)*(mu(2)+beta^2/kappa/costtau*mean(max(kappa*price_cf(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))) ...
        +paramsMin(1)*effortsnf_count(11:35);  

    Pr_priv_extra=ones(nOccup,1)*(mu(1)+beta^2/kappa/costtau*mean(max(kappa*price_cf(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)));
    Pr_med_extra=ones(nOccup,1)*(mu(2)+beta^2/kappa/costtau*mean(max(kappa*price_cf(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))) ...
        +paramsMin(1)*effortsnf_count(1:35);  

    run('endo_occupancy_06.m')
    run('simulatelos_endo_08.m')

    diff=abs(mean(LOS_med)-LOStable(2,7));

    LOStable(1,7)=mean(LOS_priv);
    LOStable(2,7)=mean(LOS_med);

    diff;
    mean(LOS_med);

    Thetaendo=occup_endo;

end

run('endo_occupancy_06.m')

LOStable(3,7)=mean(occuphist((stead+1):sw));

dispriv_pred=ones(nOccupLim,1)*beta^2/kappa/costtau*mean(max(kappa*price_cf(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0));
dispriv_med=ones(nOccupLim,1)*beta^2/kappa/costtau*mean(max(kappa*price_cf(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0)) ...
    +paramsMin(1)*effortsnf_count(11:35);

plot(occupLim, dispriv_pred, 'LineStyle', '--', 'Color', 'black', 'LineWidth', 3)
hold on;
plot(occupLim, dispriv_med, 'LineStyle', '-', 'Color', 'blue', 'LineWidth', 2)
scatter(occupLim, homeDischLim1(1:25),'Marker','o','MarkerEdgeColor','black','MarkerFaceColor','black')
scatter(occupLim, homeDischLim1(26:50),'Marker','d','MarkerEdgeColor','blue','MarkerFaceColor','blue')
ylim(ylimits)
hold off;
xlabel('occupancy rate', 'FontSize', 16)
ylabel('discharge rate', 'FontSize', 16)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(dp, 'Units', 'Inches')
pos = get(dp, 'Position');
set(dp, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
    print(dp, 'Figure6c10percent', '-dpdf', '-r0')

    
Figure6c10percent=zeros(25,5);
Figure6c10percent(:,1)=occupLim;
Figure6c10percent(:,2)=dispriv_pred;
Figure6c10percent(:,3)=dispriv_med;
Figure6c10percent(:,4)=homeDischLim1(1:25);
Figure6c10percent(:,5)=homeDischLim1(26:50);

csvwrite('Figure6c10percent.csv', Figure6c10percent)      
    
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COUNTERFACTUAL POLICY: DISCHARGE BONUS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LOStable(1,8)=mean(LOS_priv);
LOStable(2,8)=mean(LOS_med);

effort=(0.00:0.01:1.99);
phieffort_count = vertcat(zeros(10, 1), phiPart);

% Discharge incentive  (translate to $732 in 2005 dollars)
dinc3=165.83/36*214/100;

diff = 2;
tol = 0.01;


Thetaendo = Theta;

while diff > tol
  
snfresults = providereffortexperiment(alpha, beta, kappa, mc, costtau, phieffort_count, ...
    Theta, delta, mu, rho, psi, revenue, price, utility, dischShock_cons, dinc3);

    effortsnf_count=effort(snfresults(:,5))';

    Pr_priv=ones(nOccupPart,1)*(mu(1)+beta^2/kappa/costtau*mean(max(kappa*price(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)));
    Pr_med=ones(nOccupPart,1)*(mu(2)+beta^2/kappa/costtau*mean(max(kappa*price(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))) ...
        +paramsMin(1)*effortsnf_count(11:35);  

    Pr_priv_extra=ones(nOccup,1)*(mu(1)+beta^2/kappa/costtau*mean(max(kappa*price(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)));
    Pr_med_extra=ones(nOccup,1)*(mu(2)+beta^2/kappa/costtau*mean(max(kappa*price(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))) ...
        +paramsMin(1)*effortsnf_count(1:35);  

    %%% generate occupancy matrix

    run('endo_occupancy_06.m')
    run('simulatelos_endo_08.m')

    diff=abs(mean(LOS_med)-LOStable(2,8));

    LOStable(1,8)=mean(LOS_priv);
    LOStable(2,8)=mean(LOS_med);

    diff;
    mean(LOS_med);

    Thetaendo=occup_endo;

end

Pr_priv=ones(nOccupPart,1)*(mu(1)+beta^2/kappa/costtau*mean(max(kappa*price(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)));
Pr_med=ones(nOccupPart,1)*(mu(2)+beta^2/kappa/costtau*mean(max(kappa*price(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))) ...
    +paramsMin(1)*effortsnf_count(11:35);  

Pr_priv_extra=ones(nOccup,1)*(mu(1)+beta^2/kappa/costtau*mean(max(kappa*price(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0)));
Pr_med_extra=ones(nOccup,1)*(mu(2)+beta^2/kappa/costtau*mean(max(kappa*price(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0))) ...
    +paramsMin(1)*effortsnf_count(1:35); 

dispriv_pred=ones(nOccupLim,1)*beta^2/kappa/costtau*mean(max(kappa*price(1)-utility(1)-dischShock_cons(:,1)+dischShock_cons(:,2),0));
dispriv_med=ones(nOccupLim,1)*beta^2/kappa/costtau*mean(max(kappa*price(2)-utility(2)-dischShock_cons(:,3)+dischShock_cons(:,4),0)) ...
    +paramsMin(1)*effortsnf_count(11:35);

avg_med=(dispriv_med'*occupSteadyPdf(12:36))/sum(occupSteadyPdf(12:36));  

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
legend({'pred., private', 'pred., Medicaid', 'obs., private', ...
    'obs., Medicaid'}, 'location', 'southeast', 'FontSize', 16)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(dp, 'Units', 'Inches')
pos = get(dp, 'Position');
lgd = legend;
set(dp, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
    print(dp, 'Figure6b', '-dpdf', '-r0')
    
    
Figure6b=zeros(25,5);
Figure6b(:,1)=occupLim;
Figure6b(:,2)=dispriv_pred;
Figure6b(:,3)=dispriv_med;
Figure6b(:,4)=homeDischLim1(1:25);
Figure6b(:,5)=homeDischLim1(26:50);

csvwrite(['Figure6b_' model '.csv'], Figure6b)     
        
run('endo_occupancy_06.m')        
run('simulatelos_endo_08.m')

LOStable(1,8) = mean(LOS_priv);
LOStable(2,8) = mean(LOS_med);
LOStable(3,8) = mean(occuphist((stead+1):sw));

BigT=table(LOStable(2:3,1),LOStable(2:3,4),LOStable(2:3,8),LOStable(2:3,6),LOStable(2:3,7),'VariableNames',{'Baseline','Voucher','Bonus','Front2perc','Front10perc'},'RowNames',{'MedicaidLOS' 'AverageOccupancy'})

writetable(BigT,['LOStable' model '.xlsx'],'Sheet',1);



