function [all_theta] = oneVsAll(X, y, num_labels, lambda, max_iter)
%ONEVSALL trains multiple logistic regression classifiers and returns all
%the classifiers in a matrix all_theta, where the i-th row of all_theta 
%corresponds to the classifier for label i
%   [all_theta] = ONEVSALL(X, y, num_labels, lambda, max_iter) trains num_labels
%   logisitc regression classifiers and returns each of these classifiers
%   in a matrix all_theta, where the i-th row of all_theta corresponds 
%   to the classifier for label i

% Some useful variables
m = size(X, 1);
n = size(X, 2);

% theta matrix
all_theta = zeros(num_labels, n + 1);

% Add ones to the X data matrix
X = [ones(m, 1) X];

% Optimization for each class
for i = 1:num_labels
    initial_theta = zeros(n+1,1);
    options = optimset('GradObj', 'on', 'MaxIter', max_iter);
    all_theta(i,:) = fmincg(@(t)(lrCostFunction(t,X,(y == i),lambda)),initial_theta,options);
end    


end
