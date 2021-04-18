function define_data()

%% Import Data
% Read US population data for 2010
% P_2010 = xlsread('us_population_data.xls','F12:DB12'); % This is an older estimate
P_2010 = dlmread('us_population.csv',',',[3 4 103 4]);

% Read Social Security actuary table
ATable = xlsread('actuary_table.xlsx','A3:G122');

% Read birth rate data
r_birth_value = xlsread('birth_rates.xls','B35:T42'); % extract female birth rates
r_birth_year  = xlsread('birth_rates.xls','B4:T4'); % extract year data was taken

% Read naturalization data
I_data = xlsread('naturalization.xls','C8:D19');

%% Process Actuary Table
% Note: death rate is approximated as time invariant
% Extract vector components
p_death_m = ATable(:,2); % odds of men dying as a function of age
p_death_f = ATable(:,5); % odds of women dying as a function of age

% 105 males are born for every 100 females. We can use this fact to create
% a ratio of men:women as a function of age
M = 105;
F = 100;
male_ratio(1) = M/(M + F); % ratio at birth
for i = 2:120 % up to an age of 119
    M = M*(1-p_death_m(i-1)); % number of men remaining from the original population
    F = F*(1-p_death_f(i-1)); % number of women remaining from the original population
    male_ratio(i,1) = M/(M+F);
end

%% Process Population Data

% Split into male and female populations
P_2010 = round([P_2010 P_2010].*[male_ratio(1:101) (1-male_ratio(1:101))]);

% Population data lumps all individuals over 100 years old into the last
% element of the vector. We need to break this up into specific ages.
for i = 101:120
    P_2010(i,:) = round(P_2010(i-1,:).*(1-[p_death_m(i-1) p_death_f(i-1)]));
end

%% Process Birth Rates
% Note: birth rate is approximated as time invariant
r_birth_value = r_birth_value(:,end); % extract last column for 2010 data

% Birth rate data comes in 5 year buckets. We need to decompose into 1 year elements.
r_birth = [zeros(10,1);                % no births to women less than 10
           ones(5,1)*r_birth_value(1); % age 10-14
           ones(5,1)*r_birth_value(2); % age 15-19; 
           ones(5,1)*r_birth_value(3); % age 20-24; 
           ones(5,1)*r_birth_value(4); % age 25-29; 
           ones(5,1)*r_birth_value(5); % age 30-34;
           ones(5,1)*r_birth_value(6); % age 35-39;
           ones(5,1)*r_birth_value(7); % age 40-44;
           ones(5,1)*r_birth_value(6); % age 45-49 (includes births to women older);
           zeros(70,1)];               % age 50+

%% Process Immigration Rates
% Note: naturalization of immigrants is approximated as time invariant

% Naturalization comes various age brackets. We need to decompose into 1 year increments.
P_immigrants = [zeros(18,2);                % no naturalized citizens less than 18
                ones(2,1)*I_data(1,:)/2; % age 18-19
                ones(5,1)*I_data(2,:)/5; % age 20-24 
                ones(5,1)*I_data(3,:)/5; % age 25-29 
                ones(5,1)*I_data(4,:)/5; % age 30-34
                ones(5,1)*I_data(5,:)/5; % age 35-39
                ones(5,1)*I_data(6,:)/5; % age 40-44
                ones(5,1)*I_data(7,:)/5; % age 45-49
                ones(5,1)*I_data(8,:)/5; % age 50-54
                ones(5,1)*I_data(9,:)/5; % age 55-59
                ones(5,1)*I_data(10,:)/5; % age 60-64
                ones(10,1)*I_data(11,:)/10; % age 65-74
                zeros(45,2)]; % temporary placeholder

% Final bucket of immigrants defined for everyone 75 and older. Need to
% decompose into 1 year increments, scaled according the estimate of
% immigrants per that age. We rely on the US 75+ population to get the
% ratios.
P_immigrants(76:end,1) = I_data(12,1)*P_2010(76:end,1)/sum(P_2010(76:end,1));
P_immigrants(76:end,2) = I_data(12,2)*P_2010(76:end,2)/sum(P_2010(76:end,2));

% Round to whole numbers
P_immigrants = round(P_immigrants);

%% Save Data
save model_parameters P_2010 p_death_m p_death_f r_birth P_immigrants