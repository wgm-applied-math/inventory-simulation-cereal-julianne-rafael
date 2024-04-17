%% Run samples of the Inventory simulation
%
% Collect statistics and plot histograms along the way.

%% Set up

% Set-up and administrative cost for each batch requested.
K = 25.00;

% Per-unit production cost.
c = 3.00;

% Lead time for production requests.
L = 2;

% Holding cost per unit per day.
h = 0.05/7;

% Reorder point.
ROP = 50;

% Batch size.
Q = 200;

% How many samples of the simulation to run.
NumSamples = 50;

% Run each sample for this many days.
MaxTime = 100;

%% Run simulation samples

% Make this reproducible
rng("default");

% Samples are stored in this cell array of Inventory objects
InventorySamples = cell([NumSamples, 1]);

% Run samples of the simulation.
% Log entries are recorded at the end of every day
for SampleNum = 1:NumSamples
    fprintf("Working on %d\n", SampleNum);
    inventory = Inventory( ...
        RequestCostPerBatch=K, ...
        RequestCostPerUnit=c, ...
        RequestLeadTime=L, ...
        HoldingCostPerUnitPerDay=h, ...
        ReorderPoint=ROP, ...
        OnHand=Q, ...
        RequestBatchSize=Q);
    run_until(inventory, MaxTime);
    InventorySamples{SampleNum} = inventory;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Collect statistics1
% Pull the RunningCost from each complete sample.
TotalCosts = cellfun(@(i) i.RunningCost, InventorySamples);

% Express it as cost per day and compute the mean, so that we get a number
% that doesn't depend directly on how many time steps the samples run for.
meanDailyCost = mean(TotalCosts/MaxTime);
fprintf("Mean daily cost: %f\n", meanDailyCost);

%% Make pictures

% Make a figure with one set of axes.
fig = figure();
t = tiledlayout(fig,1,1);
ax = nexttile(t);

% Histogram of the cost per day.
h = histogram(ax, TotalCosts/MaxTime, Normalization="probability", ...
    BinWidth=5);

% Add title and axis labels
title(ax, "Daily total cost");
xlabel(ax, "Dollars");
ylabel(ax, "Probability");

% Fix the axis ranges
ylim(ax, [0, 0.5]);
xlim(ax, [240, 290]);

% Wait for MATLAB to catch up.
pause(2);

% Save figure as a PDF file
exportgraphics(fig, "Daily cost histogram.pdf");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Collect statistics2
FractionBacklogged = zeros(NumSamples, 1);
for SampleNum = 1:NumSamples
    FractionBacklogged(SampleNum) = InventorySamples{SampleNum}.fraction_orders_backlogged();
end
meanFractionBacklogged = mean(FractionBacklogged);
fprintf("Mean Fraction of Orders Backlogged: %f\n", meanFractionBacklogged);


% Plot a histogram of the fractions of orders backlogged
figure;
histogram(FractionBacklogged, 'Normalization', 'probability');
title('Fraction of Orders Backlogged');
xlabel('Fraction');
ylabel('Probability');


pause(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Collect statistics3
MeanFractionDaysWithBacklog = zeros(NumSamples, 1);
for SampleNum = 1:NumSamples
    MeanFractionDaysWithBacklog(SampleNum) = InventorySamples{SampleNum}.fraction_days_with_backlog();
end
meanFractionDaysWithBacklog = mean(MeanFractionDaysWithBacklog);
fprintf("Mean Fraction of Days With Non-Zero Backlog: %f\n", meanFractionDaysWithBacklog);

% Plot histogram for the fraction of days with a non-zero backlog
figure;
histogram(MeanFractionDaysWithBacklog, 'Normalization', 'probability');
title('Fraction of Days With Non-Zero Backlogs');
xlabel('Fraction');
ylabel('Probability');
pause(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Collect statistics4
DelayTimes = zeros(1, 0); % Preallocate an empty array

for SampleNum = 1:NumSamples
    inventory = InventorySamples{SampleNum};
    DelayTimes = [DelayTimes, inventory.BackloggedOrderDelayTimes];
end

mean_delay_time_backlogged = mean(DelayTimes); % Compute mean of delay times
fprintf("Mean Delay Time of Backlogged Orders: %f\n", mean_delay_time_backlogged);

% Plot histogram of delay times
figure();
histogram(DelayTimes, 'Normalization', 'probability');
title('Delay Times of Backlogged Orders');
xlabel('Delay Time');
ylabel('Probability');
pause(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Collect statistics5
TotalBacklogPerDay = zeros(NumSamples, 1);
for SampleNum = 1:NumSamples
    inventory = InventorySamples{SampleNum};
    TotalBacklogPerDay(SampleNum) = sum(cellfun(@(x) x.Amount, inventory.Backlog));
end
DaysWithBacklog = TotalBacklogPerDay > 0;
MeanTotalBacklog = mean(TotalBacklogPerDay(DaysWithBacklog));
fprintf("Mean Total Backlog Amount on Days with Backlog: %f\n", MeanTotalBacklog);


% Plot histogram for total backlog amount on days with backlog
figure();
histogram(TotalBacklogPerDay(DaysWithBacklog), 'Normalization', 'probability');
title('Total Backlog Amount on Days with Backlog');
xlabel('Total Backlog Amount');
ylabel('Probability');

pause(2)




