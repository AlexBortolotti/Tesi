% This script creates a population pyramid from Simulink data.

Pdata = logsout.getElement('P').Values.Data;
M1 = Pdata(:,1,1);
F1 = Pdata(:,2,1);
M2 = Pdata(:,1,end);
F2 = Pdata(:,2,end);

figure%('Position',[205 430 560 656])
hold on
c = bar(M2,'hist');
d = bar(-F2,'hist');
a = bar(M1,'hist');
b = bar(-F1,'hist');

title('US Population Pyramids for 2010 and 2100') % Customize as needed
xlabel('Age')
ylabel('Population')
legend('Men','Women')
axis([0 110 -3000000 3000000])
set(gca,'YTickLabel',{'3','2','1','0','1','2','3'})
view(-90,90)

set(a,'FaceColor',.8*[0.53 0.81 0.98])
set(b,'FaceColor',.8*[1 0.41 0.71])
set(c,'FaceColor',.8*[0.53 0.81 0.98])
set(d,'FaceColor',.8*[1 0.41 0.71])

set(c,'FaceAlpha',0.5);
set(d,'FaceAlpha',0.5);