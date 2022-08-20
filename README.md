# 3D Reconstruction meets Semantics 

Part of the ECCV 2018 workshop [3D Reconstruction meets Semantics](http://trimbot2020.webhosting.rug.nl/events/3drms/) was a challenge on combining 3D and semantic information in complex scenes. 
To this end, a challenging outdoor dataset, captured by a robot driving through a semantically-rich garden that contains fine geometric details, is released. 
A multi-camera rig is mounted on top of the robot, enabling the use of both stereo and motion stereo information. 
Precise ground truth for the 3D structure of the garden has been obtained with a laser scanner and accurate pose estimates for the robot are available as well. 
Ground truth semantic labels and ground truth depth from a laser scan will be used for benchmarking the quality of the 3D reconstructions.



## Reconstruction Challenge
Given a set of images and their known camera poses, the goal of the challenge is to create a semantically annotated 3D model of the scene. 
To this end, it will be necessary to compute depth maps for the images and then fuse them together (potentially while incorporating information from the semantics) into a single 3D model.

We provide the following data for the challenge:
* A set of synthetic training sequences consisting of
  * calibrated images with their camera poses,
  * ground truth semantic annotations for a subset of these images,
  * a semantically annotated 3D point cloud depicting the area of the training sequence.
* A set of synthetic testing sequences consisting of calibrated images with their camera poses.
* A set of real validation sequences consisting of calibrated images with their camera poses.

For a detailed discussion of the workshop challenge, please read our [ECCV paper](http://openaccess.thecvf.com/content_ECCVW_2018/papers/11131/Tylecek_The_Second_Workshop_on_3D_Reconstruction_Meets_Semantics_Challenge_Results_ECCVW_2018_paper.pdf)

## Data

### Download

Challenge dataset archives are hosted [here](https://homepages.inf.ed.ac.uk/rbf/TrimBot2020git/public/).
Please use [`download.sh`](https://github.com/TrimBot2020/3DRMS_Challenge2017/blob/master/download.sh) script to retrieve training and test data (or see the script for manual download steps).

### Semantic Labels and Calibration

* File [`labels.yaml`](https://github.com/TrimBot2020/3DRMS_Challenge2018/blob/master/calibration/labels.yaml) - semantic label definition list
* File [`colors.yaml`](https://github.com/TrimBot2020/3DRMS_Challenge2018/blob/master/calibration/colors.yaml) - label color definition (for display)
* File [`calibration/camchain-DDDD.yaml`](https://github.com/TrimBot2020/3DRMS_Challenge2018/blob/master/calibration/camchain-2017-05-16-09-53-50.yaml) - camera rig calibration (for real data), [Kalibr format](https://github.com/ethz-asl/kalibr/wiki/yaml-formats)

### Training (Synthetic data)

| Sequence | 0001 | 0128 | 0160 | 0224 | 
| -------- | ------ | ----- | ----- | ----- | 
| clear   |  1000  | 1000 | 1000 | 1000 |
| cloudy  |  1000  | 1000 | 1000 | 1000 |
| overcast  | 1000  | 1000 | 1000 | 1000 |
| sunset |     1000  | 1000 | 1000 | 1000 |
| twilight  |  1000  | 1000 | 1000 | 1000 |
| _Total_        | 5000 | 5000 |  5000 | 5000 |
| _Stereo pairs_ | 2500 | 2500 |  2500 | 2500 |


Total 20k images / 10k annotated stereo pairs / 25 GB

* File `model_RRRR_SSSS.ply` - point cloud of scene SSSS with semantic labels (field `scalar_s`) at resolution RRRR
* Folders `EEEE_SSSS` - sequences rendered from scene SSSS in environment EEEE
* Subfolders `vcam_X`
    * Files `vcam_X_fXXXXX_gtr.png` - GT annotation with label set IDs (indexed bitmap)
    * Files `vcam_X_fXXXXX_undist.png` - color image (RGB, undistorted)
    * Files `vcam_X_fXXXXX_over.png` - overlay of annotation over greyscale image (for display)
    * Files `vcam_X_fXXXXX_cam.txt` - camera parameters (f,c,q,t)
    * Files `vcam_X_fXXXXX_dmap.bin` - depth map (binary matrix with image dimensions, single (32-bit) float [IEEE Big-Endian format](https://en.wikipedia.org/wiki/Double-precision_floating-point_format#Endianness))
    * Files `vcam_X_fXXXXX_dmap.png` - depth map (visualization)

#### Depth data

Matlab code to read `_dmap.bin` files:
```matlab
fd = fopen('training/clear_0001/vcam_0/vcam_0_f00001_dmap.bin','r');
A = fread(fd,[480 640],'single','ieee-be');
fclose(fd);
```
Python:
```python
import numpy as np
with open('training/clear_0001/vcam_0/vcam_0_f00001_dmap.bin', 'rb') as f:
    x = np.fromfile(f, dtype='>f4', sep='')
    a = np.reshape(x, [480, 640], order='F')
```

#### Cameras

There are five camera pairs arranged in a pentagonal rig. The stereo pairs are `cam_0/cam_1`, `cam_2/cam_3`, `cam_4/cam_5`, `cam_6/cam_7`, `cam_8/cam_9`. 

The pose format is `fx fy cx cy qw qx qy qz tx ty tz`, where `f` is focal length in pixels `c` centre point in pixels, `q` is the quaternion denoting the camera orientation and `t` is the camera translation. 
The transformation from world to camera coordinates is given as `[R(q)|t]`, where `R(q)` is the rotation matrix corresponding to quaternion `q`.

The poses and are also rendered in PLY files, single environments in `cams_EEEE_SSSS_fXXXX.ply` and all jointly in `cams_all_SSSS_fXXXX.ply`. 
Points correspond to camera centers (inner circle of the rig) and viewing direction (outer circle).  

### Testing (Synthetic data)

| Sequence | frames | 
| -------- | ------ | 
| clear_0288  |  1000  | 
| cloudy_0288  |  1000  | 
| overcast_0288  |  1000 | 
| sunset_0288  |  1000 | 
| twilight_0288  |  1000 | 
| _Total_ | 5000 | 
| _Stereo pairs_ | 2500 |

Total 2 GB.

* Folders `EEEE_SSSS` - sequences rendered from scene SSSS in environment EEEE
  * Subfolders `vcam_X`
    * Files `vcam_X_fXXXXX_undist.png` - color image (RGB, undistorted)
    * Files `vcam_X_fXXXXX_cam.txt` - camera parameters (f,c,q,t)


### Validation (Real data)

| Sequence | cameras | range | frames |
| -------- | ------- | ------ | ------- | 
| test_around_garden  | cam_0, cam_1, cam_2, cam_3   | 140:10:1480 | 268 | 

* Subfolders `uvc_camera_cam_X`
    * Files `uvc_camera_cam_X_fXXXXX_undist.png` - undistorted color image (RGB)
    * Files `uvc_camera_cam_X_fXXXXX_cam.txt` - camera parameters (f,c,q,t)
    * Cameras `cam_0` and `cam_2` color
    * Cameras `cam_1` and `cam_3` greyscale

### GT for testing and validation

Data used for evaluation are added separately to `gt` folder. The folder and file structure is the same as for training.

* Subfolder `test_around_garden` (real data)
  * For `cam_1` and `cam_3` there is no annotation provided, ie. _gtr are missing

## Evaluation

We will evaluate the following measures:
* Reconstruction accuracy in % for a set of distance thresholds (similar to [1,2])
* Reconstruction completeness in % for a set of distance thresholds (similar to [1,2])
* Semantic quality in % of the triangles that are correctly labeled.

We will use distance thresholds of 1cm, 2cm, 3cm, 5cm, and 10cm. 

### Results

We include results produced by our baseline methods in `results` folder.

Reconstruction: COLMAP [3] each test sequence separately and all merged with GT distance computed.

Semantic segmentation: SegNet [TBA]

Recommended viewer: [CloudCompare](http://www.cloudcompare.org/) - turn off normals to see scalar fields properly

#### References

* [1] Seitz et al., A Comparison and Evaluation of Multi-View Stereo Reconstruction Algorithms, CVPR 2006
* [2] Schöps et al., A Multi-View Stereo Benchmark with High-Resolution Images and Multi-Camera Videos, CVPR 2017
* [3] Schönberger et al. Structure-from-motion revisited, CVPR 2016.


## Submission Categories

This challenge accepted submissions in several categories: semantics and geometry, either joint or separate. 
For example, if you have a pipeline that first computes semantics and geometry independently and then fuses them, we can compare how the fused result improved accuracy.

Once you have created the results in one or more categories below, please follow [instructions on the website](http://trimbot2020.webhosting.rug.nl/events/3drms/challenge/) to submit them.
### A. Semantic mesh

In order to submit to the challenge, please create a semantically annotated 3D triangle mesh from the test sequence and validation sequence. 
* The mesh should be stored in the [PLY text format](http://paulbourke.net/dataformats/ply/). 
* The file should store for each triangle a color corresponding to the triangle’s semantic class (see the [`calibrations/colors.yaml`](https://github.com/TrimBot2020/3DRMS_Challenge2018/blob/master/calibration/colors.yaml) file for the mapping between semantic classes and colors). 
  * Semantic labels 'Unknown' and 'Background' are only for 2D images, and should not be present in the submitted 3D mesh, ie. only values 1-8 are valid.

### B. Geometric Mesh
Same as above, but PLY mesh without semantic annotations.

### C. Semantic Image Annotations
Create a set of semantic image annotations for all views in the test, using the same filename convention and PNG format as in the training part. Upload them in a single ZIP archive.


## Contact

For questions and requests, please contact `radim.tylecek@gmail.com` or `rbf@inf.ed.ac.uk`.

## Credits

Dataset composed by Hoang-An Le and Radim Tylecek.

Please report any errors via [issue tracker](https://github.com/TrimBot2020/3DRMS_Challenge2018/issues/new).

### Acknowledgements

Production of this dataset was supported by EU project TrimBot2020.

Please cite the following [paper](http://openaccess.thecvf.com/content_ECCVW_2018/papers/11131/Tylecek_The_Second_Workshop_on_3D_Reconstruction_Meets_Semantics_Challenge_Results_ECCVW_2018_paper.pdf)
 when using the dataset: 


    @techreport{tylecek2018rms,
      author={Radim Tylecek and Torsten Sattler and Hoang-An Le and Thomas Brox and Marc Pollefeys and Robert B. Fisher and Theo Gevers},
      title={3D Reconstruction meets Semantics: Challenge Results Discussion},
      institution={ECCV Workshops}, 
      month={September},
      year={2018},
      URL={http://trimbot2020.webhosting.rug.nl/events/3drms/challenge/}
    }
