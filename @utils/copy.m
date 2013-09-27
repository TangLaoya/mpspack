% COPY - Make a deep copy of a handle object
%
%  b = copy(a) supposedly makes b a deep copy of handle object a
%
%  author: Doug M. Schwarz, 6/16/08
%  http://www.mathworks.com/matlabcentral/newsreader/view_thread/171019#438411
% Also see
%  http://www.mathworks.com/matlabcentral/newsreader/view_thread/172147
%
% Note: this is quite slow (the copy properties loop), eg takes 3 ms to copy
% a segment object, even when N is tiny.

function new = copy(this)

% Instantiate new object of the same class.
new = feval(class(this));

if numel(this)==1
  % Copy all non-hidden properties.
  p = properties(this);
  for i = 1:length(p)
    new.(p{i}) = this.(p{i});
  end
else
  for j=1:numel(this)
    p = properties(this(j));
    for i = 1:length(p)
      new(j).(p{i}) = this(j).(p{i});
    end
  end
end
