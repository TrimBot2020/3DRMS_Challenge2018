function R = quat2rotm(quat)
% x y z w
quat = quat/norm(quat);
w = quat(1);
x = quat(2);
y = quat(3);
z = quat(4);
R = [1 - 2*y*y - 2*z*z, 2*x*y - 2*z*w, 2*x*z + 2*y*w;
2*x*y + 2*z*w, 1 - 2*x*x - 2*z*z, 2*y*z - 2*x*w;
2*x*z - 2*y*w, 2*y*z + 2*x*w, 1 - 2*x*x - 2*y*y];