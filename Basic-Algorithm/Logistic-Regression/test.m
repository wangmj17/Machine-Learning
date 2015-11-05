clear all

% load data
data = load('ex2data2.txt');
X = data(:, [1, 2]); y = data(:, 3);
X = mapFeature(X(:,1), X(:,2));

% train
lambda = 1;
max_iters = 400;
model = LogisticRegressionTrain(X,y,lambda,max_iters);

%predict
ans = LogisticRegressionPredict(X,model);
accuracy = mean(double(ans == y)) * 100;