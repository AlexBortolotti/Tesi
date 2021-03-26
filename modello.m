function [tspanned,result,tspan,refin] = modello(simulength, susc, cont_mat, tau, delta_E, prob_symp, gammaI, gammaA, initS, initE, initI, initA, initR, firstDay)
%Function that handles the model


%Initial conditions vector
y0 = [initS, initE, initI, initA, initR]';

%Timespan of the dynamics
tspan = firstDay:firstDay+simulength;
%Refining mesh adding refin points every two tspan points
refin = 3;
tspanned = refin_tspan(tspan, refin);

[tspanned,result] = ode45(@(t,y)odefun(t,y), tspanned, y0);


function dydt = odefun(t,y)
    dim = length(y);
    dydt=zeros(dim,1);
    %Susceptible dynamics
    dydt(1:6) = -susc.*(cont_mat.*y(1:6)*(0.*y(2*6 + (1:6))+tau.*y(3*6 + (1:6))));
    %Latent dynamics
    dydt(6 + (1:6)) = susc.*(cont_mat.*y(1:6)*(0.*y(2*6 + (1:6))+tau.*y(3*6 + (1:6)))) - delta_E*y(1*6+(1:6));
    %Infecteds dynamics
    dydt(2*6 + (1:6)) = delta_E*prob_symp.*y(1*6 + (1:6)) - gammaI*y(2*6 + (1:6));
    %Asymptomatic dynamics
    dydt(3*6 + (1:6)) = delta_E*(1 - prob_symp).*y(1*6 + (1:6)) - gammaA*y(3*6 + (1:6));
    %Recovered dynamics
    dydt(4*6 + (1:6)) = gammaI*y(2*6 + (1:6)) + gammaA*y(3*6 + (1:6));
end

end