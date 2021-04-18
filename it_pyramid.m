% Pyramid script
clear all

pyr = readtable('Lombardia_Pyramid');
pyr = table2array(pyr(:,2:3));
age = 0:5:100;
age = age';
pyr = [age pyr];

M = pyr(:,3);
F = pyr(:,2);
N = sum(M+F);
M = (M/N)*100;
F = (F/N)*100;

figure%('Position',[205 430 560 656])
hold on
a = bar(age,M,'hist');
b = bar(age,-F,'hist');
% a = bar(M1,'hist');
% b = bar(-F1,'hist');

% title('Lombardy population pyramid 2020') % Customize as needed
xlabel('Age')
ylabel('Proportion of population (%)')
legend('Men','Women')
axis([0 100 -5 5])
set(gca,'YTickLabel',{'5','4','3','2','1','0','1','2','3','4','5'})
view(-90,90)

set(a,'FaceColor',.8*[0.53 0.81 0.98])
set(b,'FaceColor',.8*[1 0.41 0.71])
% set(c,'FaceColor',.8*[0.53 0.81 0.98])
% set(d,'FaceColor',.8*[1 0.41 0.71])

% set(c,'FaceAlpha',0.5);
% set(d,'FaceAlpha',0.5);
