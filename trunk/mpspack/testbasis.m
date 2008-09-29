% test program for all basis types: reg FB (incl fast), real PWs, ...
% barnett 7/10/08, MFS added 7/20/08, fast hankel and bessel 9/5/08
% adapted from ~/bdry/inclus/test_evalbasis.m
%
% To Do:
% * reg FB: - fix |x|=0 NaN problem, same for nu FB.

clear classes
verb = 0;                            % use verb=0, N=50, for more of a test
err = 1;                             % false, show vals / true, show errors
dx = 0.01; g = -1:dx:1;              % plotting region
[xx yy] = meshgrid(g, g);
M = numel(xx);
p = pointset([xx(:) + 1i*yy(:)], ones(size(xx(:)))); % set up n for x-derivs
k = 10;

for type = 1:10
  switch type
   case {1,2,3}             % ................. Reg FB: real/cmplx, rescl
    N = 10;               
    opts.real = (type~=2); opts.rescale_rad = 1.0*(type==3); opts.usegsl = 0;
    b = regfbbasis(0, N, k, opts);
    c = 0.5;                 % set caxis scale for this basis type
    js = 1:b.Nf;             % indices to plot, here all of them
    fprintf('evaluating Reg FB basis... real=%d, resc=%d\n', opts.real, opts.rescale_rad)
   case {4,5}              % ................. real plane waves: real/cmplx
    N = 10;
    opts.real = (type==4);
    b = rpwbasis(N, k, opts);
    c = 2.0; js = 1:b.Nf;
    fprintf('evaluating real plane wave basis... real=%d\n', opts.real)
   
   case {6,7}              % ................. MFS: real/cmplx
    N = 10;
    opts.real = (type==6);
    opts.fast = 2;       % about 10x faster than o.fast=0 (matlab hankel)!
    b = mfsbasis(@(t) exp(1i*t), -0.4, N, k, opts);  % tau keeps them outside
    c = 1.0; js = 1:b.Nf;
    fprintf('evaluating MFS basis... real=%d\n', opts.real)
   
   case {8,9,10}            % ................. SLP, DLP, SLP+DLP
    N = 10; s = segment(N, [-1.5+.5i, .5i]);
    lp = 'S'; if type==9, lp = 'D'; elseif type==10, lp = [1 1i]; end
    o.fast = 2;       % about 5x faster than o.fast=0 (matlab hankel)!
    b = layerpot(s, lp, k, o); if type==10, lp = 'SLP+D'; end % hack for text
    c = 0.25; js = 1; %b.Nf; % 1 is off the region, b.Nf is in the region
    fprintf('evaluating {S,D}LP basis... %sLP\n', lp)
  end
  tic; [A Ax Ay] = b.eval(p); t=toc;
  fprintf('\t%d evals (w/ x,y derivs) in %.2g secs = %.2g us per eval\n',...
          numel(A), t, 1e6*t/numel(A))
  n = numel(js);
  u = reshape(A(:,js), [size(xx) n]);   % make stack of rect arrays
  ux = reshape(Ax(:,js), [size(xx) n]); % from j'th cols of A, Ax, Ay
  uy = reshape(Ay(:,js), [size(xx) n]);
  nnans = numel(find(isnan([u ux uy])));
  if nnans, fprintf('\tproblem: # NaNs = %d\n', nnans); end
  if verb
    showfields(g, g, u, c, sprintf('type %d: u_j', type));         % values
    %showfields(g, g, ux, c*k, sprintf('type %d: du_j/dx', type)); % x-derivs
    %showfields(g, g, uy, c*k, sprintf('type %d: du_j/dy', type)); % y-derivs
  end
  % errors in x-derivs...   plots should have no values larger than colorscale
  if err
    unje = (u(:,3:end,:)-u(:,1:end-2,:))/(2*dx) - ux(:,2:end-1,:); % FD error
  else
    unje = (u(:,3:end,:)-u(:,1:end-2,:))/(2*dx);              % FD value
    %showfields(g, g(2:end-1), unje, c*k, ...
    %           sprintf('type %d: FD val du_j/dx', type));
  end
  fprintf('\tmax err in u_x from FD calc = %g\n', max(abs(unje(:))))
  if verb>1, showfields(g, g(2:end-1), unje, c*(k*dx)^2, ...
                      sprintf('type %d: FD err in du_j/dx', type));
  end
  % errors in y-derivs...   plots should have no values larger than colorscale
  if err
    unje = (u(3:end,:,:)-u(1:end-2,:,:))/(2*dx) - uy(2:end-1,:,:); % FD error
  else
    unje = (u(3:end,:,:)-u(1:end-2,:,:))/(2*dx);                 % FD value
    showfields(g(2:end-1), g, unje, c*k, ...
                      sprintf('type %d: FD val du_j/dy', type));
  end
  fprintf('\tmax err in u_y from FD calc = %g\n', max(abs(unje(:))))
  if verb>1, showfields(g(2:end-1), g, unje, c*(k*dx)^2, ...
                      sprintf('type %d: FD err in du_j/dy', type));
  end
end