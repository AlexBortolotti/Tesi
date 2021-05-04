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
%         R0 = 2.09;
        R0 = 1.95;
%         R0 = 1.05;
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
simulength = 18; %timespan of pre-lockdown measures
simulength_lock = 38 - simulength; %timespan of lockdown measures
simulength_lock2 = 60 - simulength_lock - simulength;
simulength_final = 120; %timespan for approximating final size
% firstDay = 224;
% firstDay = 227; %8th Oct
firstDay = 239; %20th Oct
% firstDay = 366; %24th Feb 21
firstDay_lock = firstDay + simulength;
firstDay_lock2 = firstDay_lock + simulength_lock;
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
k_italy = k_italy_home + k_italy_school/10 + k_italy_work/10 + k_italy_others/10;

%Age structured contact matrix after lockdown
%Scaling factor due high-schools closing
% scalar = ones(16);
% scalar(3,3) = scalar(3,3)*(1/10);
% scalar(4,4) = scalar(4,4)*(1/15);
% scalar(2,2) = scalar(2,2)*(1/10);
% k_italy_school = k_italy_school.*scalar;
% k_italy_school = 0;
% % Scaling factor for in-home reduction of contacts
% scalar = ones(16);
% scalar = scalar + diag(ones(1,16)*0.5);
% k_italy_home = scalar.*k_italy_home;

%CONTACT MATRICES FOR RESTRICTION MEASURES
k_italy_lock = (k_italy_home/2 + k_italy_work/15)*0.8;
% k_italy_lock = k_italy_home/10;
% k_italy_lock = k_italy;

k_italy_lock2 = k_italy*0.5;
% k_italy_lock2 = k_italy_lock;
%No over 70 contact
% k_italy_lock2(1:16,15:16) = zeros(16,2);
% k_italy_lock2(15:16,1:16) = zeros(2,16);

% Contact matrix by Prem (UPDATED: Prem et al is aggregated contact matrix +
%susceptible population, so we disaggregate the contact matrix from the
%population distribution to obtain contact coefficients and aggregate it
%w.r.t. appropriate bds)
k_italy_aggr = aggregate_contact_matrix(k_italy, prem_bds, istat_bds, pyramid);
cont_mat = dis_coeff(k_italy_aggr,agg_istat_pyr);
cont_mat_lock = aggregate_contact_matrix(k_italy_lock, prem_bds, istat_bds, pyramid);
cont_mat_lock = dis_coeff(cont_mat_lock, agg_istat_pyr);
cont_mat_lock2 = aggregate_contact_matrix(k_italy_lock2, prem_bds, istat_bds, pyramid);
cont_mat_lock2 = dis_coeff(cont_mat_lock2, agg_istat_pyr);

%NO LOCKDOWN
% k_italy_lock = k_italy;
% cont_mat_lock = cont_mat;


%Exit rate from latent state
delta_E = 0.3012;

%Reduced infectivity factors by age vector for asymptomatic individuals.
%50% reduction comes from ISS-FBK estimates
% tau = ones(6,1)*(1/2);
tau=1/2;

%Probability of developing symptoms by FBK estimates
% prob_symp = 0.30;
prob_symp = [0.1809 0.2279 0.3134 0.398 0.398 0.8291]';
prob_symp = prob_symp.*[1 0.9 0.8 0.7 0.6 0.5]'*0.85;
% prob_symp = prob_symp.*[1 0.9 0.8 0.7 0.6 0.3]';
% prob_symp = prob_symp/5;

%Removal rates from Gatto et al
gamma_cat = 0.0698;
alpha_cat = 0.04127;
eta_cat = 0.02469;
%Probability of developing symptoms changed from Gatto et al. Used
%arithmetical average.
zeta_cat = sum(prob_symp)/length(prob_symp); 
gammaI = (1/(eta_cat + gamma_cat + alpha_cat))*(gamma_cat^2 + eta_cat*(zeta_cat*gamma_cat + (1-zeta_cat)*(gamma_cat+alpha_cat))+alpha_cat^2);
gammaA = 0.1397;

%Susceptibility Hilton-Keeling
% susc = ([0.007 0.045 0.07 0.15 0.377 0.52]'./prob_symp);
% R = (k_italy_aggr.*((1 - prob_symp).*susc))*(tau/gammaA).*(1-prob_symp');
% corrector = eig(R);
% susc = susc*(R0/corrector(1));
% R0 = 1.8;
% susc = susc*(R0/1.0504);


% initS=initS*0.20;

%OLD/ARCHIVE
susc = R0*((initE')./(((tau/gammaA)*(1-prob_symp)).*((cont_mat.*initS')*(initE'.*(1-prob_symp)))));
R = (k_italy_aggr.*((1 - prob_symp).*susc))*(tau/gammaA).*(1-prob_symp');
corrector = eig(R);
susc = susc*(R0/corrector(1));
%TEST as Hilton-Keeling
% susc = (R0*((initI')./((cont_mat.*initS')*(initI'./agg_istat_pyr))))./prob_symp;
% susc = susc*(2.09/3.06);

infos = "STANDARD. Only home contacts";
infos = compose(infos);

save tester