function Pc = collisionProbability2D(r1,v1,cov1,r2,v2,cov2,rA)  
% COLLISITIONPROBABILITY2D Compute the 2D probability of collision
% Compute the 2D probability of collision using quadrature. The satellite
% states and covariance must be in the ECI frame.
% 
% Pc = collisionProbability2D(r1,v1,cov1,r2,v2,cov2,rA) where Pc is the
% collision probability.
%
% r1     Primary spacecraft position (3x1)
% v1     Primary spacecraft velocity (3x1)
% cov1   Primary spacecraft covariance (3x3)
% r2     Secondary spacecraft position (3x1)
% v2     Secondary spacecraft velocity (3x1)
% cov2   Secondary spacecraft covariance (3x3)
% rA     Hard-body radius (keep-out-region)
%
% References: 
%
% [1] NASA Spacecraft Conjunction Assessment and Collision Avoidance Best
% Practices Handbook, CARA Analysis Tools
% 
% [2]"Conjunction Risk Assessment and Avoidance Maneuver Planning Tools."
% Saika Adia, 6th International Conference on Astrodynamics Tools and
% Techniques, 2016. Available on ResearchGate.

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
r = r1 - r2;
v = v1 - v2;
h = cross(r,v);

y = v / vecnorm(v);
z = h / vecnorm(h);
x = cross(y,z);

% Transformation matrix from ECI to relative encounter plane
eciToXYZ = [x; y; z];

% Transform combined ECI covariance into xyz  
covsumxyz = eciToXYZ * covsum * eciToXYZ';

% Projection onto xz-plane in the relative encounter frame
Cxz = covsumxyz([1 3],[1 3]);

% Center of primary in the relative encounter plane
x0 = norm(r);

% Inverse of the Ce matrix
C  = inv(Cxz);
Cd = det(Cxz);

% Tolerances
RelTol = 1e-09;
AbsTol = 1e-13;

% 2x2 Integrand, e^(-0.5 r' C r), r is [x z]
Integrand = @(x,z) exp(-1/2*(C(1,1).*x.^2+(C(1,2)+C(2,1))*z.*x+C(2,2)*z.^2));

% Integrate over the circular hard-body region
upper_half = @(x)( sqrt(rA.^2 - (x-x0).^2) .* (abs(x-x0)<=rA));
lower_half = @(x)(-sqrt(rA.^2 - (x-x0).^2) .* (abs(x-x0)<=rA));
Pc = 1/(2*pi)*1/sqrt(Cd)*...
  quad2d(Integrand,x0-rA,x0+rA,lower_half,upper_half,'AbsTol',AbsTol,'RelTol',RelTol);
