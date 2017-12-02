function [ p ] = pdf_gaussian_multi(X,mu,sigma)
% PDF for multivariate Gaussian
% mu is broadcast in order to evaluate all m training examples from X [m
% examples, each with n features)

[m,n] = size(X);
A = X-repmat(mu,m,1);
%p = 1/((2*pi)^(n/2)*det(sigma)^(1/2))*exp(-0.5*sum(((A*inv(sigma)).*A)',1))';
p = 1/((2*pi)^(n/2)*det(sigma)^0.5)*exp(-0.5*sum(((A*inv(sigma)).*A),2));
end

