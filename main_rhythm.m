% Clear the workspace and the screen
sca;
close all;
clear;


% enter subject info
subjectID = 'BW';
pix2deg = 45; % about 30 pixels for 1 visual degree
P_reds = 0.75; % possible proportion of red dots


% Here we call some default settings for setting up Psychtoolbox
HideCursor;
InitializeMatlabOpenGL;
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
screenInfo.bckgnd = white/2;
screenInfo.setRect = [0 0 600 500]; % 
Screen('Preference', 'SkipSyncTests', 2 );
[screenInfo.curWindow, screenInfo.screenRect] = Screen('OpenWindow', 0, screenInfo.bckgnd,screenInfo.setRect);
ScreenCenter = [screenInfo.screenRect(3)/2 screenInfo.screenRect(4)/2];
flipIntv=Screen('GetFlipInterval', screenInfo.curWindow);
slack=flipIntv/2;
w = screenInfo.curWindow;
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
center_rect = [screenInfo.screenRect(3) screenInfo.screenRect(4) screenInfo.screenRect(3) screenInfo.screenRect(4)] / 2;
set_keys;mkdir('Results');

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle').
% For help see: help rand
rand('seed', sum(100 * clock));

% ------ parameters ------ %

% fixation
fix_rect = [-10 -3 10 3; -3 -10 3 10];

% dot cloud
dotInfo.s = 3;  % dot radius in pixel
dotInfo.r = 75; % cloud radius
dotInfo.n = 100; % number of dots generated

% square out side gabor + disc
sqInfo.h = 2 *pix2deg;
sqInfo.w = 2 *pix2deg;
sqInfo.x = 6 *pix2deg;
sqInfo.y = 0;
sqInfo.c = [255 255 255];
sqInfo.c_tar = round(sqInfo.c * 0.95);

% timing
l.fix_to_sq = [0.5 0.8]; % fixation onset to square onset
l.sq_to_cue = [0.5 0.7]; % onset of square to onset of dot cloud
l.dot = [0.3 0.3];		 % dot cloud presented for 300 ms
l.CTI = 0.3:(1/120):1.1; % all possible values
l.tar = [0.1 0.1];		 % target presented for 100 ms
l.resp = 0.8;   	     % 800 ms response window
l.ITI = [0.4 0.6]; 		 % inter-trial interval

% ------ initiation ------ %

% location transformation
fix_rect = CenterRect_bw(fix_rect,center_rect);

% framed square location
sq_rect = [-sqInfo.x-sqInfo.w/2 sqInfo.y-sqInfo.h/2 -sqInfo.x+sqInfo.w/2 sqInfo.y+sqInfo.h/2]; % left square
sq_rect(2,:) = sq_rect + [2*sqInfo.x 0 2*sqInfo.x 0]; % right square
sq_rect = CenterRect_bw(sq_rect,center_rect);


% big matrices
NRepeats = 2;
Params = repmat(combvec(P_reds,l.CTI)',NRepeats,1); NTrials = size(Params,1);
r_tr = randperm(NTrials,NTrials/2); Params(r_tr,1) = 1 - Params(r_tr,1); % randomize left or right
Params = [Params, rand(NTrials,1)<0.8]; % random validity
Params = [Params,(Params(:,1)<0.5&Params(:,3)) | (Params(:,1)>0.5&~Params(:,3))]; % target left (0) or right (1)
Params = Params(randperm(NTrials),:); % shuffling
Time  = []; t_start = GetSecs;
Resps = [];

% sca;
% return

for iTrial = 1:NTrials

	% cue & target generation
	[x,y,dotColor] = gen_dots(dotInfo.r*2,dotInfo.n,Params(iTrial,1));
	if Params(iTrial,4)
		c_sq = [sqInfo.c; sqInfo.c_tar]; % right
	else
		c_sq = [sqInfo.c_tar; sqInfo.c]; % left
	end

	% fixation point
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_fix = Screen('Flip', w);

	% intial square presentation
	Screen('FillRect',w,[0 0 0],fix_rect');
	Screen('FillRect',w,sqInfo.c,sq_rect'); % square, commented out
	t_sq_on = Screen('Flip',w,t_fix+rand_in(l.fix_to_sq));

	% dot cloud
	Screen('FillRect',w,[0 0 0],fix_rect');
	Screen('FillRect',w,sqInfo.c,sq_rect'); % square, commented out
	Screen('DrawDots', w, [(x+screenInfo.screenRect(3)/2); (y+screenInfo.screenRect(4)/2)], dotInfo.s, dotColor, [], 2);
	t_dot_on = Screen('Flip', w, t_sq_on+rand_in(l.sq_to_cue));
	% offset
	Screen('FillRect',w,sqInfo.c,sq_rect'); % square, commented out
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_dot_off = Screen('Flip',w, t_dot_on+rand_in(l.dot));

	% target
	Screen('FillRect',w,c_sq',sq_rect'); % square, commented out
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_tar_on = Screen('Flip',w, t_dot_on+Params(iTrial,2));
	% offset
	Screen('FillRect',w,sqInfo.c,sq_rect'); % square, commented out
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_tar_off = Screen('Flip',w, t_tar_on+rand_in(l.tar));


	% response
	[rt,resp] = GetResp(l.resp,[esc_key,l_key,r_key]);
	if resp==esc_key
		sca;
		return
	end
	if ~isnan(resp) resp=(resp==r_key); end
	Resps = [Resps;resp,rt];


	% ITI
	WaitSecs(rand_in(l.ITI));
	Time = [Time; [t_fix,t_sq_on,t_dot_on,t_dot_off,t_tar_on,t_tar_off]-t_start];
end


T_out = array2table([Resps,Time],'VariableNames',{'resp','rt','t_fix','t_sq_on','t_dot_on','t_dot_off','t_tar_on','t_tar_off'});
Params = array2table(Params,'VariableNames',{'P_reds','dot_off_2_tar_on','validity','tar_lr'});
save(['Results/' subjectID '_rhythm.mat'],'T_out','Params');

sca;
return

function c_out = rand_in(c)
	c_out = rand*diff(c,1) + c(:,1);
end



function A = CenterRect_bw(A,c)
	A = A + repmat(c,size(A,1),1);
end  
