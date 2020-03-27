%Predictive Analysis on COVID-19 outbreak in Sri Lanka%

%%%%%%%%%System of Non-Linear ODEs%%%%%%%%%

%Author : Ranitha Mataraarachchi [ranitha@ieee.org | github.com/ran1tha]
%Date   : 25.03.2020 

%%


function ydot = sys(t,y,theta)

%Parameters
c = theta(1);
beta = theta(2);
q = theta(3);
m = theta(4);
b = theta(5);
f = theta(6);
delta = theta(7);
gamma = theta(8);
alpha = theta(9);
N = 21413249;
lambda = 1/14;
sigma = 1/7;

%Function Values
H=y(1); B=y(2); S=y(5); E=y(6); Sq=y(4); I = y(7);


%Simultaneous ODEs
dotH =  delta*I + b*f*B - (alpha+gamma)*H;
dotB =  (beta*c*q*S*I)/N + m*S -b*B;
dotR =   gamma*H;
dotSq =   (((1-beta)*c*q)*(S*I))/N - lambda*Sq;
dotS =  -((beta*c+c*q*(1-beta))*(S*I))/N - m*S +lambda*Sq +b*(1-f)*B;
dotE =   (beta*c*(1-q)*S*I)/N - sigma*E;
dotI =    sigma*E - (delta)*I;

ydot=[dotH;dotB;dotR;dotSq;dotS;dotE;dotI];
