function [ ans ] = LinearRegressionPredict( X,model )
%LINEARREGRESSIONPREDICT Summary of this function goes here
%   Detailed explanation goes here
%   X is a m*n features matrix, where m is the number of samples, n is the
%   dimension of features.
%   ans returns the predicted value for input data X
%% Feature normalization
if model.mode == 1

    for i = 1:size(X,1)
        X(i,:) = (X(i,:)-model.mu)./model.sigma;
    end

end

%% Add intercept term to X
m = size(X,1);
X = [ones(m, 1), X];

%% Prediction
ans = X * model.theta;

end

