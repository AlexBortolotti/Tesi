function agg_pyr = aggregate_pyramid(new_bds, pyramid)
%Aggregator from population pyramid assumed 0-4,5-9,...,100+ to a smaller
%bds
%INPUT-OUTPUT
%new_bds        -> smaller bds vector
%pyramid        -> given population pyramid vector
%agg_pyr        <- aggregate pyramid vector

pyr_bds = 0:5:105;

aggregator=zeros(length(pyr_bds)-1,1); % This matrix stores where each class in finer structure is in coarser structure
for i=1:length(pyr_bds)-1
    aggregator(i)=find(new_bds>=pyr_bds(i+1),1)-1;
end

%Sparse matrix with element ij meaning that the j-th age class of the pyramid
%is cointained in the i-th age class of new_bds. Then sum along rows. 
agg_pyr = sum(sparse(aggregator,1:length(aggregator),pyramid),2);

%conversion from sparse to array
agg_pyr=full(agg_pyr);
end