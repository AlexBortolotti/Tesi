clear all
%SIMULATION LOAD
load tester

%SIMULATION RUN

[t,y,t_short,refin] = model(simulength, susc, cont_mat, agg_istat_pyr, tau, delta_E, prob_symp, gammaI, gammaA, initS, initE, initI, initA, initR, firstDay);

lastDay = simulength*refin + simulength + 1;
initS_lock = y(lastDay,1:6);
initE_lock = y(lastDay,7:12);
initI_lock = y(lastDay,13:18);
initA_lock = y(lastDay,19:24);
initR_lock = y(lastDay,25:30);

[t_lock,y_lock,t_short_lock,refin_lock] = model(simulength_lock, susc, cont_mat_lock, agg_istat_pyr, tau, delta_E, prob_symp, gammaI, gammaA, initS_lock, initE_lock, initI_lock, initA_lock, initR_lock, firstDay_lock);

lastDay_lock = simulength_lock*refin_lock + simulength_lock + 1;
initS_lock2 = y_lock(lastDay_lock,1:6);
initE_lock2 = y_lock(lastDay_lock,7:12);
initI_lock2 = y_lock(lastDay_lock,13:18);
initA_lock2 = y_lock(lastDay_lock,19:24);
initR_lock2 = y_lock(lastDay_lock,25:30);

[t_lock2,y_lock2,t_short_lock2,refin_lock2] = model(simulength_lock2, susc, cont_mat_lock2, agg_istat_pyr, tau, delta_E, prob_symp, gammaI, gammaA, initS_lock2, initE_lock2, initI_lock2, initA_lock2, initR_lock2, firstDay_lock2);

%TEMPORARY for FINAL SIZE
lastDay_lock2 = simulength_lock2*refin_lock2 + simulength_lock2 + 1;
initS_final = y_lock2(lastDay_lock2,1:6);
initE_final = y_lock2(lastDay_lock2,7:12);
initI_final = y_lock2(lastDay_lock2,13:18);
initA_final = y_lock2(lastDay_lock2,19:24);
initR_final = y_lock2(lastDay_lock2,25:30);

[t_final,y_final,t_short_final] = model(simulength_final, susc, cont_mat_lock2, agg_istat_pyr, tau, delta_E, prob_symp, gammaI, gammaA, initS_lock2, initE_lock2, initI_lock2, initA_lock2, initR_lock2, firstDay_lock2);

%Infecteds + correction for detected asymptomatics plot
k = (table2array(data_table(firstDay,2))-sum(initI))/sum(initA);
inf_asy_corr = y(:,2*6+(1:6))+k*y(:,3*6+(1:6));
% inf_asy_corr = y(:,2*6+(1:6));
inf_asy_corr_lock = y_lock(:,2*6+(1:6))+k*y_lock(:,3*6+(1:6));
% inf_asy_corr_lock = y_lock(:,2*6+(1:6));
inf_asy_corr_lock2 = y_lock2(:,2*6 + (1:6))+k*y_lock2(:,3*6+(1:6));
% inf_asy_corr_lock2 = y_lock2(:,2*6 + (1:6));
% plot([t;t_lock;t_lock2],sum([inf_asy_corr; inf_asy_corr_lock;inf_asy_corr_lock2],2));

%% Simulation
%DATE TIMING
date_t = datetime(2020,02,24) + caldays(firstDay-1);
date_t = date_t + caldays(0:(simulength + simulength_lock + simulength_lock2-1));
refin = fix(length(t)/length(t_short));
inf_asy_corr = inf_asy_corr((refin+1)*((t_short(1:end-1) - firstDay + 1)-1)+1,:);
inf_asy_corr_lock  = inf_asy_corr_lock((refin+1)*((t_short_lock(1:end-1) - firstDay_lock + 1)-1)+1,:);
inf_asy_corr_lock2 = inf_asy_corr_lock2((refin+1)*((t_short_lock2(1:end-1) - firstDay_lock2 + 1)-1)+1,:);

%PLOT SIMULATION
subplot(2,2,1:2)
% tiledlayout('flow')

% nexttile
plot(date_t',sum([inf_asy_corr; inf_asy_corr_lock; inf_asy_corr_lock2],2));
% title('Infected + Asymptomatics')
hold on

%PLOT REAL DATA
y_real = table2array(data_table(firstDay:firstDay+simulength+simulength_lock + simulength_lock2 - 1,2));
scatter(date_t,y_real)
legend({'Model', 'Data'},'Location', 'northwest');

xline(datetime(2020,11,06),'--',{'Strict lockdown'});
xline(datetime(2020,11,26),'--',{'End'});

%PLOT HEATMAP USED IN SIMULATION
subplot(2,2,3)
h = heatmap(k_italy_lock);
h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('Schools')
xlabel('Age group of individual')
ylabel('Age group of contact')

%PLOT AGE-STRATIFIED DATA
subplot(2,2,4)
% nexttile
plot(date_t,[inf_asy_corr; inf_asy_corr_lock;inf_asy_corr_lock2]);
% title('Age-stratified graph')
legend({'0-19','20-34','35-49','50-59','60-69','70+'},'Location','northwest')

%PEAK SIZE AND PEAK TIME TABLE
Simulation_type = {'Model'; 'Data'};
[peak_mod, t_max_mod] = max(sum([inf_asy_corr; inf_asy_corr_lock;inf_asy_corr_lock2],2));
t_tot = [t_short(1:end-1)';t_short_lock(1:end-1)';t_short_lock2(1:end-1)'];
t_max_mod=t_tot(t_max_mod);
[peak_data, t_max_data] = max(y_real);
t_max_data = t_max_data+firstDay;
Peak_Size = [fix(peak_mod); peak_data];
Peak_Time = [datetime(2020,02,24) + caldays(fix(t_max_mod)); datetime(2020,02,24) + caldays(t_max_data)];

T = table(Simulation_type, Peak_Size, Peak_Time);
disp(T)

%% FINAL SIZE
%Numerical estimate
N = sum(pyramid);
final_size = sum(y_final(end,1:6),2)/N;
%Theoretical estimate
fun = @(x) exp(R0*(x-1)) - x;
theoretical_final_size = fzero(fun,0.1);

%Table with result
disp("Final size presented in form of 'fraction of susceptibles'")
% Source = {'Theoretical'; 'Simulated'};
% Final_Size = [theoretical_final_size; final_size];
Source = ({'Simulated'});
Final_Size = [final_size];
T_final = table(Source,Final_Size);
disp(T_final)

%% Heatmaps prints
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
% h = heatmap(K);
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
% %Mild measures: reduced school contact by 80% and work contact by 90%,
% %others locations' contact set to 0.
% nexttile
% K = k_italy_home + k_italy_school/5 + k_italy_work/10;
% h = heatmap(K);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('(E)')
% xlabel('Age group of individual')
% ylabel('Age group of contact')
% 
% %Strong lockdown: schools closed, almost every workplace closed, reduced home contact and other locations contact
% nexttile;
% K = k_italy_home/2 + k_italy_others/10 + k_italy_work/10;
% h = heatmap(K);
% h.YDisplayData = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
% title('(F)')
% xlabel('Age group of individual')
% ylabel('Age group of contact')


%%%%%%%%%%%AUTOMATIC FIGURES ARRANGING%%%
% autoArrangeFigures()
