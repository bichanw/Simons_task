if ismac
	esc_key = KbName('ESCAPE');
	l_key = KbName('LeftArrow');
	r_key =  KbName('RightArrow');

else
	esc_key = KbName('esc');
	l_key = KbName('left');
	r_key =  KbName('right');

end

confidence_key = KbName('1!');
confidence_key = [confidence_key (1:4)+confidence_key esc_key];