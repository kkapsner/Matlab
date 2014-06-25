%MEDIAN1D_cpp Performs a median filter
%   this function does a similar task to medfilt1 BUT it has a less insane
%   handling of the data border.
%   Additional it runs faster.
%
%   But it always runs on the first dimension (despite the first dimension
%   has length one). To run the filter on a different dimension use
%   median1D.
%   
%   See also MEDFILT1, MEDIAN1D

