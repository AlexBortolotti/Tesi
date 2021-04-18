% This script creates an animation showing the population distribution as a
% function of year.

for i = 1:length(logsout.getElement('P').Values.Time)
    P_total = logsout.getElement('P').Values.Data(:,1,i) + logsout.getElement('P').Values.Data(:,2,i);
    
    plot(0:119,P_total)
    axis([0 100 0 6E6])
    legend(num2str(2009+i))
    xlabel('Age')
    ylabel('Population')
    title('Population vs Age')
    pause(1/10)
end