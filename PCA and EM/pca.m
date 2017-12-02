function [example_pca] = pca(X,k)
%{
traj = importdata('trajectories-0750am-0805am.txt');
X = traj(:,6);
% x-5 y-6 len-9 wid-10 vel-12 acc-13 spaci-17 headway-18

ID = unique(traj(:,1));
m = 20;
n = 2;
v = [5,6,9,10,12,13,17,18];
examples = zeros(m,n);
idx=1;
for i=1:m
    examples(idx,:) = mean(traj(traj(:,1)==ID(i),[12,13]),1);
    idx = idx + 1;
end
%}
 [m,n] = size(X);

% normalize data set
mu = sum(X,1)./m;
%size(mu)
example_n = X - repmat(mu,m,1);
cov_sigma = sum(X.^2,1)./m;
cov_sigma = sqrt(cov_sigma);
example_n = example_n ./ repmat(cov_sigma,m,1);

%{
subplot(3,1,1);
plot(X(:,1),X(:,2),'o');
title('original traj');
xlabel('velocity');
ylabel('acceleration');

% after normalization
subplot(3,1,2);
plot(example_n(:,1),example_n(:,2),'o');
title('normalized data');
%}

% get covaraince
covariance_mat = cov(example_n);

%get eigen vectors
[V,D] = eig(covariance_mat);
D = diag(D);

%select top k vectors
[D_sort,I] = sort(D,'descend');
max_eigen = V(:,I(1:k));

% get projection onto eigen vectors
%subplot(3,1,3);
example_pca = example_n*max_eigen;
%stem(example_pca, 'DisplayName', 'Compressed features', 'YDataSource',...
%'example_pca');
%plot(1:1:size(example_pca,1),example_pca(:,1),'o');
%title('PCA reduction');

