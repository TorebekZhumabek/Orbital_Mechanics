function [Ri,Vi] = trajectory(R0,V0,dt,step)
    %% Calculate And Plot Trajectory
    %
    % Jeremy Penn
    % 22 September 2017
    %
    % Revision  22/09/17
    %           
    % function [Ri] = trajectory(R0,V0,mu,dt,step)
    %
    % Purpose:  This function calculates the trajectory of a satellite
    %           around the Earth over a given time interval.
    % 
    % Inputs:   o R0 - A 1x3 vector describing the initial position of the
    %                  satellite.
    %           o V0 - A 1x3 vector describing the initial velocity of the
    %                  satellite.
    %           o dt - The total time interval in seconds
    %           o step - The calculation step size in seconds
    % 
    % Output:   o Ri - A matrix of the calculated positions
    %           o Vi - A matrix of the calculated velocities
    %
    clc; clear R V Long Lat t ind Ri;
    mu     = 398600; %[km^3/s^2] Standard Grav Parameter
    t      = 0;       %[s] Initial time
    ind    = 1;
    N      = (dt / step) + 1;
    Ri     = zeros(N,3);
        while (t < dt)
            [R, V] = UniversalLagrange(R0, V0, t);
            Ri(ind,:) = R;
            Vi(ind,:) = V;
            ind = ind + 1;
            t = t + step;
        end
%    
end