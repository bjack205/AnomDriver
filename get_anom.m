function [log_ind] = get_anom(X,ind,class,epsilon,sigma_pca,mu_pca)
[m,n] = size(X);
p = zeros(m,class);
sigma = sigma_pca{ind};
mu = mu_pca{ind};
for j=1:class
    B = X - repmat(mu(j,:),m,1);
    p(:,j) = 1/((2*pi)^(n/2)*det(sigma{j})^0.5)*exp(-0.5*sum((B/sigma{j}.*B),2));
end
p(20,:);

A = p<epsilon;
%v = p==0;
count = sum(A,2);
log_ind = count==class;