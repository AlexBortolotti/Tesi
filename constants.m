clear all
data_management

%%%%%%%%%%%DEMOGRAPHIC DATA%%%

%Lombardy age-stratified population
N = readtable('Lombardia-2020.csv');
% N = readtable('Emilia-2020.csv');
%Seroprevalance Lombardy
seroprev = 754331;
%Seroprevalence Emilia
% seroprev = 124458;
prem_bds = [0:5:75 105];
istat_bds = [0, 20, 35, 50, 60, 70, 105];
pyramid = table2array(N(:,2));
agg_istat_pyr = aggregate_pyramid(istat_bds, pyramid);

%%%%%%%%%%%TIME INITIALIZATION%%%
simulength = 80;
firstDay = 227;
sieroDay = 142;
%R0 per settimana 12-19 da report ISS
R0 = 1.67;

%%%%%%%%%%%INITIAL VALUES%%%

%ISS data 8 Oct
initI = (table2array(data_table(firstDay,2))*0.372)*[0.131, 0.148, 0.202, 0.199, 0.133, 0.187];
initA = initI.*(1./(1 - [0.1809 0.2279 0.3134 0.398 0.3980 0.8291]));
%Estimation of new infections after latent period estimate by Gatto et al
initE = ((table2array(data_table(firstDay + 5, 2)) + table2array(data_table(firstDay + 4, 2)) - 2 * table2array(data_table(firstDay,2)))/2)*[0.131, 0.148, 0.202, 0.199, 0.133, 0.187];
%InitR = sierological prevalence at 15th July + recovered from 15 Jul to 1 Sept + dead at 1 Sept
initR = (seroprev + (table2array(data_table(firstDay,3)) - table2array(data_table(sieroDay,3))) + table2array(data_table(firstDay,4)))*[0.131, 0.148, 0.202, 0.199, 0.133, 0.187];
%initS = initial number of susceptibles after considering infecteds and
%removed
%ISTAT bds is 0-17, 18-34, 35-49, 50-59, 60-69, 70+, approximated to 0-19,
%20-34 etc...
initS = agg_istat_pyr' - (initE + initI + initA + initR);

%%%%%%%%%%%PARAMETERS%%%

%Contact matrix and age structure
% k_italy = table2array(readtable('MUestimates_all_locations_1.xlsx','Sheet','Italy')); % Load contact matrix with 16 age classes. Prem et al. 2017
% k_italy_work = table2array(readtable('contact_matrices_2017/MUestimates_work_1','Sheet','Italy'));
% k_italy_home = table2array(readtable('contact_matrices_2017/MUestimates_home_1','Sheet','Italy'));
% k_italy_other = table2array(readtable('contact_matrices_2017/MUestimates_other_locations_1','Sheet','Italy'));
% k_italy = k_italy_work + k_italy_home + k_italy_other;
k_italy = table2array(readtable('ITA2.xlsx')); % Load contact matrix with 16 age classes. Prem et al. 2020
k_italy = k_italy(:,2:end);

%Exit rate from latent state
delta_E = 0.52;

%Reduced infectivity factors by age vector for asymptomatic individuals.
%50% reduction comes from ISS-FBK estimates
% tau = ones(6,1)*(1/2);
tau=1/2;

% Contact matrix by Prem (UPDATED: Prem et al is aggregated contact matrix +
%susceptible population, so we disaggregate the contact matrix from the
%population distribution to obtain contact coefficients and aggregate it
%w.r.t. appropriate bds)
% cont_mat = [1,1,1,1,1,1; 1,1,1,1,1,1; 1,1,1,1,1,1; 1,1,1,1,1,1; 1,1,1,1,1,1; 1,1,1,1,1,1];
cont_mat = aggregate_contact_matrix(k_italy, prem_bds, istat_bds, pyramid);
cont_mat = dis_coeff(cont_mat,agg_istat_pyr);

%Probability of developing symptoms by FBK estimates
prob_symp = [0.1809 0.2279 0.3134 0.398 0.398 0.8291]';

%Removal rates from Gatto et al
gamma_cat = 0.0698;
alpha_cat = 0.04127;
eta_cat = 0.02469;
%Probability of developing symptoms changed from Gatto et al. Used
%arithmetical average.
zeta_cat = sum(prob_symp)/length(prob_symp); 
gammaI = (1/(eta_cat + gamma_cat + alpha_cat))*(gamma_cat^2 + eta_cat*(zeta_cat*gamma_cat + (1-zeta_cat)*(gamma_cat+alpha_cat))+alpha_cat^2);
% gammaI = 0.0698;
gammaA = 0.1397;

%Susceptibility constants fitting
% susc = [0.007 0.045 0.07 0.15 0.377 0.52]';  
susc = R0*((initE')./((tau/gammaA)*(1-prob_symp).*initS'.*(cont_mat*initE'.*(1-prob_symp))));
% susc2 = R0*((initI')./((cont_mat*initA').*initS'.*(1-prob_symp).*tau));

save tester