function [J, grad] = costFunctionReg(theta, X, y, lambda)
%COSTFUNCTIONREG Compute cost and gradient for logistic regression with regularization
%   J = COSTFUNCTIONREG(theta, X, y, lambda) computes the cost of using
%   theta as the parameter for regularized logistic regression and the
%   gradient of the cost w.r.t. to the parameters. 

m = length(y); % number of training examples
grad = zeros(size(theta));

h = sigmoid(X * theta);
J = mean(-y.*log(h)-(1-y).*log(1-h)) + lambda*sum(theta(2:end).^2)/(2*m);

grad(1) = mean((h-y).*X(:,1));

for i=2:length(grad)
    grad(i) = mean((h-y).*X(:,i)) + lambda * theta(i)/m;
end

end
