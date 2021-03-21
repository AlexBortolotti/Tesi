function contact_coeff_matr = dis_coeff(cont_mat, pyramid)
%Contact coefficients matrix calculator from aggregated Prem et al. contact matrix.
%By Diekmann's book c(a,b)N(a) is by definition the expected amount of
%contacts per unit of time that an individual of age b has with all of the
%inviduals of age a. N(a) is the population probability distribution.
%INPUT-OUTPUT
%prem_cont_matr         -> aggregated Prem et al contact matrix
%pyramid                -> Population pyramid vector
%contact_coeff_matr     <- Contact coefficient matrix with coefficients defined as in Diekmann's book

%Population probability distribution
% pyramid = pyramid./sum(pyramid);

%Calculate coefficient contact matrix
contact_coeff_matr = cont_mat./pyramid;

end