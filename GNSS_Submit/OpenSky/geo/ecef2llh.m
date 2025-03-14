% ecef2llh
function LLH = ecef2llh(XYZ)
    % Earth constants
    re = 6378137.0;           % Earth equatorial radius in meters
    eflat = (1.0/298.257223563);  % Earth flattening
    e2 = (2 - eflat) * eflat; % Eccentricity squared

    % Extract ECEF coordinates
    X = XYZ(:,1);
    Y = XYZ(:,2);
    Z = XYZ(:,3);

    % Compute longitude (lambda)
    lon = atan2(Y, X);  % Longitude in radians

    % Iteratively compute latitude (phi) and height (h)
    lat = atan(Z ./ sqrt(X.^2 + Y.^2));  % Initial guess for latitude
    h = zeros(size(X));  % Height (meters)
    r = sqrt(X.^2 + Y.^2);  % Distance from Z-axis

    % Iterative solution for latitude (phi)
    for i = 1:length(lat)
        r_N = re / sqrt(1 - e2 * sin(lat(i))^2);  % Radius of curvature in the prime vertical
        lat(i) = atan((Z(i) + e2 * r_N * sin(lat(i))) / r(i));  % Update latitude
        h(i) = r(i) / cos(lat(i)) - r_N;  % Calculate height
    end

    % Convert to degrees
    lat = rad2deg(lat);  % Latitude in degrees
    lon = rad2deg(lon);  % Longitude in degrees

    % Output latitude, longitude, and height
    LLH = [lat, lon, h];
end
