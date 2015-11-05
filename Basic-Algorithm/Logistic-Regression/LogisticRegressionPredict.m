function [ ans ] = LogisticRegressionPredict( X,model)
%LOGISTICREGRESSIONPREDICT Summary of this function goes here
%   X is a m*n features matrix, where m is the number of samples, n is the
%   dimension of features.
%   ans returns the predicted label for input data X

%% Add intercept term to X
m = size(X,1);
X = [ones(m, 1), X];

%% Prediction
ans = sigmoid(X * model.theta);
ans = double(ans>=0.5);

end

