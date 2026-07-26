function [tCA,dCA,dV] = findConjunctions(sc,satellite1,satellite2,nDays,dMinTarget,dMin,doPlot)
% FINDCONJUNCTIONS Find conjunctions between a pair of satellites
% This function may take a long time - greater than 1 minute - depending on
% the screening distance and how many close passes there are.
%
% [tConj,dConj,vConj] = findConjunctions(sc,satellite1,satellite2,nDays,dMinTarget,dMin,doPlot)
%
% Inputs Arguments:
%   sc         Scenario object
%   satellite1 Satellite 1 from scenario
%   satellite2 Satellite 2 from scenario
%   nDays      Number of days, default 7
%   dMinTarget Coarse screening distance in m, default 200,000
%   dMin       Fine screening distance in m, default 1,000
%
% Output Arguments:
%   tConj   datetimes of any conjunctions within dMin
%   dConj   Distance between satellites at tConj
%   vConj   Velocity different at tConj
%
% Example:
%
%   sc = satelliteScenario;
%   tleFile = "Conjunction_Starlink1735_Starlink2304.txt";
%   satellites = satellite(sc,tleFile);
%   nDays = days(7);
%   dMinTarget = 200e3;
%   dMin = 500;
%   findConjunctions(sc,satellites(1),satellites(2),nDays,dMinTarget,dMin);


% Copyright 2022-2023 The MathWorks, Inc.

arguments
    sc (1,1)         % sateliteScenario
    satellite1 (1,1) matlabshared.satellitescenario.Satellite
    satellite2 (1,1) matlabshared.satellitescenario.Satellite
    nDays (1,1) duration = days(7);
    dMinTarget (1,1) double = 200000;
    dMin (1,1) double = 1000;
    doPlot (1,1) matlab.lang.OnOffSwitchState = false
end

%% Find Windows When the Satellites Pass Within a Specified Distance
% A sample time of 20 seconds is sufficient for LEO satellites.
startTime_init = sc.StartTime;
sc.StopTime = startTime_init + nDays;
sc.SampleTime = 20;

% Get the satellite position data and associated times using the aer function 
[~,~,range,tOut] = aer(satellite1,satellite2);

%% Find Windows When the Satellites Pass Within a Specified Distance
% Compute the distance between the two satellite positions. Determine the
% indices of the range when the satellite are closer than the target of 200
% km. 
kCloseIdx = find(range<dMinTarget);
dW        = [0 diff(kCloseIdx)];
kWindow   = zeros(2,length(kCloseIdx));
j = 1;
for m = 1:length(dW)
    if dW(m)~=1
        % single point window
        kWindow(1,j) = max(1,kCloseIdx(m)-1);
        kWindow(2,j) = kCloseIdx(m)+1;
        j = j+1;
    elseif j>1
        % update window end as long as diff==1
        kWindow(2,j-1) = kCloseIdx(m)+1;
    end
end

kWindow = kWindow(:,1:j-1);
windows = tOut(kWindow);

%% Search the Windows for the Closest Approach
% To find the point of closest approach, look for the cost to change sign
% over the window.  
tMin = zeros(1,size(windows,1));
dRs = zeros(1,size(windows,1));
for k = 1:size(windows,2)
    % Test the Gradient Function Over Window
    [dRDot1,dR1] = loc_gradientScenario(days(windows(1,k)-sc.StartTime), satellite1, satellite2, sc.StartTime, sc.StopTime);
    [dRDot2,dR2] = loc_gradientScenario(days(windows(2,k)-sc.StartTime), satellite1, satellite2, sc.StartTime, sc.StopTime);
    if sign(dRDot1)~=sign(dRDot2)
        tMin(k) = fzero(@(t) loc_gradientScenario(t,satellite1,satellite2,sc.StartTime, sc.StopTime),days(windows(:,k)-sc.StartTime));
        [~,dRs(k)] = loc_gradientScenario(tMin(k), satellite1, satellite2, sc.StartTime, sc.StopTime);
    else
        [dRs(k),iT] = min([dR1 dR2]);
        tMin(k) = days(windows(iT,k)-sc.StartTime);
    end
end

iMin = find(dRs<dMin);

if isempty(iMin)
    % No conjunction detected
    tCA = [];
    dCA = [];
    dV = [];
    return;
end

dCA = dRs(iMin);
tCA = sc.StartTime + tMin(iMin);

% Verify the relative velocity between the satellites from SOCRATES using
% the states function and the time of closest approach. The velocity is in
% m/s.  
vel = zeros(3,length(tCA),2);
for k = 1:length(tCA)
    [~,vel(:,k,:)] = states([satellite1 satellite2],tCA(k));
end
dV = vecnorm(vel(:,:,1)-vel(:,:,2));

% To plot the resulting close passes, use the stem function. Mark the
% closest approach in red.   
if (nargout == 0 || doPlot)
    figure('name','ConjunctionDetection');
    subplot(211)
    plot(tOut,range)
    tf = islocalmin(range);
    hold on
    plot(tOut(tf),range(tf),'*')
    grid on
    ylabel('Coarse Distance (m)')
    title('Distance Between Satellites')
    xl = xlim;
    subplot(212)
    stem(tMin+sc.StartTime,dRs);
    hold on
    stem(tCA,dCA,'filled','r')
    grid on
    ylabel('Closest Approach (m)')
    xlim(xl)
    disp(table(tCA, dCA, dV, days(tCA-sc.StartTime), ...
        VariableNames=["Conjunction time", "Dist at closest approach (m)", "Velocity difference (m/s)", "Time from epoch (days)"]))
end


    function [dRDot,dRmin] = loc_gradientScenario( t, satellite1, satellite2, StartTime, StopTime )
        % LOC_GRADIENTSCENARIO Determine gradient of the distance function
        % between two satellites. For use with FZERO.
        % Since the distance between the satellites decreases then increases with
        % each close pass, we can use the gradient of this distance to find the
        % exact minimum distance - when the derivative changes sign. In order to
        % compute the gradient we generate the state of the satellites at the
        % requested time along with a delta time before and after, just a fraction
        % of a second.
        %
        % [dRDot,dRmin] = loc_gradientScenario( T )
        % returns the gradient and minimum distance between the satellites at time
        % T. T is a double with units of days.

        % Compute points on either side of the input time
        delT = 0.1*[-1 0 1]; % seconds

        % gradient between the satellites at time
        dRDot = ones(size(t));
        % minimum distance between the satellites at time
        dRmin = 1e10*ones(size(t));
        loc_range  = zeros(size(delT));

        % Keep time with realistic values
        index = 2;
        if (t == 0)
            % Avoid negative time from scenario
            delT = delT + 0.1;
            index = 1;
        elseif (t == days(StopTime-StartTime))
            % Avoid exceeding end of scenario 
            delT = delT - 0.1;
            index = 3;
        end

        for loc_k = 1:length(t)
            for loc_p = 1:length(delT)
                [~,~,loc_range(loc_p)] = aer(satellite1, satellite2,StartTime+t+seconds(delT(loc_p)));
            end
            yp = gradient(loc_range);
            dRDot(loc_k) = yp(index);
            dRmin(loc_k) = loc_range(index);
        end

    end

end