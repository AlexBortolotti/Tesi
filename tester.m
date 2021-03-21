clear all
load tester
[t,y,t_short] = modello(simulength, susc, cont_mat, tau, delta_E, prob_symp, gammaI, gammaA, initS, initE, initI, initA, initR, firstDay);
figure
tiledlayout('flow')
% nexttile
% plot(t,y(:,2*6+(1:6)));
% title('Lombardy | I | Prem 2017 work cont. matr. + starting October 9') 
% legend({'0-19','20-34','35-49','50-59','60-69','70+'},'Location','southwest')
nexttile
k = (table2array(data_table(firstDay,2))-sum(initI))/sum(initA);
%Infecteds + correction for detected asymptomatics
inf_asy_corr = y(:,2*6+(1:6))+k*y(:,3*6+(1:6));
plot(t,sum(inf_asy_corr,2));
title('Tester')
hold on
%Real data comparison
y_real = table2array(data_table(firstDay:firstDay+simulength,2));
scatter(t_short,y_real)

models = {'Models'; 'Data'};
[~, t_max_mod] = max(sum(inf_asy_corr,2));
t_max_mod=t(t_max_mod);
[~, t_max_data] = max(y_real);
t_max_data = t_max_data+firstDay;
t_peak = [t_max_mod; t_max_data];

T = table(models, t_peak);
disp(T)