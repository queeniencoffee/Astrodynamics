function DCM = dcmicrf2lvlh( pos_icrf, vel_icrf )
% DCMICRF2LVLH Convert Earth-centered inertial to LVLH coordinates
% Given satellite position and velocity in the inertial frame, compute the
% direction cosine matrix to rotate from inertial to the local vertical,
% local horizontal (LVLH) frame. The LVLH frame axes R, S, W move with the
% satellite and are:
% 
% - x/R: radial, along the position vector
% - y/S: tangential, or along-track
% - z/W: orbit normal, also called cross-track or out-of-plane
%
% Note that the y-axis (S) will only be perfectly aligned with the velocity in
% circular orbits or for ellipical orbits, at apogee and perigee.
%
% DCM = dcmicrf2lvlh( position, velocity ) returns the transformation matrix
% DCM that rotates an inertial state to an LVLH state. The position and velocity
% inputs are in the inertial frame. They may be in any units.

% Copyright 2023 The MathWorks, Inc.

% if row vectors, rotate to columns
if size(pos_icrf,1)==1
  pos_icrf = pos_icrf';
  vel_icrf = vel_icrf';
end

x = pos_icrf/vecnorm( pos_icrf ); % x is radial
h = cross( pos_icrf, vel_icrf );  % h is + orbit normal
z = h/vecnorm(h);
y = cross( z, x );    % y completes RHS
DCM = [x'; y'; z'];   % Inertial to LVLH rotation matrix
