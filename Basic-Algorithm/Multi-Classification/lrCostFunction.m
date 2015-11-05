function [J, grad] = lrCostFunction(theta, X, y, lambda)
%LRCOSTFUNCTION Compute cost and gradient for logistic regression with 
%regularization
%   J = LRCOSTFUNCTION(theta, X, y, lambda) computes the cost of using
%   theta as the parameter for regularized logistic regression and the
%   gradient of the cost w.r.t. to the parameters. 

m = length(y); % number of training examples
h = sigmoid(X * theta);
J = mean(-y.*log(h)-(1-y).*log(1-h)) + lambda * sum(theta(2:end).^2) / (2 * m);
grad = (X' * (h-y))/m + lambda * [0;theta(2:end)] / m;

end
