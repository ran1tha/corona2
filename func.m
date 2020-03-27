%Predictive Analysis on COVID-19 outbreak in Sri Lanka%

%%%%%%%%%Function to solve the simultaneous nonlinear ODEs%%%%%%%%%

%Author : Ranitha Mataraarachchi [ranitha@ieee.org | github.com/ran1tha]
%Date   : 25.03.2020 

%%

function y=func(time,theta,y0,xdata)

opt = odeset('NonNegative', 1:7);   %Define function outputs to be non-negative
[t,y] = ode15s(@sys,time,y0,opt,theta);
