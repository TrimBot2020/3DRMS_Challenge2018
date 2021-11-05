function model = read_model(modelPath)
%% read mesh model
fprintf('Reading model %s ... ',modelPath); tic;
[tri, vtx, model.data, model.name] = ply_read(modelPath,'tri');
model.vtx = vtx';
model.tri = tri';
if isfield(model.data.vertex,'red')
model.vtxColor = [model.data.vertex.red model.data.vertex.green model.data.vertex.blue];
else
  model.vtxColor = [];
end
model.vtxLabels = []; %model.data.vertex.alpha;
model.triColor = [];
%% color point cloud matrix
%model.ptXcol = [model.vtx model.vtxColor];
model.ptXh = [model.vtx, ones(size(model.vtx,1),1)];
%model.ptBox = [min(model.vtx,[],1); max(model.vtx,[],1)];
toc;