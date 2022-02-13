% Clear the workspace and the screen

sca;
close all;
clear;

% Here we call some default settings for setting up Psychtoolbox
HideCursor;
InitializeMatlabOpenGL;
screenInfo.bckgnd = 128;
screenInfo.setRect = [0 0 600 500];
Screen('Preference', 'SkipSyncTests', 2 );
[screenInfo.curWindow, screenInfo.screenRect] = Screen('OpenWindow', 0, screenInfo.bckgnd,screenInfo.setRect);
ScreenCenter = [screenInfo.screenRect(3)/2 screenInfo.screenRect(4)/2];
flipIntv=Screen('GetFlipInterval', screenInfo.curWindow);
slack=flipIntv/2;
w = screenInfo.curWindow;
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
center_rect = [screenInfo.setRect(3) screenInfo.setRect(4) screenInfo.setRect(3) screenInfo.setRect(4)] / 2;

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

% gabor
gaborInfo.x = 200; 	% x offset
gaborInfo.y = -100; % y offset, upper field
gaborInfo.r = 30; 	% gabor radius in pixel

% disc
discInfo.r = 30;
discInfo.lum = 200;
discInfo.d2gabor = 65; % distance to gabor in pixel
discInfo.sigma = 20;

% square out side gabor + disc
% sqInfo.h = 200;
% sqInfo.w = 70;
% sqInfo.w_frame = 0;
% sqInfo.c_in = 128;
% sqInfo.x = gaborInfo.x;
% sqInfo.y = gaborInfo.y;



% ------ initation ------ %

% location transformation
fix_rect   = CenterRect_bw(fix_rect,center_rect);
gabor_rect = CenterRect_bw([-gaborInfo.x gaborInfo.y -gaborInfo.x gaborInfo.y;gaborInfo.x gaborInfo.y gaborInfo.x gaborInfo.y],[-1 -1 1 1]*gaborInfo.r+center_rect);
disc_rect  = discInfo.d2gabor*[0 -1 0 -1;0 1 0 1; 0 -1 0 -1; 0 1 0 1] + [gaborInfo.x gaborInfo.y gaborInfo.x gaborInfo.y].*[-1 1 -1 1;-1 1 -1 1;1 1 1 1;1 1 1 1];
disc_rect  = CenterRect_bw(disc_rect,center_rect+[-1 -1 1 1]*discInfo.r);
% framed square location
sq_rect = [-sqInfo.x-sqInfo.w/2 sqInfo.y-sqInfo.h/2 -sqInfo.x+sqInfo.w/2 sqInfo.y+sqInfo.h/2]; % left square
sq_rect(2,:) = sq_rect + [2*sqInfo.x 0 2*sqInfo.x 0]; % right square
sq_rect(3,:) = sq_rect(1,:) + [sqInfo.w_frame sqInfo.w_frame -sqInfo.w_frame -sqInfo.w_frame];
sq_rect(4,:) = sq_rect(2,:) + [sqInfo.w_frame sqInfo.w_frame -sqInfo.w_frame -sqInfo.w_frame];
sq_rect = CenterRect_bw(sq_rect,center_rect);


% draw gabor
gaborDimPix = gaborInfo.r * 2;
numCycles = 5;
freq = numCycles / gaborDimPix;

contrast = 0.5;
aspectRatio = 1.0;
Sigma = gaborDimPix/8;
phase = 0;
propertiesMat = [phase+180, freq, Sigma, contrast, aspectRatio, 0, 0, 0];
GratPtr = CreateProceduralGabor(w,gaborDimPix, gaborDimPix,[],[0.5 0.5 0.5 1],1);
% draw disc
DiscPtr = CreateProceduralSmoothedDisc(w, discInfo.r*2, discInfo.r*2 , [], discInfo.r, discInfo.sigma);


P_reds = [0.7 0.5 0.3];
for iTrial 

	
	l.delay = rand*800 + 400;

	% ------ task ------ %
	gabor_ori = -45;
	p_red = 0.7; % proportion of red dots
	[x,y,dotColor] = gen_dots(dotInfo.r*2,dotInfo.n,p_red);

	% fixation point
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_fix = Screen('Flip', w);

	% draw dot cloud
	Screen('DrawDots', w, [(x+screenInfo.setRect(3)/2); (y+screenInfo.setRect(4)/2)], dotInfo.s, dotColor, [], 2);
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_dot = Screen('Flip', w, t_fix+1.0);


	% delay period
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_delay = Screen('Flip', w, t_dot+0.3);

	% sample display
	% Screen('FillRect',w,[255 0 0;0 250 0;ones(2,3)*sqInfo.c_in]',sq_rect'); % square, commented out
	Screen('DrawTextures',w,DiscPtr,[],disc_rect',[],[],[],ones(1,3)*discInfo.lum);
	Screen('DrawTextures',w,GratPtr,[],gabor_rect',gabor_ori,[],[],[],[],kPsychDontDoRotation,propertiesMat');
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_sample = Screen('Flip', w, t_delay+l.delay);

	% inter-display 
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_idd = Screen('Flip', w, t_sample+0.2);

	% probe display
	% Screen('FillRect',w,[255 0 0;0 250 0;ones(2,3)*sqInfo.c_in]',sq_rect'); % square, commented out
	Screen('DrawTextures',w,DiscPtr,[],disc_rect',[],[],[],ones(1,3)*discInfo.lum);
	Screen('DrawTextures',w,GratPtr,[],gabor_rect',gabor_ori,[],[],[],[],kPsychDontDoRotation,propertiesMat');
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_probe = Screen('Flip', w, t_idd+0.2);

	% saccade resp
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_resp = Screen('Flip', w, t_probe+0.2);
end


% making demo
% img = cat(4,img,Screen('GetImage',w));
% mov([1:15 27:42 50:56 64:90])  = {squeeze(img(:,:,:,1))};
% mov(16:26) = {squeeze(img(:,:,:,2))};
% mov(43:49) = {squeeze(img(:,:,:,3))};
% mov(57:63) = {squeeze(img(:,:,:,4))};


% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo. For help see: help KbStrokeWait
KbStrokeWait;

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;  


function A = CenterRect_bw(A,c)
	A = A + repmat(c,size(A,1),1);
end  
