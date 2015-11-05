clear all

load('ex3data1.mat'); % training data stored in arrays X, y
m = size(X, 1);

% train
lambda = 0.1;
num_labels = 10; 
max_iter = 50;
[all_theta] = oneVsAll(X, y, num_labels, lambda,maxiter);

% predict
pred = predictOneVsAll(all_theta, X);
accuracy = mean(double(pred == y)) * 100;