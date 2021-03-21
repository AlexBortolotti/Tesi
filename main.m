%Model with no age-dependent parameters
%TODO: Ideally a parameter fit for contact rate in order to compare non
%age-structured and age-structured population
% clear all
% load constants_noage
% [t,y] = modello(simulength, susc, cont_mat, tau, delta_E, prob_symp, gammaI, gammaA, initS, initE, initI, initA, initR, firstDay);
% figure
% plot(t,y(:,2*6+(1:6)));
% title('Lombardy-Infecteds-NoAge') 
% legend({'0-19','20-34','35-49','50-59','60-69','70+'},'Location','southwest')


% %Standard model with estimated parameters
% clear all
% simulength=1;
% load constants_0
% [t,y,t_short] = modello(simulength, susc, cont_mat, tau, delta_E, prob_symp, gammaI, gammaA, initS, initE, initI, initA, initR, firstDay);
% figure
% tiledlayout('flow')
% nexttile
% plot(t,y(:,2*6+(1:6)));
% title('Lombardy | I | Standard') 
% legend({'0-19','20-34','35-49','50-59','60-69','70+'},'Location','southwest')
% nexttile
% plot(t,sum(y(:,2*6+(1:12)),2))
% title('Lombardy | I+A | Aggregated vs Data')
% hold on
% %Real data comparison
% y_real = table2array(data_table(firstDay:firstDay+simulength,2));
% scatter(t_short,y_real)

% %Model with susceptiblity = linspace(0.5,0.8,6)
% clear all
% simulength=1;
% load constants_susc1_2020
% [t,y,t_short] = modello(simulength, susc, cont_mat, tau, delta_E, prob_symp, gammaI, gammaA, initS, initE, initI, initA, initR, firstDay);
% figure
% plot(t,y(:,2*6+(1:6)));
% title('Lombardy | I | Susceptibility from 0.5 to 0.8') 
% legend({'0-19','20-34','35-49','50-59','60-69','70+'},'Location','southwest')

% %Model with only work contact matrix from 2017
% clear all
% simulength=10;
% load constants_work_2017
% [t,y,t_short] = modello(simulength, susc, cont_mat, tau, delta_E, prob_symp, gammaI, gammaA, initS, initE, initI, initA, initR, firstDay);
% figure
% tiledlayout('flow')
% nexttile
% plot(t,y(:,2*6+(1:6)));
% title('Lombardy | I | Prem 2017 work contact matrix') 
% legend({'0-19','20-34','35-49','50-59','60-69','70+'},'Location','southwest')
% nexttile
% plot(t,sum(y(:,2*6+(1:12)),2))
% title('Lombardy | I+A | Prem 2017 work contact matrix')
% hold on
% %Real data comparison
% y_real = table2array(data_table(firstDay:firstDay+simulength,2));
% scatter(t_short,y_real)

%Model with only work contact matrix from 2017
clear all
simulength=100;
load constants_oct_work_2017
[t,y,t_short] = modello(simulength, susc, cont_mat, tau, delta_E, prob_symp, gammaI, gammaA, initS, initE, initI, initA, initR, firstDay);
figure
tiledlayout('flow')
nexttile
plot(t,y(:,2*6+(1:6)));
title('Lombardy | I | Prem 2017 work cont. matr. + starting October 9') 
legend({'0-19','20-34','35-49','50-59','60-69','70+'},'Location','southwest')
nexttile
plot(t,sum(y(:,2*6+(1:12)),2))
title('Lombardy | I+A | Prem 2017 work cont. matr. + starting October 9')
hold on
%Real data comparison
y_real = table2array(data_table(firstDay:firstDay+simulength,2));
scatter(t_short,y_real)

autoArrangeFigures()