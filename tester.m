clear all
% load('simulations/simul_susc_fit.mat')
load tester

[t,y,t_short,refin] = model(simulength, susc, cont_mat, agg_istat_pyr, tau, delta_E, prob_symp, gammaI, gammaA, initS, initE, initI, initA, initR, firstDay);

lastDay = simulength*refin + simulength + 1;
initS_lock = y(lastDay,1:6);
initE_lock = y(lastDay,7:12);
initI_lock = y(lastDay,13:18);
initA_lock = y(lastDay,19:24);
initR_lock = y(lastDay,25:30);

[t_lock,y_lock,t_short_lock] = model(simulength_lock, susc, cont_mat_lock, agg_istat_pyr, tau, delta_E, prob_symp, gammaI, gammaA, initS_lock, initE_lock, initI_lock, initA_lock, initR_lock, firstDay_lock);

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

%%%%Heatmaps for locations

% tiledlayout(3,2)
% nexttile
% k_italy = table2array(readtable('contact_matrices_2020/contact_ita_all.csv'));
% h = heatmap(k_italy);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('All locations')
% xlabel('Age group of indivual')
% ylabel('Age group of contact')
% nexttile
% h = heatmap(k_italy_home);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('Household')
% xlabel('Age group of individual')
% ylabel('Age group of contact')
% nexttile
% h = heatmap(k_italy_school);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('Schools')
% xlabel('Age group of individual')
% ylabel('Age group of contact')
% nexttile
% h = heatmap(k_italy_work);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('Workplace')
% xlabel('Age group of individual')
% ylabel('Age group of contact')
% nexttile
% h = heatmap(k_italy_others);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title("Other locations")
% xlabel('Age group of individual')
% ylabel('Age group of contact')

%%%%Heatmaps with restriction measures

% tiledlayout(3,2)
% 
% %Mild social distancing
% nexttile
% K = table2array(readtable('contact_matrices_2020/contact_ita_all.csv'));
% K = K/2;
% h = heatmap(k_italy_work);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('(A)')
% xlabel('Age group of individual')
% ylabel('Age group of contact')
% 
% %Closed schools
% nexttile
% K = k_italy_home + k_italy_work + k_italy_others;
% h = heatmap(K);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('(B)')
% xlabel('Age group of indivual')
% ylabel('Age group of contact')
% 
% %Schools and workplaces closed. Only household and other locations contact
% nexttile
% K = k_italy_home + k_italy_others;
% h = heatmap(K);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('(C)')
% xlabel('Age group of individual')
% ylabel('Age group of contact')
% 
% %No closing measures: mandatory masks and recommended social distancing
% nexttile
% K = k_italy_home + 0.1*(k_italy_school + k_italy_work + k_italy_others);
% h = heatmap(K);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('(D)')
% xlabel('Age group of individual')
% ylabel('Age group of contact')
% 
% %Mild measures: mandatory masks and reduced non-work contacts
% nexttile
% K = k_italy_home + k_italy_school/5 + k_italy_work/10;
% h = heatmap(K);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('(E)')
% xlabel('Age group of individual')
% ylabel('Age group of contact')
% 
% %Strong lockdown: schools closed, almost every workplace closed, reduced home contact and other locations contact
% nexttile
% scalar = ones(16)*0.5;
% scalar = scalar + diag(ones(1,16)*0.5);
% K = scalar.*k_italy_home + k_italy_others/10 + k_italy_work/10;
% h = heatmap(K);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('(F)')
% xlabel('Age group of individual')
% ylabel('Age group of contact')


%%%%%%%%%%%AUTOMATIC FIGURES ARRANGING%%%
autoArrangeFigures()