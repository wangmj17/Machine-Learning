function [ E ] = EER(labeledfeatures, labels, unlabeledfeatures  )
%SELECTX Summary of this function goes here
%   Input: features of labeled instances, labels of labeled instances ,
%   features of unlabeled instances
%   Output: E, the base informativeness
    
    n = length(labels);
    m = size(unlabeledfeatures,1);
    % compute P
    model = svmtrain(ones(n,1),labels,labeledfeatures,'-t 2 -b 1');
    [label,accuracy,P] = svmpredict(zeros(m,1),unlabeledfeatures,model,'-b 1');
    
    % compute H
    H = zeros(m,2);
    for i=1:m
        model0 = svmtrain(ones(n+1,1),[labels;-1],[labeledfeatures;unlabeledfeatures(i,:)],'-t 2 -b 1 -q');
        [label,accuracy,prob] = svmpredict(zeros(m-1,1),unlabeledfeatures([1:i-1,i+1:end],:),model0,'-b 1 -q');
        H(i,1) = - sum(prob(:,1).*log(prob(:,1))) - sum(prob(:,2).*log(prob(:,2)));
        
        model1 = svmtrain(ones(n+1,1),[labels;1],[labeledfeatures;unlabeledfeatures(i,:)],'-t 2 -b 1 -q');
        [label,accuracy,prob] = svmpredict(zeros(m-1,1),unlabeledfeatures([1:i-1,i+1:end],:),model1,'-b 1 -q');
        H(i,2) = - sum(prob(:,1).*log(prob(:,1))) - sum(prob(:,2).*log(prob(:,2)));
    end
    
    % compute E
    E = P(:,1).*H(:,1) + P(:,2).*H(:,2);
    
end

