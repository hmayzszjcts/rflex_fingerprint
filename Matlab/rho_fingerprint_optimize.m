function [remainder,fval_features,wlind_features] = rho_fingerprint_optimize(rho,Lt,Ls,Ed,indices,bandwidth)
% Optimization of the shape of Rrs within bands affected by atmospheric absorption 
% 
% This optimization is called for every sample of Lw,Ls,Ed, after bands
% have been selected using the function rho_fingerprint_getfingerprint.
%
% SYNTAX: 
% [remainder,fval_features,wlind_features] = rho_fingerprint_optimize(rho,Lt,Ls,Ed,indices,bandwidth)
% 
% rho = value of sky radiance reflectance factor resulting in optimized Rrs
% Lt = Total radiance measured by water-viewing sensor
% Ls = Sky radiance
% Ed = Downwelling irradiance
% indices = the indices in Lw,Ls, and Ed of the bands selected with rho_fingerprint_getfingerprint
% bandwidth = the margin (half-bandwidth) to be inspected, on either side
% of each selected band. If sensor resolution allows, choose bandwidth
% corresponding to 5-10 nm (e.g. bw = 2 for TriOS Ramses or Satlantic Hypersas)
%
% 
% [Please retain the following traceback notice in your code]
% Version: 20130410.1
% Adaptation: -
%
% This code is the implementation of the 'fingerprint' method to derive Rrs from hyperspectral (ir)radiance measurements:
% Simis, S.G.H. and J. Olsson. Unattended processing of shipborne hyperspectral reflectance measurements. Remote Sensing of Environment, in press. DOI: 10.1016/j.rse.2013.04.001
%
% <a href="http://creativecommons.org/licenses/by-sa/3.0/deed.en_GB"><img src="http://i.creativecommons.org/l/by-sa/3.0/88x31.png"></a>
% This work is licensed under a <a href="http://creativecommons.org/licenses/by-sa/3.0/deed.en_GB">Creative Commons Attribution-ShareAlike 3.0 Unported License</a>
% This code is maintained in a git repository at http://sourceforge.net/p/rflex/fingerprint/
%
% Rflex hardware/software are described at http://sourceforge.net/p/rflex/wiki/Home/
% 
% See also rho_fingerprint_getfingerprint polyfit polyval

% start
% Do not display warnings generated by the optimization function (change to debug)
warning('off');

%margin selected on either side of selected feature (should be a function of sensor resolution). For 3.3 nm sensors like TrioS RAMSES, leave at 2. For finer resolution, increase.
bw = bandwidth; 

ind = indices;
Lw = Lt - (rho*Ls);
ratio = Lw./Ed;
grid0 = [-bw:1:bw]';
grid1 = grid0([1:bw,end-bw+1:end]);
for j = 1:numel(ind);
    % fit polynome through this part of the spectrum (around the selected drop or rise)
    Y = polyfit(grid1,ratio([ind(j)-bw:ind(j)-1,ind(j)+1:ind(j)+bw]),2);
    Z = polyval(Y,grid0);
    %then define the minimization parameter = distance from peak to polynomial fit
    remainder(j) = abs(ratio(ind(j))-Z(bw+1));
end;
fval_features = remainder;
remainder = sum(remainder);
wlind_features = ind;
