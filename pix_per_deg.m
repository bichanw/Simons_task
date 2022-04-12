% Clear the workspace and the screen
sca;
close all;
clear;

% enter subject info
subjectID = 'BW_700';
starting_coherence = 0.6;

% Here we call some default settings for setting up Psychtoolbox
HideCursor;
InitializeMatlabOpenGL;
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
screenInfo.bckgnd = white/2;
screenInfo.setRect = [0 0 600 500];
Screen('Preference', 'SkipSyncTests', 2 );
[screenInfo.curWindow, screenInfo.screenRect] = Screen('OpenWindow', 0, screenInfo.bckgnd,screenInfo.setRect);
ScreenCenter = [screenInfo.screenRect(3)/2 screenInfo.screenRect(4)/2];
flipIntv=Screen('GetFlipInterval', screenInfo.curWindow);
slack=flipIntv/2;
w = screenInfo.curWindow;
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
center_rect = [screenInfo.screenRect(3) screenInfo.screenRect(4) screenInfo.screenRect(3) screenInfo.screenRect(4)] / 2;
set_keys;
% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle').
% For help see: help rand
rand('seed', sum(100 * clock));

% ------ parameters ------ %
pix2deg = 30;

% ------ stimulus presentation ------ %
% adjust size
while true
	Screen('FillOval',w,[],center_rect+[-1 -1 1 1]/2*pix2deg); % square, commented out
	Screen('Flip', w);

	[~,resp] = GetResp(Inf,[esc_key,u_key,d_key]);

	% change size
	if resp==u_key
		pix2deg = pix2deg + 1;
	elseif resp==d_key
		pix2deg = pix2deg - 1;
	else
		Screen('DrawText',w,sprintf('About %d pixels per degree',pix2deg),center_rect(1)-150,center_rect(2)-50);
		Screen('Flip', w);
		WaitSecs(3);
		sca;
		return
	end
			
end


KbStrokeWait;

sca;  



function A = CenterRect_bw(A,c)
	A = A + repmat(c,size(A,1),1);
end  
