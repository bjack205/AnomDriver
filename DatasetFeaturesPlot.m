figure(1);clf;
colormap jet
col = hsv(6);
for i = 1:6
    subplot(3,2,i)
    histogram(X(:,i+1),'FaceColor',col(i,:))
    if isempty(features(i+1).units)
        label = features(i+1).names;
    else
        label = sprintf('%s (%s)',features(i+1).names,features(i+1).units);
    end
    xlabel(label,'interpreter','none')
end
