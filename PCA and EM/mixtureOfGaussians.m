% Taylor Howell
% EM algorithm to fit mixture of Gaussians
% 11-14-2017

clear;clc;close all;
n = 2; % dimension of each training example
k = 4; % number of clusters

%% Generate k 2-dimensional Gaussians and sample from them to create training examples
examples = 150;
mu_initial = [];
sigma_initial = [];
Xi = [];
X = [];
for i = 1:k
    mu_initial{i} = 5*randn(1,n);
        d = 5*rand(n,1); % The diagonal values
        t = triu(bsxfun(@min,d,d.').*rand(n),1); % The upper trianglar random values
        M = diag(d)+t+t.'; % Put them together in a symmetric matrix
    sigma_initial{i} = M;
    Xi{i} = randn(examples, n) * chol(sigma_initial{i}) + repmat(mu_initial{i}, examples, 1);
    X = cat(1,X,Xi{i});
end
examples = load('trainingdata.mat');
X_full = examples.X;
X = X_full(:,[2,3]);

%% Run EM

eps = 1e-12;
iterations = 7;
[mu, sigma] = EM_mix_gauss(X,k,eps,iterations);

%% Visualize Mixture of Gaussians
gridSize = 100;
u = linspace(-10, 10, gridSize);
[A B] = meshgrid(u, u);
gridX = [A(:), B(:)];

figure
subplot(1,2,1)
hold on;
  
for j = 1:k
    % plot raw data
    plot(Xi{j}(:, 1), Xi{j}(:, 2), 'o');
    % plot contour from know distributions
    z = pdf_gaussian_multi(gridX, mu_initial{j}, sigma_initial{j});
    contour(u, u, reshape(z, gridSize, gridSize),'k');
end
title('Fit from know distributions')
axis square

subplot(1,2,2)
hold on;
for j = 1:k
    % plot raw data
    plot(X(:, 1), X(:, 2), 'o');
end
for j = 1:k
    % plot contour from know distributions
    z = pdf_gaussian_multi(gridX,mu(j,:), sigma{j});
    contour(u, u, reshape(z, gridSize, gridSize),'k');
end
title('Fitted mixture of Gaussians')
axis square

%% Run EM multiple times on same training set
% figure
% for i = 1:4
%     [mu, sigma] = EM_mix_gauss(X,k,eps,iterations);
%     subplot(2,2,i)
%     hold on;
%     for j = 1:k
%         % plot raw data
%         plot(Xi{j}(:, 1), Xi{j}(:, 2), 'o');
%     end
%     for j = 1:k
%         % plot contour from know distributions
%         z = pdf_gaussian_multi(gridX,mu(j,:), sigma{j});
%         contour(u, u, reshape(z, gridSize, gridSize),'k');
%     end
%     title('Different EM initializations')
%     axis square 
% end