clear all
% load('simulations/simul_susc_fit.mat')
load tester

[t,y,t_short,refin] = model_HK(simulength, susc, cont_mat, tau, delta_E, prob_symp, gammaI, gammaA, initS, initE, initI, initA, initR, firstDay);

lastDay = simulength*refin + simulength + 1;
initS_lock = y(lastDay,1:6);
initE_lock = y(lastDay,7:12);
initI_lock = y(lastDay,13:18);
initA_lock = y(lastDay,19:24);
initR_lock = y(lastDay,25:30);

[t_lock,y_lock,t_short_lock] = model_HK(simulength_lock, susc, cont_mat_lock, tau, delta_E, prob_symp, gammaI, gammaA, initS_lock, initE_lock, initI_lock, initA_lock, initR_lock, firstDay_lock);

figure
% tiledlayout('flow')
% nexttile
% plot(t,y(:,2*6+(1:6)));
% title('Lombardy | I | Prem 2017 work cont. matr. + starting October 9') 
% legend({'0-19','20-34','35-49','50-59','60-69','70+'},'Location','southwest')
% nexttile
%Infecteds + correction for detected asymptomatics plot
k = (table2array(data_table(firstDay,2))-sum(initI))/sum(initA);
inf_asy_corr = y(:,2*6+(1:6))+k*y(:,3*6+(1:6));
inf_asy_corr_lock = y_lock(:,2*6+(1:6))+k*y_lock(:,3*6+(1:6));
plot([t; t_lock],sum([inf_asy_corr; inf_asy_corr_lock],2));
title('Infected + Asymptomatics')
hold on
%Real data comparison
y_real = table2array(data_table(firstDay:firstDay+simulength+simulength_lock,2));
scatter([t_short t_short_lock(2:end)],y_real)
legend({'Model', 'Data'},'Location', 'northeast');

figure
plot([t; t_lock],[inf_asy_corr; inf_asy_corr_lock]);
title('Age-stratified graph')
legend({'0-19','20-34','35-49','50-59','60-69','70+'},'Location','southwest')

models = {'Models'; 'Data'};
[~, t_max_mod] = max(sum([inf_asy_corr; inf_asy_corr_lock],2));
t_tot = [t;t_lock];
t_max_mod=t_tot(t_max_mod);
[~, t_max_data] = max(y_real);
t_max_data = t_max_data+firstDay;
t_peak = [t_max_mod; t_max_data];

T = table(models, t_peak);
disp(T)

%%%%%%%%%%%HEATMAPS PRINTS%%%

% figure
% heatmap(k_italy, 'ColorMap',jet)
% title('Standard')
% figure
% heatmap(k_italy_school, 'ColorMap',jet)
% title('Scuole')
% figure
% heatmap(k_italy_work, 'ColorMap',jet)
% title('Lavoro')
% figure
% heatmap(k_italy_others, 'ColorMap',jet)
% title("Altri")
% figure
% heatmap(k_italy_home, 'ColorMap',jet)
% title('Casa')
% figure
% heatmap(k_italy-k_italy_school, 'ColorMap',jet)
% title('Scuole chiuse')
% figure
% heatmap(k_italy-k_italy_school-k_italy_others, 'ColorMap',jet)
% title('Scuole e altri chiusi')


%%%%%%%%%%%AUTOMATIC FIGURES ARRANGING%%%
autoArrangeFigures()