occupgraph = (0.64:0.01:0.99)';      % occupancy rates
nOccupgraph  = size(occupgraph, 1); 

% total number of observations for each of current occupancy rates
occupNextTotal = zeros(nOccupgraph, 1);
for j = 1:size(occupTrans, 1)
   for o = 1:nOccupgraph
        if occupTrans(j, 1) == 100 * occupgraph(o) && occupTrans(j, 2) ~= 0
            occupNextTotal(o) = occupNextTotal(o) + occupTrans(j, 3);
        end
    end
end

% for each of current occupancy rates, what fraction does each of next
% period's occupancy rates have?
for j = 1:size(occupTrans, 1)
    for o = 1:nOccupgraph
        if occupTrans(j, 1) == 100 * occupgraph(o)
            occupTrans(j, 3) = occupTrans(j, 3) / occupNextTotal(o);
        end
    end
end

% put transition probabilities in square matrix
Thetagraph = zeros(nOccupgraph);
for j = 1:size(occupTrans, 1)
    for o1 = 1:nOccupgraph
        for o2 = 1:nOccupgraph
            if 100 * occupgraph(o1) == occupTrans(j, 1) && 100 * occupgraph(o2) == ...
                occupTrans(j, 2)
                Thetagraph(o1, o2) = occupTrans(j, 3);
            end
        end
    end
end


mc = dtmc(Thetagraph);

T1 = 1000;
B = 10000;
    
occupSimulSteady = zeros(T1+1, B);    
    
parfor b = 1:B
    occupSimulSteady(:, b) = simulate(mc, T1);
end  
  
pdfSteady = zeros(size(Thetagraph, 1), 1);
for i = 1:size(Thetagraph, 1)
    pdfSteady(i, 1) = sum(occupSimulSteady(T1+1, :) == i) / B;
end

%steadyStateMean = mean(occupSimulSteady(T1+1, :), 2);

x01 = zeros(1,mc.NumStates);
x01(1, 25) = 1;

x02 = zeros(1,mc.NumStates);
x02(1, 31) = 1;

T = 200;
B = 10000;

occupSimul1 = zeros(T+1,B);
occupSimul2 = zeros(T+1,B);

parfor b = 1:B
    occupSimul1(:,b) = simulate(mc, T, 'X0', x01);
    occupSimul2(:,b) = simulate(mc, T, 'X0', x02);
end

occupSimulMean1 = mean(occupSimul1, 2);
occupSimulMean2 = mean(occupSimul2, 2);

occupSimulMeanMonth1 = zeros(1, T-2);
occupSimulMeanMonth2 = zeros(1, T-2);

for t = 2:T-1
    occupSimulMeanMonth1(t-1) = (occupSimulMean1(t-1) + occupSimulMean1(t) + ...
        occupSimulMean1(t+1) + occupSimulMean1(t+2)) / 4;
    occupSimulMeanMonth2(t-1) = (occupSimulMean2(t-1) + occupSimulMean2(t) + ...
        occupSimulMean2(t+1) + occupSimulMean2(t+2)) / 4;
end


steadyStateMean=(mean(occupSimulMean1(151:T-2))+mean(occupSimulMean2(151:T-2)))/2;
occupSteadyState = steadyStateMean * ones(T-2, 1);

weeks = (1:T-2)';

plot(weeks, occupSimulMeanMonth1, weeks, occupSimulMeanMonth2, weeks, occupSteadyState)

%%% steady state


cd baseline

ir = figure;
plot(occupSimulMean1(1:150), 'LineStyle', '-', 'Color', 'blue', 'LineWidth', 2)
hold on;
plot(occupSimulMean2(1:150), 'LineStyle', '-.', 'Color', 'blue', 'LineWidth', 2)
plot(occupSteadyState(1:150), 'LineStyle', '--', 'Color', 'black', 'LineWidth', 2) 
plot([25.7 25.7], [25 31], 'LineStyle', ':', 'Color', 'black', 'LineWidth', 2) 
hold off;
legend({'-3 points occupancy shock', '+3 points occupancy shock', 'mean steady state occupancy'}, 'Location', 'southeast', 'FontSize', 16)
xlabel('weeks', 'FontSize', 16)
ylabel('occupancy rate', 'FontSize', 16)
yticklabels({'87', '88', '89', '90', '91', '92', '93'});
set(gca,'XTick',0:25:150);
xt = get(gca, 'XTick');
set(gca, 'FontSize', 16)
set(ir, 'Units', 'Inches')
pos = get(ir, 'Position');
set(ir, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
    [pos(3), pos(4)])
print(ir, 'Figure2d', '-dpdf', '-r0')


%T2 = 50;
%B2 = 12;
%B3 = 12;

%occupSimul1 = zeros(T2+2, sum(B2*round(B2*pdfSteady)));
%occupSimul2 = zeros(T2+2, sum(B3*round(B3*pdfSteady)));
%x02 = B2*round(B2*pdfSteady)'.*ones(1,mc.NumStates);
%x03 = B3*round(B3*pdfSteady)'.*ones(1,mc.NumStates);


%occupSimul1(2:T2+2,:) = simulate(mc, T2, 'X0', x02);
%occupSimul2(2:T2+2,:) = simulate(mc, T2, 'X0', x03);
%occupSimul1(2:T2+2,:) = occupSimul1(2:T2+2, :) - (occupSimul1(2, :) - 1); 
%occupSimul2(2:T2+2,:) = occupSimul2(2:T2+2, :) - (occupSimul2(2, :)); 
%occupSimulMean1 = mean(occupSimul1, 2);
%occupSimulMean2 = mean(occupSimul2, 2);


%ir = figure;
%plot(occupSimulMean1(1:40), 'LineStyle', '-', 'Color', 'blue', 'LineWidth', 2)
%hold on;
%plot(occupSimulMean2(1:40), 'LineStyle', '--', 'Color', 'black', 'LineWidth', 2)
%hold off;
%legend({'with occupancy shock', 'without occupancy shock'}, 'Location', 'northeast', 'FontSize', 16)
%xlabel('weeks', 'FontSize', 16)
%ylabel('occupancy rate deviation', 'FontSize', 16)
%xt = get(gca, 'XTick');
%set(gca, 'FontSize', 16)
%set(ir, 'Units', 'Inches')
%pos = get(ir, 'Position');
%set(ir, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', ...
%    [pos(3), pos(4)])
%print(ir, 'Figure2dv2', '-dpdf', '-r0')
    