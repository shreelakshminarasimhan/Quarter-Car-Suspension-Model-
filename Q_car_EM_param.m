%Quarter car parameters
clear all
run road_inputs.m 

Mb = 300;   %Body mass [kg]
Mw = 30;    %Wheel mass [kg]
Ks = 15000; %Spring stiffness [N/m]
Kt = 200000;%Tyre stiffness[N/m]
Cs = 1000;  %Damper coefficient[Ns/m]

% Initial values (need zero for control/linearisation)
zb0 = 0.65; %initial body displacement 
zw0 = 0.25; %initial wheel displacement


% Actuator Parameters:
R_a = 0.1;
L_a = 250*10^-6;
K_ta = 0.08;
Sl_a = 0.01;
r_gear = 5;

% Inputs for feedback system
C_sh = -2750;
tau = 0.01;

% ISO2631 (Wk) Filter Parameters
f1 = 0.4;
f2 = 100;
f3 = 12.5;
f4 = 12.5;
Q4 = 0.63;
f5 = 2.37;
Q5 = 0.91;
f6 = 3.35;
Q6 = 0.91;
w1 = 2*pi*f1; w2 = 2*pi*f2; w3 = 2*pi*f3; w4 = 2*pi*f4; w5 = 2*pi*f5; w6 = 2*pi*f6;

sim('Qcar_basic.slx')
sim('Qcar_2Loop_Frictionless.slx')
sim('Qcar_2Loop_Friction.slx')
sim('Qcar_3Loop_Friction.slx')


