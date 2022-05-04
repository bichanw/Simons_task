if ismac
	esc_key = KbName('ESCAPE');
	l_key = KbName('LeftArrow');
	r_key =  KbName('RightArrow');

	u_key = KbName('UpArrow');
	d_key = KbName('DownArrow');

else
	esc_key = KbName('esc');
	l_key = KbName('left');
	r_key =  KbName('right');

	u_key = KbName('up');
	d_key = KbName('down');

end

% keys that are same for mac & windows
y_key = KbName('y');
n_key = KbName('n');
confidence_key = KbName('1!');
confidence_key = [confidence_key (1:4)+confidence_key esc_key];