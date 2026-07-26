function [Pmax,ksq] = maxCollisionProbability2D(r1,v1,cov1,r2,v2,cov2,rA)  
% MAXCOLLISIONPROBABILITY2D Compute the maximum 2D probability of collision.
% This is an analytical solution for the scaling of the covariance ellipse
% that will give the approximate maximum probability of collision given the
% encounter geometry. The assumes the probability density is constant over
% the hard-body sphere, which is valid for small radii compared to the
% covariance.
%
% [Pmax,ksq] = maxCollisionProbability2D(r1,v1,cov1,r2,v2,cov2,rA) where
% Pmax is the maximum probability and ksq is the scaling factor of the
% input covariance that gives the maximum.
%
% r1     Primary spacecraft position (3x1)
% v1     Primary spacecraft velocity (3x1)
% cov1   Primary spacecraft covariance (3x3)
% r2     Secondary spacecraft position
% v2     Secondary spacecraft velocity
% cov2   Secondary spacecraft covariance 
% rA     Hard-body radius (keep-out-region)
%
% References: 
% [1] NASA Spacecraft Conjunction Assessment and Collision Avoidance
%     Best Practices Handbook, CARA Analysis Tools
% [2] Conjunction Risk Assessment and Avoidance Maneuver Planning Tools.
%     Saika Aida, 2015, https://core.ac.uk/display/31023996

% Copyright 2023 The MathWorks, Inc.

% Combined position covariance
covsum = cov1(1:3,1:3) + cov2(1:3,1:3);

if size(r1,1)==3
  r1 = r1';
  v1 = v1';
  r2 = r2';
  v2 = v2';
end

% Construct relative encounter frame
r = r2 - r1;
v = v2 - v1;
h = cross(r,v);

y = v / vecnorm(v);
z = h / vecnorm(h);
x = cross(y,z);

% Transformation matrix from ECI to relative encounter plane
eciToEnc = [x; y; z];

% Transform combined ECI covariance into encounter frame  
covsumEnc = eciToEnc * covsum * eciToEnc';
rEnc = eciToEnc*r';
rxz = rEnc([1 3]);

% Projection onto xz-plane in the relative encounter frame
Cxz = covsumEnc([1 3],[1 3]);
Cd = det(Cxz);

% Center of primary in the relative encounter plane
x0sq = dot(r,r);

% scaling factor for covariance for max probability
ksq = rxz'/Cxz*rxz; % factor of 2 difference from reference

if vecnorm(r)<rA
  Pmax = 1;
  return;
end

% approximate max probability
Pmax = rA.^2/exp(1)*sqrt(Cd)/x0sq/Cxz(2,2);
