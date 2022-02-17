function [x,y,color] =  gen_dots(d,n_dots,p_red)
% d:		diameter of the dot cloud
% n_dots:	number of dots to generate (rough number)

% params for debugging
% d = 150;
% n_dots = 50;
% p_red = 1;

while true
	% generate dot location
	loc_index = randperm(d^2,round(n_dots*1.5)); % randomly selecting location index; round(n_dots / pi * 4)=1.27
	[y,x] = ind2sub([d d], loc_index);
	y = y - d/2; x = x - d/2;

	% constrain inside a circle
	dot_oi = (x.^2 + y.^2)<=(d/2)^2;

	% make sure there's enough number of dots
	if sum(dot_oi)>= n_dots
		break;
	end
end
dot_oi(find(dot_oi,sum(dot_oi)-n_dots)) = false;
x = x(dot_oi); y = y(dot_oi);

% generate color index
color = repmat([255;0;0],1,sum(dot_oi)); % default all red
n_green = round((1-p_red)*sum(dot_oi)); % the number to turn green
color(1,1:n_green) = 0; color(2,1:n_green) = 255; % change them to green

end