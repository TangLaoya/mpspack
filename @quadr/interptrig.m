function [g] = interptrig(f, N)
% INTERPTRIG - regular interpolate periodic function w/ trig poly's and FFT
%
% [g] = interptrig(f, N).  f is a row or col vec, or stack of col vecs.
%   In the last case, interp is done to each col vec separately.
%   N is new number of points. Cannot be less than numel(f), currently.
%   Key convention is that points are spaced at the half-integers
%   ie, t = 2*pi*((1:n)-0.5)/n
%
% See also: MATLAB's polyfun/interpft.m which doesn't allow grid sliding
% TESTINTERPTRIG shows how to construct the dense interp matrix.

% Copyright (C) 2012 - 2013, Alex Barnett

row=(size(f,1)==1); if row, f = f.'; end, ncols = size(f,2); n = size(f,1);
F = fft(f,[],1);  % fft down the col(s)
nyqst = ceil((n+1)/2);     % following few lines from MATLAB's interpft.m
G = [F(1:nyqst,:) ; zeros(N-n,ncols) ; F(nyqst+1:n,:)];
if rem(n,2) == 0
   G(nyqst,:) = G(nyqst,:)/2;
   G(nyqst+N-n,:) = G(nyqst,:);
end
sh = 0.5 * 2*pi*(1/n - 1/N); % now do the shift to 1/2-centered grid..
if mod(N,2)==0, ks = [0:N/2 -N/2+1:-1]; else, ks = [0:(N-1)/2 -(N-1)/2:-1]; end
G = G .* repmat(exp(-1i*sh*ks'), [1 ncols]);  % ks is k-grid
% xform back (again from MATLAB's interpft.m)
g = ifft(G,[],1);
if isreal(f), g = real(g); end
if row, g = g.'; end % make row vec if f was
g = g * N/n;
