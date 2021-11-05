%% evaluate semantics
addpath('render','toolbox');
addpath 'export_fig'; warning off all;
set(0,'defaultfigurecolor',[1 1 1]);
set(0,'defaultAxesFontSize',14);
%% options
resDir = '../results';
% submissions = {'snbasic-frNone','snbasic-frNone-skip','snfull-frImgNet','snfull-frNone-real','snfull-skip-frImgNet'};  % each has separate folder
% subnames = {'SegNet-basic','SegNet-basic-skip','SegNet-full-ImgNet','SegNet-full-real','SegNet-full-ImgNet-skip'};

%submissions = {'HAB','dtis','snfull-frImgNet'};  % each has separate folder
%subnames = {'HAB','DTIS','SegNet'};

submissions = {'dtis','snfull-frImgNet-ft-real'};  % each has separate folder
subnames = {'DTIS','SegNet'};

loadModel = false;
loadMat = true;

%%
if 1
  resName = 'real';
  modelName = 'real';
  scenes = {'test_around_garden' };
  dataPath = '../gt';
  evalFrames = 140:10:1480;
  evalCams = [0 2];
  camType = 'uvc_camera_cam';
else
  resName = 'test';
  modelName = '0288';
  scenes = { 'clear_0288','cloudy_0288','overcast_0288','sunset_0288','twilight_0288'};
  dataPath = '../gt';
  evalFrames = 1:100;
  evalCams = 0:2:9;
  camType = 'vcam';
end

%% read label def
def = read_labels('../calibration');
labelCount = length(def.labelNames);
figure(1);
astats.acc = zeros(length(submissions),length(scenes));
astats.conf = zeros(labelCount-1,labelCount-1,length(submissions));
%%
cols = round(def.labelColors*255);
for c = 1:labelCount
fprintf("<step r=""%d"" g=""%d"" b=""%d"" pos=""%d""/>\n",cols(c,1),cols(c,2),cols(c,3),c);
end
%% subs
for m = 1:length(submissions)
  subName = submissions{m};
  subTitle = subnames{m};
  
  subfn = sprintf('%s/%s/%s-sem-all',resDir,subName,resName);
  mstatfn = [subfn '-stats.mat'];
  if 0 % loadMat && exist(mstatfn,'file')
    mstats = load(mstatfn);
  else
    mstats.conf = zeros(labelCount-1,labelCount-1,length(scenes));
    mstats.acc = zeros(length(scenes),length(evalCams));
    %% scenes
    for s = 1:length(scenes)
      scene = scenes{s};
      sceneName = strrep(scene,'_','-');
      modelPath = sprintf('%s/%s/%s_%s.ply',resDir,subName,subName,modelName);
      resfn = sprintf('%s/%s/%s-sem',resDir,subName,scene);
      statfn = [resfn '-stats.mat'];
      if loadMat && exist(statfn,'file')
        stats = load(statfn);
      else
        if loadModel
          %% read models
          %model = read_model(modelPath);
          figure(101); clf; trimesh(model.tri,model.vtx(:,1),model.vtx(:,2),model.vtx(:,3)); axis equal; title('submitted');
        end
        %% project to images
        stats.conf = zeros(labelCount-1,labelCount-1,length(evalCams));
        stats.acc = zeros(length(evalCams),length(evalFrames));
        for c = 1:length(evalCams)
          %% select camera
          idCam = evalCams(c);
          acc = zeros(length(evalFrames),1);
          conf = zeros(labelCount-1,labelCount-1,length(evalFrames));
          cdir = sprintf('%s/%s/%s',resDir,subName,scene);
          mkdir(cdir);
%           vid = VideoWriter(sprintf('%s/sem-vid-cam%d.avi',cdir,idCam));
%           vid.FrameRate = 3;
%           vid.Quality = 100;
%          open(vid);
          for i = 1:length(evalFrames)
            %% select frame
            idFrame = evalFrames(i);
            basePath = sprintf('%s/%s/%s_%d/%s_%d_f%05d',dataPath,scene,camType,idCam,camType,idCam,idFrame);
            txtPath = [basePath '_cam.txt'];
            clsPath = sprintf('%s/%s/%s/%s_%d/%s_%d_f%05d_undist.png',resDir,subName,scene,camType,idCam,camType,idCam,idFrame);
            if exist(txtPath,'file')
              %% read from colmap txt
              txtCam = load(txtPath);
              cam.f = txtCam(1:2); % fx fy
              cam.c = txtCam(3:4); % cx cy
              cam.q = txtCam(5:8); % qw qx qy qz
              cam.t = txtCam(9:11); % tx ty tz
              cam.resolution = 2*cam.c; % [752, 480];
              
              cam.R = quat2rotm(cam.q);
              cam.K = eye(3);
              cam.K(1,1) = cam.f(1);
              cam.K(2,2) = cam.f(2);
              cam.K(1,3) = cam.c(1);
              cam.K(2,3) = cam.c(2);
              fprintf('Cam pose loaded from %s\n',txtPath);
              
              %% mesh projection
              camParsMesh{1} = struct('TcV', cam.t, ...
                'RcM', cam.R, ...
                'fcV', [cam.K(1,1); cam.K(2,2)], ...
                'ccV', [cam.K(1,3); cam.K(2,3)], ...
                'imSizeV', [cam.resolution(2); cam.resolution(1)]);
              projZrange = [1e-3; 2000];
              %       %% gt depths
              %       [projDmap, cx] = RenderDepthMesh(gtmodel.tri, gtmodel.ptXh(:,1:3), camParsMesh{1}, ...
              %         [cam.resolution(2); cam.resolution(1)], projZrange, 1, 0);
              
              if 0 %exist(clsPath,'file')
                %% load anot from file
                [imgAnot,cmap] = imread(clsPath);
                
                %% remap to match colors, remap(2) = 9; % 1->8
                cfl = zeros(10);
                anotOrig = imgAnot;
                imgAnot(:) = 0;
                for lm = 1:10
                  for la = 1:10
                    cfl(lm,la) = mean(abs(def.labelColors(la,:)-cmap(lm,:)));
                  end
                  [remin(lm),remap(lm)] = min(cfl(lm,:),[],2);
                  imgAnot(anotOrig(:)==lm-1) = remap(lm)-1;
                end
                %figure; imagesc(cfl); colormap hot;
                [cremin,cremap] = min(cfl,[],2);
                imgAnot = flip(imgAnot,2);
              else
                projColor = RenderColorMesh(model.tri, model.ptXh(:,1:3), single(model.vtxColor)/255, ...
                  camParsMesh{1}, [cam.resolution(2); cam.resolution(1)], projZrange, 1);
                %% tranform color to labels
                projColor = uint8(projColor);
                imgAnot = uint8(rgbmapind(projColor,uint8(def.labelColors*255))) - 1;
                clsPath = strrep(clsPath,'_undist.png','_proj.png');
                imwrite(imgAnot,def.labelColors,clsPath);
              end
              
              imgAnot(imgAnot(:)==0) = 9;
            else
              stats.acc(c,i) = nan;
              continue;
            end
            %% load gt anot
            gtAnot = imread([basePath '_gtr.png']);
            gtAnot(gtAnot(:)>10) = 9;
            gtAnotTest = gtAnot;
            gtValid = true(size(gtAnot));
            %     gtValid = (projDmap<1);
            %     gtValid = imdilate(gtValid,strel('diamond',3));true
            gtValid(gtAnot(:)==0) = 0;
            gtAnotTest(gtValid==0) = 0;
            gtDiff = double(gtAnotTest~=imgAnot);
            gtDiff(gtAnotTest==0) = -1;
            gtDiff(gtAnot==9)= 0;
            %% stats
            stats.acc(c,i) = sum(gtDiff(:)==0) / sum(gtDiff(:)>=0);
            conf(:,:,i) = confMatrix(gtAnotTest(gtValid(:)),imgAnot(gtValid(:)),labelCount-1);
            %figure(103);
            %confMatrixShow(conf(:,:,i), def.labelNames(2:end), {'FontSize',12}, 2, 1 ); colormap hot; ylabel('GT');
            
            %% err
            
            errPath = strrep(clsPath,'.png','_err.png');
            errImg = gtDiff+2;
            errMap = [0 0 0; 0.5 0.5 0.5; 1 0 0];
            imwrite(errImg,errMap,errPath);
            
%             %% plot
%             figure(1); clf;
%             subplot(2,2,1); imshow(imgAnot,def.labelColors); axis image; title(sprintf('cam %d frame %d: submitted labels',idCam,idFrame));
%             subplot(2,2,2); % imagesc(projDmap); axis image; title('gt depths');
%             imagesc(max(conf(:))-conf(:,:,i)); axis image; colormap hot; ylabel('GT'); title('confusion matrix');
%             subplot(2,2,3); imshow(gtAnotTest,def.labelColors); axis image; title('gt labels (masked)');
%             subplot(2,2,4); imshow(errImg,errMap); axis image; title(sprintf('error mask (accuracy = %.03f)',stats.acc(c,i))); %colormap jet;
%             drawnow;
%   %          writeVideo(vid,getframe(gcf));true
            
          end
%          close(vid);
          %% camera totals
          camconf = sum(conf,3);
          stats.conf(:,:,c) = sum(camconf,3);
          stats.cacc(c) = sum(diag(camconf))/sum(camconf(:));
          
        end
        %% scene totals
        stats.tconf = sum(stats.conf,3);
        stats.tacc = sum(diag(stats.tconf))/sum(stats.tconf(:));
        disp(stats.tacc);
        save(statfn,'-struct','stats');
      end
      %
      figure(105);
      plot(stats.acc','*'); ylabel 'accuracy'; grid on; xlabel('frame');
      title(sprintf('%s[%s]: label accuracy = %.3f',subName,sceneName,stats.tacc)); drawnow;
      export_fig([resfn '-acc.pdf'],'-pdf');
      %
      figure(106);
      confMatrixShow(stats.tconf, def.labelNames(2:end), {'FontSize',12}, 2, 1 );
      colormap hot; ylabel('GT');
      title(sprintf('%s[%s]: label accuracy = %.3f',subName,sceneName,stats.tacc)); drawnow;
      export_fig([resfn '-conf.pdf'],'-pdf');
      %% main stats
      mstats.acc(s,:) = median(stats.acc,2);
      mstats.conf(:,:,s) = stats.tconf;
    end
    
    %% submission totals
    mstats.name = subTitle;
    mstats.tconf = sum(mstats.conf,3);
    mstats.tacc = sum(diag(mstats.tconf))/sum(mstats.conf(:));
    disp(mstats);
    save(mstatfn,'-struct','mstats');
  end
  %%
  astats.acc(m,:) = median(mstats.acc,2);
  astats.conf(:,:,m) = mstats.tconf;
  %
  figure(105);
  plot(mstats.acc','*'); ylabel 'accuracy'; grid on; xlabel('camera');
  title(sprintf('%s[%s]: label accuracy = %.3f',subTitle,resName,mstats.tacc)); drawnow;
  export_fig([subfn '-acc.pdf'],'-pdf');
  %
  figure(106);
  confMatrixShow(mstats.tconf, def.labelNames(2:end), {'FontSize',12}, 2, 1 );
  colormap hot; ylabel('GT');
  title(sprintf('%s[%s]: label accuracy = %.3f',subTitle,resName,mstats.tacc)); drawnow;
  export_fig([subfn '-conf.pdf'],'-pdf');
  
end
%% summary
astats.cacc = median(astats.acc,2);
astats.tconf = sum(astats.conf,3);
astats.tacc = sum(diag(astats.tconf))/sum(astats.conf(:));
astats.name = resName;
save(sprintf('%s/sem-%s-stats.mat',resDir,resName),'-struct','astats');
%
figure(105);
if size(astats.acc,2)==1
  bar([astats.acc nan(size(astats.acc,1),1)]' );
  xlim([0.5 1.5]);
else
  bar(astats.acc');
end
%
subres = {};
for s=1:length(subnames)
  subres{s} = sprintf('%s [%.3g]',subnames{s},astats.cacc(s));
end
ylabel 'accuracy'; grid on; xlabel('scene');
title(sprintf('all[%s]: semantic pixelwise accuracy',resName));
%title(sprintf('all[%s]: avg pixelwise accuracy = %.3f',resName,astats.tacc));
legend(subres,'Location','southeast');  drawnow;
export_fig(sprintf('%s/sem-%s-acc.pdf',resDir,resName),'-pdf');
%
figure(106);
confMatrixShow(astats.tconf, def.labelNames(2:end), {'FontSize',12}, 2, 1 );
colormap hot; ylabel('GT');
title(sprintf('all[%s]: semantic pixelwise accuracy = %.3f',resName,astats.tacc)); drawnow;
export_fig(sprintf('%s/sem-%s-conf.pdf',resDir,resName),'-pdf');



