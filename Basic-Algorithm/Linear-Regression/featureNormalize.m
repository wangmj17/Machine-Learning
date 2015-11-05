function [X_norm, mu, sigma] = featureNormalize(X)
%FEATURENORMALIZE Normalizes the features in X 
%   FEATURENORMALIZE(X) returns a normalized version of X where
%   the mean value of each feature is 0 and the standard deviation
%   is 1. This is often a good preprocessing step to do when
%   working with learning algorithms.

X_norm = X;
mu = mean(X);
sigma = std(X);
for i=1:length(mu)
    X_norm(:,i) = (X(:,i) - mu(i))/sigma(i);
end

end
