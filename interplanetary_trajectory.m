function interplanetary_trajectory()
    %% Calculates the interplanetary COE, ejection angle, & hyperbolic excess velocities
    %
    % Jeremy Penn
    % 11 November 2017
    %
    % Revision  11/11/2017
    %           12/11/2017 - added calculation of dv and beta angles
    %
    % function interplanetary_trajectory()
    %
    % Purpose:  This function calculates the interplanety trajectory orbit
    %           as well as delta-v and ejection/capture angles.
    %
    % Required: planet_sv.m, lambert.m, coe_from_rv.m
    %
    clc;
    
    %% constants
    mu = 132.71e9;  % [km^3/s^2]
    
    %% inputs
    planet1 = input('Input the departing planet:\n','s');
    planet1 = lower(planet1);
    
    planet2 = input('Input the target planet:\n','s');
    planet2 = lower(planet2);
    
    date1 = input('Input the departure date & time (dd/mm/yyyy/tt & 24-hour clock):\n','s');
    split1 = strsplit(date1, '/');
    
    d1 = str2double(split1{1});
    m1 = str2double(split1{2});
    y1 = str2double(split1{3});
    UT1 = str2double(split1{4});
    
    r_d = input('Input the perigee radius of the parking orbit:\n ');
    e_d = input('Input the eccentricity of the parking orbit:\n ');
    
    r_a = input('Input the perigee radius of the capture orbit:\n ');
    e_a = input('Input the eccentricity of the capture orbit:\n ');
    
    date2 = input('Input the arrival date & time (dd/mm/yyyy/tt & 24-hour clock):\n','s');
    split2 = strsplit(date2, '/');
    
    d2 = str2double(split2{1});
    m2 = str2double(split2{2});
    y2 = str2double(split2{3});
    UT2 = str2double(split2{4});
    
    %% calculate the state vector of planet 1 at departure
    [R1, V1, jd1] = planet_sv(planet1, d1, m1, y1, UT1);
    
    %% calculate the state vector of planet 2 at arrival
    [R2, V2, jd2] = planet_sv(planet2, d2, m2, y2, UT2);
    
    %% calculate the flight time
    t12 = jd2 - jd1;
    t12 = t12 * 86400; %convert days to seconds
    
    %% solve lambert's problem for the velocities at departure & arrival
    [vd, va] = lambert(R1, R2, t12, 1e-8, mu);
    
    %% calculate the hyperbolic excess velocities at departure & arrival
    V_inf_D = vd - V1;
    V_inf_A = va - V2;
    
    speed_inf_D = norm(V_inf_D);
    speed_inf_A = norm(V_inf_A);
    
    %% calculate the coe of the transfer orbit
    [h, e, inc, W, w, theta] = coe_from_rv(R1, vd, mu);
    a = (h^2/mu)*(1/(1-e^2));
    
    inc = mod(inc, 360);
    W = mod(W, 360);
    w = mod(w, 360);
    theta = mod(theta, 360);
    
    %% calculate the ejection angle
    
    % find the grav parameter of the departing planet
    switch planet1
        case 'mercury'
            mu_d = 22030;
            Rd = 2440;
        case 'venus'
            mu_d = 324900;
            Rd = 6052;
        case 'earth'
            mu_d = 398600;
            Rd = 6378;
        case 'mars'
            mu_d = 42828;
            Rd = 3396;
        case 'jupiter'
            mu_d = 126686000;
            Rd = 71490;
        case 'saturn'
            mu_d = 37931000;
            Rd = 60270;
        case 'uranus'
            mu_d = 5794000;
            Rd = 25560;
        case 'neptune'
            mu_d = 6835100;
            Rd = 24760;
        case 'pluto'
            mu_d = 830;
            Rd = 1195;
        otherwise
            error('Error: selected planet not available. Please try again.')
    end
    
    switch planet2
        case 'mercury'
            mu_a = 22030;
            Ra = 2440;
        case 'venus'
            mu_a = 324900;
            Ra = 6052;
        case 'earth'
            mu_a = 398600;
            Ra = 6378;
        case 'mars'
            mu_a = 42828;
            Ra = 3396;
        case 'jupiter'
            mu_a = 126686000;
            Ra = 71490;
        case 'saturn'
            mu_a = 37931000;
            Ra = 60270;
        case 'uranus'
            mu_a = 5794000;
            Ra = 25560;
        case 'neptune'
            mu_a = 6835100;
            Ra = 24760;
        case 'pluto'
            mu_a = 830;
            Ra = 1195;
        otherwise
            error('Error: selected planet not available. Please try again.')
    end
    
    rd = Rd + r_d; 
    e_h = 1 + rd*speed_inf_D^2 / mu_d; % ecc of hyperbolic ejection traj
    
    beta_d = acos(1/e_h)*180/pi;
    beta_d = mod(beta_d, 360);
    
    ra = Ra + r_a;
    e_h_a = 1 + ra*speed_inf_A^2 / mu_a; % ecc of hyperbolic capture traj
    
    beta_a = acos(1/e_h_a)*180/pi;
    beta_a = mod(beta_a, 360);
    
    %% calculate the delta-v of injection and capture
    v_d_p = sqrt( speed_inf_D^2 + 2*mu_d/rd );
    v_d_c = sqrt( (mu_d/rd) * (1 + e_d));
    
    delta_vd = v_d_p - v_d_c;
    
    v_a_p = sqrt( speed_inf_A^2 + 2*mu_a/ra );
    v_a_c = sqrt( (mu_a/ra) * (1 + e_a));
    
    delta_va = v_a_p - v_a_c;
    
    %% print the results
    dd = num2str(d1);
    md = num2str(m1);
    yd = num2str(y1);
    
    da = num2str(d2);
    ma = num2str(m2);
    ya = num2str(y2);
    
    date_depart = strcat(dd,'/',md,'/',yd);
    date_arrive = strcat(da,'/',ma,'/',ya);
    
    planet_d = replace(planet1,planet1(1),upper(planet1(1)));
    planet_a = replace(planet2,planet2(1),upper(planet2(1)));
    
    disp('---------------------------------------------------------------')
    fprintf('The state vector for %s on %s: \n', planet_d,date_depart);
    disp('---------------------------------------------------------------')
    fprintf('\t r_d = %.4e*i + %.4e*j + %.4e*k [km]\n',R1)
    fprintf('\t v_d = %.4f*i + %.4f*j + %.4f*k [km/s]\n',V1)
    
    disp('---------------------------------------------------------------')
    fprintf('The state vector for %s on %s: \n', planet_a,date_arrive);
    disp('---------------------------------------------------------------')
    fprintf('\t r_a = %.4e*i + %.4e*j + %.4e*k [km]\n',R2)
    fprintf('\t v_a = %.4f*i + %.4f*j + %.4f*k [km/s]\n',V2)
    
    disp('---------------------------------------------------------------')
    disp('The orbital elements of the transfer trajectory: ')
    disp('---------------------------------------------------------------')
    fprintf('\t h    = %.4e [km^2/s]\n',h)
    fprintf('\t e    = %.4f\n',e)
    fprintf('\t i    = %.4f [deg]\n',inc)
    fprintf('\t W    = %.4f [deg]\n',W)
    fprintf('\t w    = %.4f [deg]\n',w)
    fprintf('\t th_d = %.4f [deg]\n',theta)
    fprintf('\t a    = %.4e [km]\n',a)
    
    disp('---------------------------------------------------------------')
    disp('The transfer elements: ')
    disp('---------------------------------------------------------------')
    fprintf('\t t12     = %.2f [days]\n',t12/86400);
    fprintf('\t V_inf_D = %.4f*i + %.4f*j + %.4f*k [km/s]\n',V_inf_D);
    fprintf('\t speed_d = %.4f [km/s]\n',speed_inf_D);
    fprintf('\t V_inf_A = %.4f*i + %.4f*j + %.4f*k [km/s]\n',V_inf_A);
    fprintf('\t speed_a = %.4f [km/s]\n',speed_inf_A);
    
    disp('---------------------------------------------------------------')
    disp('The injection elements: ')
    disp('---------------------------------------------------------------')
    fprintf('\t beta    = %.4f [deg]\n', beta_d);
    fprintf('\t delta-v = %.4f [km/s]\n', delta_vd)
    
    disp('---------------------------------------------------------------')
    disp('The capture elements: ')
    disp('---------------------------------------------------------------')
    fprintf('\t beta    = %.4f [deg]\n', beta_a);
    fprintf('\t delta-v = %.4f [km/s]\n', delta_va)
end