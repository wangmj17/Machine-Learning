function [ index ] = selectx( labeledfeatures, labels, unlabeledfeatures, beta  )
%SELECTX Summary of this function goes here
%   Input: features of labeled instances, labels of labeled instances ,
%   features of unlabeled instances, and parameter beta which controls the
%   relative importance of the density term
%   Output: the index of the most informative unlabeled instance
%   
%   Notice: beta must be negative. (Expected error reduction choose the minimum value, while similarity choose the maximum value)
    
    [n,m] = size(unlabeledfeatures);
    % base informativeness computed by expected error reduction
    SE = EER(labeledfeatures, labels, unlabeledfeatures);
    
    
    % similarity
    sim = zeros(n,n);
    for i=1:n
        for j=1:n
        sim(i,j) = dot(unlabeledfeatures(i,:),unlabeledfeatures(j,:))/(norm(unlabeledfeatures(i,:)) * norm(unlabeledfeatures(j,:)));
        end
    end
   
    % information density
    for i=1:n
        ID(i) = SE(i) * (sum(sim(i,:))/n)^beta;
    end
    
    % select the instance with the least ID
    index = find(ID==min(ID));
    index = index(1);
end

