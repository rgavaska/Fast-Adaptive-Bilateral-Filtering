function [ Y ] = linearMap( X,xrange,yrange )
%LINEARMAP
% Linearly map values in the interval [xrange(1),xrange(2)] to [yrange(1),yrange(2)]
% X = Input image

x1 = xrange(1);
x2 = xrange(2);
y1 = yrange(1);
y2 = yrange(2);
m = (y2-y1)/(x2-x1);
c = (x2*y1-x1*y2)/(x2-x1);
Y = m*X + c;

end

