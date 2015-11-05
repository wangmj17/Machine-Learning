function [ model ] = LogisticRegressionTrain( X,y,lambda,max_iters )
%LOGISTICREGRESSIONTRAIN Summary of this function goes here
%   X is a m*n features matrix, where m is the number of samples, n is the
%   dimension of features.
%   y is a m*1 vector indicating the real value of each sample.
%   lambda is the regularization parameter
%   num_iters is the max number of iterations in the optimization function
%% Add intercept term to X
m = size(X,1);
X = [ones(m, 1), X];

%% Initialize fitting parameters
initial_theta = zeros(size(X, 2), 1);

%% Set Options and optimize
options = optimset('GradObj', 'on', 'MaxIter', max_iters);
[theta, J, exit_flag] = ...
	fminunc(@(t)(costFunctionReg(t, X, y, lambda)), initial_theta, options);

%% return model
model.theta = theta;

end

