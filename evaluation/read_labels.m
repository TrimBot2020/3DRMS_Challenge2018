function def = read_labels(dir)
%READLABELS Read semantic shape labels and colors into handles struct
%           from yaml files in dir
%   labelNames
%   labelIDs
%   labelColors
%% read labels
def.labels = YAML.read(fullfile(dir, 'labels.yaml'));
def.colors = YAML.read(fullfile(dir, 'colors.yaml'));
groupNames = fieldnames(def.labels.Semantic);
id = 1;
for g = 1:length(groupNames)
  gn = groupNames{g};
  gel = def.labels.Semantic.(gn);
  if isstruct(gel)
    groupLabels = fieldnames(gel);
    for gi = 1:length(groupLabels)
      gl = groupLabels{gi};
      def.labelNames{id} = [gn '-' gl];
      def.labelIDs(id) = def.labels.Semantic.(gn).(gl);
      def.labelColors(id,1:3) = def.colors.Semantic.(gn).(gl);
      id = id + 1;
    end
  else
    def.labelNames{id} = gn;
    def.labelIDs(id) = def.labels.Semantic.(gn);
    def.labelColors(id,1:3) = def.colors.Semantic.(gn);
    id = id + 1;
  end
end
%% mapping
if isfield(def.labels,'Mapping')
  def.mapping = zeros(255,1);
  groupNames = fieldnames(def.labels.Mapping);
  for g = 1:length(groupNames)
    gn = groupNames{g};
    gel = def.labels.Mapping.(gn);
    if isstruct(gel)
      groupLabels = fieldnames(gel);
      for gi = 1:length(groupLabels)
        gl = groupLabels{gi};
        lmap = def.labels.Mapping.(gn).(gl);
        def.mapping(lmap(1)) = lmap(2);
      end
    end
  end
end