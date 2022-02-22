% Clear the workspace and the screen

sca;
close all;
clear;

% enter subject info
subjectID = 'test2';

% Here we call some default settings for setting up Psychtoolbox
HideCursor;
InitializeMatlabOpenGL;
screenInfo.bckgnd = 128;
screenInfo.setRect = [];
Screen('Preference', 'SkipSyncTests', 2 );
[screenInfo.curWindow, screenInfo.screenRect] = Screen('OpenWindow', 0, screenInfo.bckgnd,screenInfo.setRect);
ScreenCenter = [screenInfo.screenRect(3)/2 screenInfo.screenRect(4)/2];
flipIntv=Screen('GetFlipInterval', screenInfo.curWindow);
slack=flipIntv/2;
w = screenInfo.curWindow;
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
center_rect = [screenInfo.screenRect(3) screenInfo.screenRect(4) screenInfo.screenRect(3) screenInfo.screenRect(4)] / 2;

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle').
% For help see: help rand
rand('seed', sum(100 * clock));

% ------ parameters ------ %

% number of trial for psychometric curve
NRepeats = 100;
NLevels = 5;

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


% response instruction
respdisc_rect = [CenterRect_bw([-120 -20 -80 20],center_rect); CenterRect_bw([80 -20 120 20],center_rect)];

% square out side gabor + disc
sqInfo.h = 200;
sqInfo.w = 70;
sqInfo.w_frame = 0;
sqInfo.c_in = 128;
sqInfo.x = gaborInfo.x;
sqInfo.y = gaborInfo.y;



% ------ initiation ------ %

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

% set up keyboard
if ismac
	esc_key = KbName('ESCAPE');
else
	esc_key = KbName('esc');
end


% set up staircase
Rev = 0;
StepSize = 0.03;
resp_rw = [];
Xnext = 0.6; Coherence = []; 
P_reds = [];


thresh_file = ['Results/' subjectID '_thresh.mat'];
if exist(thresh_file)
	load(thresh_file)
else

	for iTrial = 1:1000	

		% ------ task ------ %
		Coherence(end+1) = Xnext;
		more_red = randi(2)-1;
		if more_red 
			P_reds(end+1) = Coherence(end);
			correct_resp = 80;
		else
			P_reds(end+1) = 1-Coherence(end);
			correct_resp = 79;
		end % randomly choosing from red or green
		[x,y,dotColor] = gen_dots(dotInfo.r*2,dotInfo.n,P_reds(end));

		% fixation point
		Screen('FillRect',w,[0 0 0],fix_rect');
		t_fix = Screen('Flip', w);

		% draw dot cloud
		Screen('DrawDots', w, [(x+screenInfo.screenRect(3)/2); (y+screenInfo.screenRect(4)/2)], dotInfo.s, dotColor, [], 2);
		Screen('FillRect',w,[0 0 0],fix_rect');
		t_dot = Screen('Flip', w, t_fix+1.0);


		% stimulu offset period
		Screen('FillRect',w,[0 0 0],fix_rect');
		t_delay = Screen('Flip', w, t_dot+0.3);



		% ------ response ------ %
		% red or green
		Screen('DrawText',w,'Which is more?',center_rect(1)-100,center_rect(2)-100);
		Screen('FillRect',w,[255 0 0; 0 255 0]',respdisc_rect'); % left red, right green
		Screen('Flip', w,t_dot+1);
		[rt(iTrial),resp_lr(iTrial)] = GetResp(Inf);
		% exit program
		if (resp_lr(iTrial) == esc_key)
			sca;
			return;
		end
		WaitSecs(0.5);

		% apply staircase
		resp_rw(end+1) = (resp_lr(end)==correct_resp);
		[Xnext,Threshold,Rev,StepSize] = StairCase(Coherence,resp_rw,3,Rev,StepSize);
		Xnext = max([Xnext 0.5]);
		
		if ~isnan(Threshold)
			break;
		end

		% % confidence level
		% Screen('DrawText',w,'Rate your confidence (1-5)',center_rect(1)-150,center_rect(2)-25);
		% Screen('Flip', w);
		% [rt(iTrial,2),resp(iTrial,2)] = GetResp(Inf);

	end
	save(thresh_file,'P_reds','Threshold','Coherence','rt','resp_lr','resp_rw');
end


i_tr_start = numel(P_reds);
newtrs = repmat(linspace(1-Threshold,Threshold,NLevels),1,NRepeats);
rt_rep = nan(NRepeats*NLevels,1); resp_lr_rep = rt_rep; 
P_reds_rep = newtrs(randperm(NRepeats*NLevels));
for iTrial = 1:(NRepeats*NLevels)

	

	% ------ task ------ %
	[x,y,dotColor] = gen_dots(dotInfo.r*2,dotInfo.n,P_reds_rep(iTrial));

	% fixation point
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_fix = Screen('Flip', w);

	% draw dot cloud
	Screen('DrawDots', w, [(x+screenInfo.screenRect(3)/2); (y+screenInfo.screenRect(4)/2)], dotInfo.s, dotColor, [], 2);
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_dot = Screen('Flip', w, t_fix+1.0);


	% stimulu offset period
	Screen('FillRect',w,[0 0 0],fix_rect');
	t_delay = Screen('Flip', w, t_dot+0.3);



	% ------ response ------ %
	% red or green
	Screen('DrawText',w,'Which is more?',center_rect(1)-100,center_rect(2)-100);
	Screen('FillRect',w,[255 0 0; 0 255 0]',respdisc_rect'); % left red, right green
	Screen('Flip', w,t_dot+1);
	[rt_rep(iTrial),resp_lr_rep(iTrial)] = GetResp(Inf);
	if resp_lr_rep(iTrial) == esc_key
		sca;
		return;
	end
	WaitSecs(0.5);


	% % confidence level
	% Screen('DrawText',w,'Rate your confidence (1-5)',center_rect(1)-150,center_rect(2)-25);
	% Screen('Flip', w);
	% [rt(iTrial,2),resp(iTrial,2)] = GetResp(Inf);

end

iFile = numel(dir(['Results/' subjectID '*']));
save(['Results/' subjectID '_' num2str(iFile) '.mat'],'resp_lr_rep','rt_rep','P_reds_rep');


sca;  



function A = CenterRect_bw(A,c)
	A = A + repmat(c,size(A,1),1);
end  
