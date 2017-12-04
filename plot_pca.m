function [] = plot_pca(X_pca,ind,classes,sigma_pca,mu_pca)
example_pca = X_pca;
figure()
stem(example_pca, 'DisplayName', 'Compressed features', 'YDataSource',...
 'example_pca');
plot(X_pca(:,1),X_pca(:,2),'o');
hold on
title('PCA reduction');

gridSize = 100;
u = linspace(-5, 5, gridSize);
[A B] = meshgrid(u, u);
gridX = [A(:), B(:)];

hold on;


sigma = sigma_pca{ind};
mu = mu_pca{ind};

for j = 1:classes
    % plot raw data
    % plot contour from know distributions
    z = pdf_gaussian_multi(gridX, mu(j,:), sigma{j});
    contour(u, u, reshape(z, gridSize, gridSize),'k');
end
title('Fit from know distributions')
axis square