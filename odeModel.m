function dydt = odeModel(t,y, susc, prob_symp, tau, cont_mat, delta_E, gammaI, gammaA)
%ODE model
%INPUT-OUTPUT
%t          -> input time
%y          -> y = [S, E, I, A, R]
%susc       -> susceptibility
%prob_symp  -> probability of developing symptoms
%tau        -> decreased infectivity for asymptomatics
%cont_mat   -> contact matrix
%delta_E    -> exit rate from latent state
%gammaI     -> exit rate from infected state
%gammaA     -> exit rate from asymptomatic state
%result     <- array with resulting derivatives


end