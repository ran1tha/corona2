%Predictive Analysis on COVID-19 outbreak in Sri Lanka%

%%%%%%%%%System of Non-Linear ODEs%%%%%%%%%

%Author : Ranitha Mataraarachchi [ranitha@ieee.org | github.com/ran1tha]
%Date   : 25.03.2020 

%%

clear model data params options
close all
clc

%Enter the Known Data starting from 15th March 2020
data.ydata = [
%  Time (days)    [H]   [B]     [R]     [Sq]
            1     10    133     1       122
            2     18    212     1       123
            3     28    204     1       562
            4     41    212     1       833
            5     52    243     1       1072
            6     65    218     1       1421
            7     71    245     1       1482
            8     77    222     1       1694
            9     86    227     1       1906
            10    95    229     2       2500
            11    99    255     3       3080
            12    99    237     3       3250 
            13    99    238     7       3549
 ];

%%
% Set the model sum of squares function
model.ssfun = @ss;

%%
% All parameters are constrained to be positive. The initial
% S0,E0,I0 are also unknown and are treated as extra parameters.

k0 = [11.390,0.1911,0.49005,0.00000010002,0.07,0.5,1.3163,0.15,0.008,122,89]';


%Initialize the Parameters

    %Name       %Initial Guess       %min      %max
params = {
    {'c',       11.390,              0}
    {'beta',    0.1911 ,             0}
    {'q',       0.49005,             0}
    {'m',       0.00000010002,       0}
    {'b',       0.07,                0}
    {'f',       0.5,                 0,         1}
    {'delta',   1.3163,              0}
    {'gamma',  0.15,                0}
    {'alpha',   0.008,               0}
    {'E0',      255,                 255}
    {'I0',      89,                  89}
    };



%%
% First generate an initial chain.
options.nsimu = 100000;
[results, chain, s2chain]= mcmcrun(model,data,params,options);
%%
% Then re-run starting from the results of the previous run,
% this will take couple of minutes.
options.nsimu = 500000;
[results, chain, s2chain] = mcmcrun(model,data,params,options, results);

%%
%Analyse data Using Modelled Parameters and Initial Conditions

%Initial Conditions
H0 = data.ydata(1,2); 
B0 = data.ydata(1,3); 
R0 = data.ydata(1,4); 
Sq0 = data.ydata(1,5); 
S0 = 21413249; 
E0 = results.theta(10); 
I0= results.theta(11);
y0 = [H0;B0;R0;Sq0;S0;E0;I0];

%Plot Curves of H,I,R for 50 days
Fig1 = figure('Position', get(0, 'Screensize'));

%timespan of 50 days
t = linspace(0,50);
y = func(t,mean(chain),y0);
hold on
grid on
plot(t,y(:,1),'-','LineWidth',2)
plot(t,y(:,7),'-','LineWidth',2)
plot(t,y(:,3),'-','LineWidth',2)
legend({'Prediction for The Number of Confirmed Active Cases',
    'Prediction for The Number of Unidentified Active Infectives',
    'Prediction for The Number of Recovered Patients'},'Location','best')
title('Predictions upto 20 days starting from 15/03/2020')
ylabel('Number of People'); xlabel('Days');
hold off

F    = getframe(Fig1);
imwrite(F.cdata, 'HIRplot.png', 'png')


%%
% Chain plots should reveal that the chain has converged and we can
% use the results for estimation and predictive inference.

%This plot displays the Probability distributions of MCMC estimated params
Fig2 = figure('Position', get(0, 'Screensize'));
mcmcplot(chain,[],results,'denspanel',2);
F    = getframe(Fig2);
imwrite(F.cdata, 'params.png', 'png')

%%
% Function |chainstats| calculates mean ans std from the chain and
% estimates the Monte Carlo error of the estimates. Number |tau| is
% the integrated autocorrelation time and |geweke| is a simple test
% for a null hypothesis that the chain has converged.
chainstats(chain,results)



%%
% In order to use the |mcmcpred| function we need
% function |modelfun| with input arguments given as
% |modelfun(xdata,theta)|. We construct this as an anonymous function.

%Initial conditions cannot be passed to the function via variables
%therefore they need to be hard-coded
modelfun = @(d,th) func(d(:,1),th,[10;133;1;122;21413249;th(10);th(11)],d);

%%
% We sample 500 parameter realizations from |chain| and |s2chain|
% and calculate the predictive plots.
nsample = 500;

%Create a vector of increasing numbers from 1 to 50
input = zeros(50,1);
for count = 1:length(input)
    input(count) = count;
end

%Predict the model for 50 days
out = mcmcpred(results,chain,s2chain,input,modelfun,nsample);

figure(3); clf
mcmcpredplot(out);

%Titles of plots for later use
data.ylabels = {'Active Confirmed Cases',
                'Suspected Cases',
                'Recovered Patients',
                'People in Quarantine centers',
                'Susceptible Population',
                'Exposed Population',
                'Unidentified Active Infectives'
                 };


% add the actual observations to the plot and label the plots
hold on
for i=1:7
 subplot(7,1,i)
 hold on
 
 if i < 5
 plot(data.ydata(:,1),data.ydata(:,i+1),'o','MarkerSize',5);
 end
 
 ylabel(''); title(data.ylabels(i)); xlabel('days');
 hold off
end

%%
%Plotting comparisons for various parameter changes

%%
%Changing the contact rate
%Twice the Contact rate
TCchain = mean(chain);
TCchain(1) = 2*TCchain(1);

%Half the Contact rate
HCchain = mean(chain);
HCchain(1) = 0.5*HCchain(1);

Fig4 = figure('Position', get(0, 'Screensize'));
t = linspace(0,50);

%Plotting H
subplot(1,2,1)
hold on

ych1 = func(t,mean(chain),y0);
plot(t,ych1(:,1),'-','LineWidth',2)

ych2 = func(t,TCchain,y0);
plot(t,ych2(:,1),'-','LineWidth',2)

ych3 = func(t,HCchain,y0);
plot(t,ych3(:,1),'-','LineWidth',2)

legend({'Present curve',
    'Twice the contact rate',
    'Half the contact rate'},'Location','best')
title('Confirmed Active Cases');

%Plotting I
subplot(1,2,2)
hold on

yci1 = func(t,mean(chain),y0);
plot(t,yci1(:,7),'-','LineWidth',2)

yci2 = func(t,TCchain,y0);
plot(t,yci2(:,7),'-','LineWidth',2)

yci3 = func(t,HCchain,y0);
plot(t,yci3(:,7),'-','LineWidth',2)

legend({'Present curve',
    'Twice the contact rate',
    'Half the contact rate'},'Location','best')
title('Unidentified Active Cases');

hold off
F    = getframe(Fig4);
imwrite(F.cdata, 'c.png', 'png')





%%
%Changing the quarantine rate
%Twice the Quarantine rate
TQchain = mean(chain);
TQchain(3) = 2*TQchain(3);

%Half the Quarantine rate
HQchain = mean(chain);
HQchain(3) = 0.5*HQchain(3);

Fig5 = figure('Position', get(0, 'Screensize'));
t = linspace(0,50);

%Plotting H
subplot(1,2,1)
hold on

yqh1 = func(t,mean(chain),y0);
plot(t,yqh1(:,1),'-','LineWidth',2)

yqh2 = func(t,TQchain,y0);
plot(t,yqh2(:,1),'-','LineWidth',2)

yqh3 = func(t,HQchain,y0);
plot(t,yqh3(:,1),'-','LineWidth',2)

legend({'Present curve',
    'Twice the Quarantine rate',
    'Half the Quarantine rate'},'Location','best')
title('Confirmed Active Cases');

%Plotting I
subplot(1,2,2)
hold on

yqi1 = func(t,mean(chain),y0);
plot(t,yqi1(:,7),'-','LineWidth',2)

yqi2 = func(t,TQchain,y0);
plot(t,yqi2(:,7),'-','LineWidth',2)

yqi3 = func(t,HQchain,y0);
plot(t,yqi3(:,7),'-','LineWidth',2)

legend({'Present curve',
    'Twice the Quarantine rate',
    'Half the Quarantine rate'},'Location','best')
title('Unidentified Active Cases');

hold off
F    = getframe(Fig5);
imwrite(F.cdata, 'q.png', 'png')

%%
%Changing the Detection rate of the suspected class and Recovery rate of
%quarantined infected individuals

%Twice the Detection rate
bchain = mean(chain);
bchain(5) = 2*bchain(5);

%Twice the Recovery rate
rchain = mean(chain);
rchain(8) = 2*rchain(8);

Fig6 = figure('Position', get(0, 'Screensize'));
t = linspace(0,50);
hold on
%Plotting R

yrr1 = func(t,mean(chain),y0);
plot(t,yrr1(:,3),'-','LineWidth',2)

yrr2 = func(t,bchain,y0);
plot(t,yrr2(:,3),'-','LineWidth',2)

yrr3 = func(t,rchain,y0);
plot(t,yrr3(:,3),'-','LineWidth',2)

legend({'Present curve',
    'Twice the Detection rate',
    'Twice the Recovery rate'},'Location','best')
title('Recovered Patients');

hold off

F    = getframe(Fig6);
imwrite(F.cdata, 'bgamma.png', 'png')

%%
%Best Parameter Predictions


Fig7 = figure('Position', get(0, 'Screensize'));
t = linspace(0,50);

%Plotting H
subplot(1,2,1)
hold on

y11 = func(t,mean(chain),y0);
plot(t,y11(:,1),'-','LineWidth',2)

y12 = func(t,HCchain,y0);
plot(t,y12(:,1),'-','LineWidth',2)

y13 = func(t,TQchain,y0);
plot(t,y13(:,1),'-','LineWidth',2)

legend({'Present curve',
    'Half the Contact rate',
    'Twice the Quarantine rate'},'Location','best')
title('Confirmed Active Cases');

%Plotting I
subplot(1,2,2)
hold on

y21 = func(t,mean(chain),y0);
plot(t,y21(:,7),'-','LineWidth',2)

y22 = func(t,HCchain,y0);
plot(t,y22(:,7),'-','LineWidth',2)

y23 = func(t,TQchain,y0);
plot(t,y23(:,7),'-','LineWidth',2)

legend({'Present curve',
    'Half the Contact rate',
    'Twice the Quarantine rate'},'Location','best')
title('Unidentified Active Cases');

hold off
F    = getframe(Fig7);
imwrite(F.cdata, 'best.png', 'png')
