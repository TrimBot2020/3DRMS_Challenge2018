function stats = eval_recon(subName, scene, accRatio, compThreshold, histBins, maxRange,type)
%% EVAL_RECON - evaluate accuracy and completeness of a model
% acc is distance d (in m) such that [accRatio]% of the reconstruction is within d of the ground truth mesh
% comp is the percent of points on the GTM that are within [compThreshold] mm of the reconstruction

filePath = sprintf('../results/%s/%s_%s',subName,subName,scene); % distances to GT

if ~exist([filePath '-acc.ply'],'file')
  %% compute distances using CloudCompare 2.10+ - https://www.cloudcompare.org/
  % linux: install using "sudo snap install cloudcompare --edge --classic"
  if strcmp(scene,'real')
    eval(sprintf('!./eval_real_%s.sh %s.ply %s',type,filePath,scene));
  else
    eval(sprintf('!./eval_synth_%s.sh %s.ply %s',type,filePath,scene));
  end
end

stats.accRatio = accRatio; %0.9;
stats.compThreshold = compThreshold; %0.1;
% histBins = 10;

%% read distances from CloudCompare pcls
compPcl = ply_read([filePath '-comp.ply']);
if strcmp(type,'mesh')
  compDist = abs(compPcl.vertex.('scalar_C2M_signed_distances'));
else
  compDist = abs(compPcl.vertex.('scalar_C2C_absolute_distances'));
end

accPcl = ply_read([filePath '-acc.ply']);
accDist = abs(accPcl.vertex.('scalar_C2C_absolute_distances'));

%% compute stats
stats.acc = quantile(accDist,accRatio);
stats.comp = mean(compDist<compThreshold);
stats.histBins = linspace(maxRange/histBins/2, maxRange-maxRange/histBins/2, histBins);
stats.histBins = maxRange*logspace(-2,0,histBins);
histComp = hist(compDist,stats.histBins);
stats.histComp = histComp/sum(histComp);
histAcc = hist(accDist,stats.histBins);
stats.histAcc = histAcc/sum(histAcc);

%% plot
figure('Name',subName);
subplot(2,2,1);
bar(stats.histBins,cumsum(stats.histComp));  title(sprintf('completeness: %.1f %%',stats.comp*100)); xlabel('m (GT to X)'); ylim([0 1]);
hold on; plot(compThreshold*[1 1],[0 1],'r-');
subplot(2,2,2);
bar(stats.histBins,cumsum(stats.histAcc));  title(sprintf('accuracy: %.3f m',stats.acc)); xlabel('m (X to GT)'); ylim([0 1]);
hold on; plot([0 maxRange],accRatio*[1 1],'r-');
try
  subplot(2,2,3); imshow(imread([filePath '-comp.png']));
  subplot(2,2,4); imshow(imread([filePath '-acc.png']));
catch
  warning('eval: missing pngs');
end

print([filePath '-geom.pdf'],'-dpdf','-bestfit');
