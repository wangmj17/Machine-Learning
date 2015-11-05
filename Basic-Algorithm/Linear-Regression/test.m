clear all

data = load('ex1data2.txt');
X = data(:, 1:2);
y = data(:, 3);

% Choose some alpha value
alpha = 0.01;
num_iters = 400;

% Train
model = LinearRegressionTrain(X,y,1,alpha,num_iters);

% Predict
Xtest = [1650,3];
ans = LinearRegressionPredict(Xtest,model);