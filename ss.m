%Predictive Analysis on COVID-19 outbreak in Sri Lanka%

%%%%%%%%%Sum-of-Squares Function%%%%%%%%%

%Author : Ranitha Mataraarachchi [ranitha@ieee.org | github.com/ran1tha]
%Date   : 25.03.2020 

%%


function ss = ss(theta,data)
%sum-of-squares function

time   = data.ydata(:,1);

Hobs = data.ydata(:,2); %Actual Values
Bobs = data.ydata(:,3);
Robs = data.ydata(:,4);
Sqobs = data.ydata(:,5);

H0 = data.ydata(1,2); %Initial Conditions
B0 = data.ydata(1,3); 
R0 = data.ydata(1,4); 
Sq0 = data.ydata(1,5); 
S0 = 21413249; 
E0 = theta(10); 
I0= theta(11);

y0 = [H0;B0;R0;Sq0;S0;E0;I0];

%Solve the euqation with given params and init conditions
y = func(time,theta,y0);

%Outputs from the model
Hmodel = y(:,1);
Bmodel = y(:,2);
Rmodel = y(:,3);
Sqmodel = y(:,4);

%Obtain the sum-of-squares difference between outputs from the model
%and actual data. Bias this error to stress on reliable data (H,R)
ss = 100*sum((Hobs-Hmodel).^2)+10*sum((Bobs-Bmodel).^2)+100*sum((Robs-Rmodel).^2)+sum((Sqobs-Sqmodel).^2);

