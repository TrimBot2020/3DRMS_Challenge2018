function [ ind ] = rgbmapind( rgb, cmap )
%RGBMAPIND Convert color image exactly to given colormap 
%   rgb ... color image (uint8)
%   cmap ... colormap (uint8)
rgb = uint32(rgb);
cmap = uint32(cmap);
srgb = rgb(:,:,1) + 256*rgb(:,:,2) + 256^2 * rgb(:,:,3);
smap = cmap(:,1) + 256*cmap(:,2) + 256^2 * cmap(:,3);
if 0 % jm fix
  smap(smap==230) = 229;
  smap(smap==32845) = 32588;
  smap(smap==32896) = 32639;
  smap(smap==1749837) = 1684044;
  smap(smap==11776768) = 11710976;
  smap(smap==15086387) = 15020851;
  smap(smap==15125683) = 15060146;
end
%%
ind = zeros(size(srgb,1),size(srgb,2),'uint16');
for i = 1:length(smap)
  ind(srgb==smap(i)) = i;  
end

