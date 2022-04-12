% Clear the workspace and the screen
sca;
close all;
clear;

% enter subject info
subjectID = 'BW';
starting_delta_ori = 3;
pix2deg = 45; % about 30 pixels for 1 visual degree


% Here we call some default settings for setting up Psychtoolbox
HideCursor;
InitializeMatlabOpenGL;
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
screenInfo.bckgnd = white/2;
screenInfo.setRect = [0 0 1000 800]; % 
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

% gabor
gaborInfo.x = 8*cosd(45) *pix2deg; 	% x offset
gaborInfo.y = -8*sind(45) *pix2deg; % y offset, upper field
gaborInfo.r = 1.5 *pix2deg; 	% gabor radius in pixel

% square out side gabor + disc
sqInfo.h = gaborInfo.r*2.5;
sqInfo.w = gaborInfo.r*2.5;
sqInfo.w_frame = 10;
sqInfo.c_in = screenInfo.bckgnd;
sqInfo.x = gaborInfo.x;
sqInfo.y = gaborInfo.y;



% ------ initiation ------ %

% location transformation
fix_rect   = CenterRect_bw(fix_rect,center_rect);
gabor_rect = CenterRect_bw([-gaborInfo.x gaborInfo.y -gaborInfo.x gaborInfo.y;gaborInfo.x gaborInfo.y gaborInfo.x gaborInfo.y],[-1 -1 1 1]*gaborInfo.r+center_rect);
% framed square location
sq_rect = [-sqInfo.x-sqInfo.w/2 sqInfo.y-sqInfo.h/2 -sqInfo.x+sqInfo.w/2 sqInfo.y+sqInfo.h/2]; % left square
sq_rect(2,:) = sq_rect + [2*sqInfo.x 0 2*sqInfo.x 0]; % right square
sq_rect(3,:) = sq_rect(1,:) + [sqInfo.w_frame sqInfo.w_frame -sqInfo.w_frame -sqInfo.w_frame];
sq_rect(4,:) = sq_rect(2,:) + [sqInfo.w_frame sqInfo.w_frame -sqInfo.w_frame -sqInfo.w_frame];
sq_rect = CenterRect_bw(sq_rect,center_rect);
sq_color = [180 180 180;180 180 180;ones(2,3)*sqInfo.c_in]; % change to other gray if cue is not desired

% draw gabor
gaborDimPix = gaborInfo.r * 2;
freq = 1.5 / pix2deg;

contrast = 0.25;
aspectRatio = 1.0;
Sigma = 0.5 * pix2deg;
phase = 0;
propertiesMat = [phase+180, freq, Sigma, contrast, aspectRatio, 0, 0, 0];
GratPtr = CreateProceduralGabor(w,gaborDimPix, gaborDimPix,[],[0.5 0.5 0.5 1],1,0.5);

% set up staircase
Rev = 0;
StepSize = (starting_delta_ori)/3;
resp_rw  = [];
Xnext    = starting_delta_ori; 
P_reds   = [];
delta_ori = starting_delta_ori;


% ------ stimulus presentation ------ %
base_ori = 0; % horizontal(90) or vertical(0), (randi(2)-1) * 90
NTrials = 100;



T = [];
for iTrial = 1:NTrials

	% trial parameters
	gabor_lr = randi(2); % left(1) or right(2) gabor
	tilt_lr = randi(2)*2-3; % left(1) or right(-1) tilt

	% sample display
	% fixation
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_fix = Screen('Flip', w);

	% target onset
	% Screen('FillRect',w,sq_color',sq_rect'); % square, commented out
	Screen('DrawTextures',w,GratPtr,[],gabor_rect(gabor_lr,:)',base_ori+delta_ori*tilt_lr,[],[],[],[],kPsychDontDoRotation,propertiesMat');
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_tar_on = Screen('Flip', w, t_fix + 1);

	% target offset
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_tar_off = Screen('Flip', w,t_tar_on+0.5);


	% response collection
	[rt,resp] = GetResp(Inf,[esc_key,l_key,r_key]);
	if resp==esc_key
		sca;
		return
	end
	resp = (resp==l_key)*2 - 1;
	T = [T;gabor_lr,delta_ori,tilt_lr,resp,rt];

	% staircase
	[delta_ori,Threshold,Rev,StepSize] = StairCase(T(:,2),T(:,3)==T(:,4),3,Rev,StepSize);
	delta_ori = max([delta_ori 0]);
	if ~isnan(Threshold)
		break;
	end
	
	WaitSecs(0.5);
end

T_out = array2table(T,'VariableNames',{'gabor_lr','delta_ori','tilt_lr','resp_lr','RT'});
save(['Results/' subjectID '_gabor_thresh.mat'],'T_out','Threshold');
% KbStrokeWait;

sca;  



function A = CenterRect_bw(A,c)
	A = A + repmat(c,size(A,1),1);
end  
