clear;
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
iterations = 2;
classes = 4;
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
%{
th = 2e-9; %threshold
l_orig = get_anom(X,4,classes,th,sigma_pca,mu_pca);
anom_examples = X_full(l_orig);
uniq_anom_examples = unique(anom_examples);
size(uniq_anom_examples)
%}

%%
th = 0.0025;
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
%% Plot histogram
ctitle = {'num of lane changes', 'avg velocity', 'max velocity', 'avg acceleration'};
for i=2:5
figure()
subplot(2,1,1)
f_sz1 = anom{1};
f_sz6 = anom{4};
h1 = histogram(f_sz1(:,i));
hold on
h3 = histogram(X_full(:,i));
title(strcat({'Histogram of '},ctitle{i-1}))
legend('anomalous drivers with pca', 'all drivers')
h1.Normalization = 'probability';
h1.BinWidth = 0.25;
h3.Normalization = 'probability';
h3.BinWidth = 0.25;
subplot(2,1,2)
h2 = histogram(f_sz6(:,i));
hold on
h3 = histogram(X_full(:,i));
h2.Normalization = 'probability';
h2.BinWidth = 0.25;
h3.Normalization = 'probability';
h3.BinWidth = 0.25;
legend('anomalous drivers without pca','all drivers')
end
%% max velocity
for i=2:5
subplot(2,2,i-1)
pdf1 = fitdist(f_sz1(:,i),'kernel');
pdf2 = fitdist(f_sz1(:,i),'kernel','Bandwidth',1);
pdf3 = fitdist(f_sz1(:,i),'kernel','Bandwidth',5);

x = -10:1:40;
y1 = pdf(pdf1,x);
y2 = pdf(pdf2,x);
y3 = pdf(pdf3,x);
plot(x,y1,'Color','r','LineStyle','-')
hold on
plot(x,y2,'Color','k','LineStyle',':')
hold on
plot(x,y3,'Color','b','LineStyle','--')
title(strcat({'Distribution of '},ctitle{i-1}))
legend({'Bandwidth = Default','Bandwidth = 1', 'Bandwidth = 5'})
hold off
end
%% create distribution for simulator
feature_dist = get_distribution(f_sz1);
%% Plot number of offenders
figure()
fea_num = {'2','3','4','baseline'};
% number of unique examples by vehicle id
num_ids = size(unique(X_full(:,1)),1);
a_num = n_out(n_out~=0);
a_num = a_num./num_ids*100;
bar(a_num);
set(gca,'xticklabel',fea_num);
title('Anomalous drivers for different feature space sizes')
xlabel('Feature Set Size')
ylabel('Percentage of drivers flagged anomalous')