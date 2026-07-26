function drawConjunction(cov2x2, rA, dMiss)
% DRAWCONJUNCTION Draw satellite conjunction geometry
% The conjunction encounter plane is defined from the relative position and
% velocity of the two objects. The avoidance region is the sum of the two
% objects' hard-body radii.
%
% cov2x2  Covariance in the encounter plane
% rA      Avoidance radius
% dMiss   Miss distance

% Copyright 2023 The MathWorks, Inc.

if nargin==0
  % Use default values
  cov2x2 = [1 -0.6; -0.6 2];
  rA = 0.1;
  dMiss = 2;
end

[u,s] = svd(cov2x2);
theta = linspace(0,2*pi,51);
xE = sqrt(s(1,1)) * cos(theta);
yE = sqrt(s(2,2)) * sin(theta);
rE = u*[xE;yE];
rB = [dMiss;0];

hFEncounter = figure;
hAEncounter = axes(hFEncounter);

hold(hAEncounter,"on");

% plot 1 sigma
plot(hAEncounter, rE(1,:),rE(2,:),'r--')
% plot 2 sigma
plot(hAEncounter, 2*rE(1,:),2*rE(2,:),'g--')
% plot 3 sigma
plot(hAEncounter, 3*rE(1,:),3*rE(2,:),'b--')

hold(hAEncounter,"on");

% Draw and label secondary object
patch(hAEncounter,rB(1)+rA*cos(theta),rB(2)+rA*sin(theta),'k')
text(hAEncounter,rB(1)+2*rA,rB(2),'Secondary Object')

% Draw and label satellite trajectory
line(hAEncounter,[0 0],ylim,'color',[0 0 0],'linewidth',2)
annotation(hFEncounter,'textarrow',[0.4 0.5],[0.75 0.75],'string','Primary Trajectory')

xlabel(hAEncounter,'x, r1-r2')
ylabel(hAEncounter,'z, dr x dv')
grid(hAEncounter,"on")
axis(hAEncounter,"equal")
legend(hAEncounter,'1 sigma','2 sigma','3 sigma')
title(hAEncounter,'Relative Encounter Geometry')