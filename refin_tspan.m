function new_tspan = refin_tspan(old_tspan, num_el)
%Mesh refiner for time.
%INPUT-OUTPUT
%old_tspan      -> Old timespan vector
%num_el         -> Number of elements to be added between every two nodes
%new_tspan      <- New refined timespan vector

refin=num_el+1;
for i=1:length(old_tspan)-1
    start_point = 1 + (i-1)*refin;
    new_points = linspace(old_tspan(start_point),old_tspan(start_point+1),refin+1);
    new_points = new_points(2:refin);
    old_tspan = [old_tspan(1:start_point) new_points old_tspan(start_point+1:end)];
end

new_tspan = old_tspan;

end