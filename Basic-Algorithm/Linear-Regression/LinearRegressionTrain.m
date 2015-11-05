function [ model] = LinearRegressionTrain( X,y,mode,alpha,num_iters )
%LINEARREGRESSION Summary of this function goes here
%   X is a m*n features matrix, where m is the number of samples, n is the
%   dimension of features.
%   y is a m*1 vector indicating the real value of each sample.
%   mode indicates whether to use gradient descent (mode = 1) or normal
%   equation (mode = others)
%   alpha is a parameter deciding the length of step in the (not need for normal equation)
%   num_iters is the max number of iterations in the gradient descent (not 
%   need for normal equation)

%% Gradient Descent
if mode == 1
    %% Feature normalization
    [X mu sigma] = featureNormalize(X);

    %% Add intercept term to X
    m = size(X,1);
    X = [ones(m, 1), X];
    
    %% Init Theta and Run Gradient Descent
    num_features = size(X,2);
    theta = zeros(num_features,1);
    [theta, J_history] = gradientDescentMulti(X, y, theta, alpha, num_iters);

    %% Plot the convergence graph
    figure;
    plot(1:numel(J_history), J_history, '-b', 'LineWidth', 2);
    xlabel('Number of iterations');
    ylabel('Cost J');

    %% Return model
    model.mu = mu;
    model.sigma = sigma;
    model.theta = theta;
    model.mode = mode;

%% Normal Equation
else
    %% Add intercept term to X
    m = size(X,1);
    X = [ones(m, 1), X];
    
    %% Compute Theta
    theta = normalEqn(X,y);
    
    %% Return model
    model.theta = theta;
    model.mode = mode;
end

end

