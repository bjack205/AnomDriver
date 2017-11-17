function [ mu_best, sigma_best ] = EM_mix_gauss( X,k,eps,iterations )
% Implementation of the EM algorithm to fit a mixture of Gaussians.

% X is all training examples (one training example per row). k is the
% number of Gaussians x is theorized to be drawn from. eps is the
% convergence criteria.
[m,n] = size(X);

% initialize worst case log likelihood
logL = -Inf;

for r = 1:iterations
    fprintf('Random Initialization: %i\n',r)
    
    % initialize k cluster centroids randomly from the data
    mu = datasample(X,k);

    % initialize covariance matrix for each cluster as covariance of all
    % training examples
    sigma = [];
    for j = 1:k
        sigma{j} = cov(X);
    end

    % initialize equal priors
    phi = ones(1,k)./k;

    % initialized weights: w_j = p(z = j| x)
    W = zeros(m,k);

    iter = 0;
    error = 1;
    logL_old = logL;
    
% ALGORITHM
    while error > eps
        %fprintf('Iteration: %d\n',iter);
        iter = iter + 1;

    % E-step
        p = zeros(m,k);
        pw = zeros(m,k);

        for j = 1:k
            p(:,j) = pdf_gaussian_multi(X,mu(j,:),sigma{j});
            pw(:,j) = p(:,j)*phi(j);
        end

        W = pw./repmat(sum(pw,2),1,k);

    % M-step
        mu_old = mu;

        for j = 1:k
            % recalculate priors
            phi(j) = mean(W(:,j),1);

            % recalculate means
            mu(j,:) = (W(:,j)'*X)./sum(W(:,j),1);

            sigma_k = zeros(n,n);

            for i = 1:m
                sigma_k = sigma_k + (W(i,j).*(X(i,:)-mu(j,:))'*(X(i,:)-mu(j,:)));
            end
            sigma{j} = sigma_k./sum(W(:,j));
        end
        error = sum((mu-mu_old).^2);
    end
    
    % calculate the log likelihood for the mixture of gaussians selected
    % the for loop is because W(i,j) may be zero, and that division breaks
    % logL
    logL = 0;
    %for i = 1:m
        for j = 1:k
            %if W(i,j) ~= 0
                logL = logL + sum(W(:,j).*(log(pdf_gaussian_multi(X,mu(j,:),sigma{j})) - log(W(:,j))));
            %end
        end
    %end
    %fprintf('logL: %.5d\n',logL)

    if isnan(logL)
        logL = logL_old;
        fprintf('PROBLEM\n')
        %break
    end
    
    %update best clustering
    if logL >= logL_old
        fprintf('-Improvement made\n')
        mu_best = mu;
        for j = 1:k
            sigma_best{j} = sigma{j};
        end
    end    
end 

end

