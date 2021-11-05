%% evaluate 3DRMS workshop challenge submissions

%%
addpath 'export_fig'; warning off all;
set(0,'defaultfigurecolor',[1 1 1]);
set(0,'defaultAxesFontSize',18);
%%
resDir = '../results';
resType = 'mesh'; % 'pcl'
% submissions = {'HAB'};  % each has separate folder
% subnames = {'HAB'};
submissions = {'HAB','lapsi4','lapsi360','dtis','colmap'};  % each has separate folder
subnames = {'HAB','lapsi4','lapsi360','DTIS','Colmap'};
% submissions = {'colmap'};  % each has separate folder
% subnames = {'Colmap'};
%%
% resName = 'all';
% scenes = { '0001', '0128', '0160', '0224', '0288', 'real' }; 
%%
% resName = 'train';
% scenes = { '0001', '0128', '0160', '0224' }; 
%%
resName = 'realp';
scenes = { 'real'}; %,  };
submissions = {'proc3d'};  % each has separate folder
subnames = {'PointFusion'};

%%
% resName = 'real';
% scenes = { 'real'}; %,  };
%%
accRatio = 0.9;
compThreshold = 0.05; % meters
maxRange = 0.3;
histBins = 20;

%% submissions
stall = cell(length(submissions),length(scenes));
for i = 1:length(submissions)
  for s = 1:length(scenes)
    %% scene
    subName = submissions{i};
    scene = scenes{s};
    fprintf('eval: %s ...',subName);
    sfn = sprintf('%s/%s/%s_%s-results.mat',resDir, subName,subName,scene);
    if exist(sfn,'file')
      fprintf('loaded from %s\n',sfn);
      stats = load(sfn);
    else
      tic;
      stats = eval_recon(subName, scene, accRatio, compThreshold, histBins, maxRange,resType);
      save(sfn,'-struct','stats');
      toc;
    end
    disp(stats);
    stall{i,s} = stats;
  end
end

%% summary
allAcc = zeros(length(submissions)*length(scenes),histBins);
allComp = zeros(length(submissions)*length(scenes),histBins);
legComp = {};
legAcc = {};
jj = 1;
for i = 1:length(submissions)
  for s = 1:length(scenes)
    allAcc(jj,:) = cumsum(stall{i,s}.histAcc);
    allComp(jj,:) = cumsum(stall{i,s}.histComp);
    
    legAcc{jj} = sprintf('%s-%s (%.3f m)', subnames{i}, scenes{s}, stall{i,s}.acc);
    legComp{jj} = sprintf('%s-%s (%.1f%%)', subnames{i}, scenes{s}, 100*stall{i,s}.comp);
    jj = jj+1;
  end
end

%% comp
figure(11); clf; set(gcf,'Name','Completeness');
plot(stats.histBins,allComp','LineWidth',2);  title(sprintf('%s: completeness (at %.0fcm)',resName,100*compThreshold)); xlabel('m (GT to X)'); ylim([0 1]);
hold on; plot(compThreshold*[1 1],[0 1],'r-'); legend(legComp,'Location','southeast'); grid on;
export_fig([resDir '/' resName '-stats-comp.pdf'],'-pdf');

%% acc
figure(12); clf; set(gcf,'Name','Accuracy');
plot(stats.histBins,allAcc','LineWidth',2);  title(sprintf('%s: accuracy (at %.0f%%)',resName,100*accRatio)); xlabel('m (X to GT)');  ylim([0 1]);
hold on; plot([0 maxRange],accRatio*[1 1],'r-'); legend(legAcc,'Location','southeast'); grid on;
export_fig([resDir '/' resName '-stats-acc.pdf'],'-pdf');
