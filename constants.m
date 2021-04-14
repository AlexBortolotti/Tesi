clear all
data_management

%%%%%%%%%%%DEMOGRAPHIC DATA%%%

%Switcher. Lombardia = 3; Emilia = 8;

% n = input("Region to simulate: Lombardy = 3; Emilia-Romagna = 8");
n=3;

switch n
    case 3
        N = readtable('Lombardia-2020.csv');
        seroprev = 754331;
        R0 = 2.09;
    case 8
        N = readtable('Emilia-2020.csv');
        seroprev = 124458;
        R0 = 1.67;
end

prem_bds = [0:5:75 105];
istat_bds = [0, 20, 35, 50, 60, 70, 105];
pyramid = table2array(N(:,2));
agg_istat_pyr = aggregate_pyramid(istat_bds, pyramid);

%%%%%%%%%%%TIME INITIALIZATION%%%
simulength = 7; %timespan of pre-lockdown measures
simulength_lock = 30 - simulength; %timespan of lockdown measures
% firstDay = 224;
firstDay = 227; %8th Oct
% firstDay = 239; %20th Oct
% firstDay = 366; %24th Feb 21
firstDay_lock = firstDay + simulength;
sieroDay = 142;

%%%%%%%%%%%INITIAL VALUES%%%

%ISS Data
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

%Age structured contact matrix on 20th Oct
% k_italy = table2array(readtable('contact_matrices_2020/contact_ita_all.csv')); % Load contact matrix with 16 age classes. Prem et al. 2017
k_italy_work = table2array(readtable('contact_matrices_2020/contact_ita_work.csv'));
k_italy_home = table2array(readtable('contact_matrices_2020/contact_ita_home.csv'));
k_italy_others = table2array(readtable('contact_matrices_2020/contact_ita_others.csv'));
k_italy_school = table2array(readtable('contact_matrices_2020/contact_ita_school.csv'));
k_italy = k_italy_home + k_italy_work;
% k_italy = zeros(16);
k_italy = k_italy/100;

%Age structured contact matrix after lockdown
%Scaling factor due high-schools closing
scalar = ones(16);
scalar(3,3) = scalar(3,3)*(1/10);
scalar(4,4) = scalar(4,4)*(1/15);
scalar(2,2) = scalar(2,2)*(1/10);
k_italy_school = k_italy_school.*scalar;
% k_italy_school = 0;
%Scaling factor for in-home reduction of contacts
scalar = ones(16)*0.5;
scalar = scalar + diag(ones(1,16)*0.5);
k_italy_home = scalar.*k_italy_home;
k_italy_lock = k_italy_work + k_italy_home + k_italy_school;
% k_italy_lock = k_italy_lock*0.9;

% Contact matrix by Prem (UPDATED: Prem et al is aggregated contact matrix +
%susceptible population, so we disaggregate the contact matrix from the
%population distribution to obtain contact coefficients and aggregate it
%w.r.t. appropriate bds)
% cont_mat = [1,1,1,1,1,1; 1,1,1,1,1,1; 1,1,1,1,1,1; 1,1,1,1,1,1; 1,1,1,1,1,1; 1,1,1,1,1,1];
cont_mat = aggregate_contact_matrix(k_italy, prem_bds, istat_bds, pyramid);
cont_mat = dis_coeff(cont_mat,agg_istat_pyr);
% cont_mat_lock = aggregate_contact_matrix(k_italy_lock, prem_bds, istat_bds, pyramid);
% cont_mat_lock = dis_coeff(cont_mat_lock, agg_istat_pyr);

%NO LOCKDOWN
k_italy_lock = k_italy;
cont_mat_lock = cont_mat;


%Exit rate from latent state
delta_E = 0.52;

%Reduced infectivity factors by age vector for asymptomatic individuals.
%50% reduction comes from ISS-FBK estimates
% tau = ones(6,1)*(1/2);
tau=1/2;

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
gammaA = 0.1397;

%Susceptibility constants fitting
% susc = ([0.007 0.045 0.07 0.15 0.377 0.52]'./prob_symp)*(1/2);  
% initS=initS.*(rand(1,6)*0.2);
% susc = R0*((initE')./(((tau/gammaA)*(1-prob_symp)).*((cont_mat.*initS')*(initE'.*(1-prob_symp)))));
%TEST as Hilton-Keeling, rho = susc
susc = (R0*((initI')./((cont_mat.*initS')*initI')))./prob_symp;

infos = "Susceptibility Simulation: results vary with choice of susceptibility. \n This test is with LITERATURE susceptibility.";
infos = compose(infos);

save tester