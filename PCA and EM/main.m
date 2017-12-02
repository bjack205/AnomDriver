examples = load('trainingdata.mat');
X_full = examples.X;
X = X_full(:,2:7);
features = examples.features;

%evaluate different reduced feature length
[m,n] = size(X);
k = [2:1:4];
m_pca = size(k,2);
X_pca = cell(1,m_pca);
for j=1:m_pca
    X_pca{j} = pca(X,k(j));
end

%% evaluate EM
eps = 1e-12;
iterations = 1;
classes = 3;
mu_pca = cell(1,size(k,2));
sigma_pca = cell(1,size(k,2));
%%
for j=1:m_pca
    [mu_pca{j}, sigma_pca{j}] = EM_mix_gauss(X_pca{j},classes,eps,iterations);
end

%% evaluate original examples
[mu_pca{end+1}, sigma_pca{end+1}] = EM_mix_gauss(X,classes,eps,iterations);
X_pca{end+1} = X;
%X_pca{1} = X_full(:,[5,6]);
%X_te = X_full(:,3:6);
%[mu_p, sigma_p] = EM_mix_gauss(X_te,classes,eps,iterations);

%% get atypical drivers (score examples)
th = 2e-9; %threshold
l_orig = get_anom(X,4,classes,th,sigma_pca,mu_pca);
anom_examples = X_full(l_orig);
uniq_anom_examples = unique(anom_examples);
size(uniq_anom_examples)

%%
th = 0.005;
m_pca = size(X_pca,2);
n_out = zeros(1,m_pca);
%labels - 2,3,4,5,6,6orig
anom = cell(1,m_pca);
anom_ind = cell(1,m_pca);
%classes = 4;
for j=1:m_pca
    l_ind = get_anom(X_pca{j},j,classes,th,sigma_pca,mu_pca);
    anom_ind{j} = l_ind;
    anom{j} = X_full(l_ind,:); %get ids
    n_out(j) = size(unique(X_full(l_ind)),1);
end

%% Plot number of offenders
figure()
subplot(1,3,1)
fea_num = {'2','3','4','baseline'};
% number of unique examples by vehicle id
num_ids = size(unique(X_full(:,1)),1);
a_num = n_out(n_out~=0);
a_num = a_num./num_ids*100;
%a_num(end+1) = n_out(5);
bar(a_num);
set(gca,'xticklabel',fea_num);
%plot(fea_num,n_out(1:5));
title('Anomalous drivers for different feature space sizes')%
xlabel('Feature Set Size')
ylabel('Percentage of drivers flagged anomalous')
%xlim([2,6]);
%set(gca,'XTick',[2:1:6]);
%% Get range of features
n_size = size(a_num,2); %number of feature space sizes to plot
%get std and mean for num of lane changes, avg vel, max vel, avg acc, and standard dev from lane centres
fea_des = 2:5;
anom_std = zeros(n_size,4);
anom_mean = zeros(n_size,4);
idx = 1;
for j=1:4
    temp = anom{j};
    anom_std(idx,:) = std(temp(:,2:5));
    anom_mean(idx,:) = mean(temp(:,2:5));
    idx = idx+1;
end
%% Plot range and max for feature spaces4
figure()
subplot(1,3,1)
%{
fea_num = {'2','3','4','6'};
a_num = n_out(1:3);
a_num(end+1) = n_out(5);
%}
bar(a_num);
set(gca,'xticklabel',fea_num);
%plot(fea_num,n_out(1:5));
title('Atypical drivers')
xlabel('Feature set size')
ylabel('Percentage of drivers which are atypical')
subplot(1,3,2)
fea_num = {'2','3','4','baseline'};
%a_num(end+1) = n_out(end);
bar(anom_std);
set(gca,'xticklabel',fea_num);
title('Atypical drivers: Standard deviation') %of each feature attribute for different feature space sizes
xlabel('Feature set size')
ylabel('Standard deviation of feature attributes')
legend('num. of lane changes','avg velocity','max velocity','avg acceleration','avg dev. from lane centers') 

% Plot max for feature spaces
subplot(1,3,3)
fea_num = {'2','3','4','baseline'};
%a_num(end+1) = n_out(end);
bar(anom_mean);
hold on
set(gca,'xticklabel',fea_num);
title('Atypical drivers: Mean') % of each feature attribute for different feature space sizes
xlabel('Feature set size')
ylabel('Mean value of feature attributes')
ylim([0 16])
%legend('num. of lane changes','avg velocity','max velocity','avg acceleration','avg deviation from lane centers')
%% get mean of normal drivers
test_mean = mean(X(~anom_ind{end},1:5));
test_std = std(X(~anom_ind{end},1:5));
%% Plot Guassian for 2D feature set
%plot_pca(X_pca{1},1,classes,sigma_pca,mu_pca);
figure()
plot(
