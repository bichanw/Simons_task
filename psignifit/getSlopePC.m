function slope = getSlopePC(result, pCorrect, unscaled)
% function slope = getSlopePC(result, pCorrect, unscaled)
% This function finds the slope of the psychometric function at a given
% performance level in percent correct.
%
% result is a result struct from psignifit.
%
% pCorrect is the proportion correct where to evaluate the slope (in [0,1]).
% 
% By default this function uses the percent correct of the function scaled
% by the asymptotes, i.e. the final psychometric function. 
%
% If you want to pass values on the original sigmoid scaling from 0 to 1
% instead, pass a true for unscaled.
%
% This function cannot provide credible intervals. 

if ~exist('unscaled','var') || isempty(unscaled)
    unscaled = false;
end

if isstruct(result)
    theta0 = result.Fit;
else
    error('Result needs to be a result struct generated by psignifit');
end


if unscaled 
    assert((pCorrect>0) && (pCorrect<1), 'The threshold percent correct is not reached by the sigmoid!')
    pCorrectUnscaled = pCorrect;
else
    assert(pCorrect>theta0(4) && pCorrect<(1-theta0(3)), 'The threshold percent correct is not reached by the sigmoid!')
    pCorrectUnscaled = (pCorrect-theta0(4))./(1-theta0(3)-theta0(4));
end

%% calculate point estimate -> transform only result.Fit

alpha = result.options.widthalpha;
if isfield(result.options,'threshPC')
    PC    = result.options.threshPC;
else
    PC = 0.5;
end

if strcmp(result.options.sigmoidName(1:3),'neg')
    pCorrectUnscaled = 1-pCorrectUnscaled;
    PC = 1-PC;
end

% find the (normalized) stimulus level, where the given percent correct is
% reached and evaluate slope there
switch result.options.sigmoidName
    case {'norm','gauss','neg_norm','neg_gauss'}   % cumulative normal distribution
        C         = my_norminv(1-alpha,0,1) - my_norminv(alpha,0,1);
        normalizedStimLevel = my_norminv(pCorrectUnscaled, 0, 1);
        slopeNormalized = my_normpdf(normalizedStimLevel);
        slope = slopeNormalized *C./theta0(2);
    case {'logistic','neg_logistic'}         % logistic function
        stimLevel = theta0(1)-theta0(2)*(log(1/pCorrectUnscaled-1)-log(1/PC-1))/2/log(1/alpha-1);
        C = 2 * log(1./alpha - 1) ./ theta0(2);
        d = log(1/PC-1);
        slope = C.*exp(-C.*(stimLevel-theta0(1))+d)./(1+exp(-C.*(stimLevel-theta0(1))+d)).^2;
    case {'gumbel','neg_gumbel'}           % gumbel
        % note that gumbel and reversed gumbel definitions are sometimesswapped
        % and sometimes called extreme value distributions
        C      = log(-log(alpha)) - log(-log(1-alpha));
        stimLevel = log(-log(1-pCorrectUnscaled));
        slope = C./theta0(2).*exp(-exp(stimLevel)).*exp(stimLevel);
    case {'rgumbel','neg_rgumbel'}          % reversed gumbel
        % note that gumbel and reversed gumbel definitions are sometimesswapped
        % and sometimes called extreme value distributions
        C      = log(-log(1-alpha)) - log(-log(alpha));
        stimLevel = log(-log(pCorrectUnscaled));
        slope = -C./theta0(2).*exp(-exp(stimLevel)).*exp(stimLevel);
    case {'logn','neg_logn'}             % cumulative lognormal distribution
        C      = my_norminv(1-alpha,0,1) - my_norminv(alpha,0,1);
        stimLevel = exp(my_norminv(pCorrectUnscaled, theta0(1)-my_norminv(PC,0,theta0(2)./C), theta0(2) ./ C));
        normalizedStimLevel = my_norminv(pCorrectUnscaled, 0, 1);
        slopeNormalized = my_normpdf(normalizedStimLevel);
        slope = slopeNormalized *C./theta0(2)./stimLevel; 
        
    case {'Weibull','weibull','neg_Weibull','neg_weibull'} % Weibull
        C      = log(-log(alpha)) - log(-log(1-alpha));
        stimLevel = exp(theta0(1)+theta0(2)/C*(log(-log(1-pCorrectUnscaled))-log(-log(1-PC))));
        stimLevelNormalized = log(-log(1-pCorrectUnscaled));
        slope = C./theta0(2).*exp(-exp(stimLevelNormalized)).*exp(stimLevelNormalized);
        slope = slope./stimLevel;
    case {'tdist','student','heavytail','neg_tdist','neg_student','neg_heavytail'}
        % student T distribution with 1 df
        %-> heavy tail distribution
        C      = (my_t1icdf(1-alpha) - my_t1icdf(alpha));
        stimLevel = my_t1icdf(pCorrectUnscaled);
        slope = C./theta0(2).*tpdf(stimLevel,1);
    otherwise
        error('unknown sigmoid function');
end

slope = (1-theta0(3)-theta0(4))*slope;

if strcmp(result.options.sigmoidName(1:3),'neg')
    slope = -slope;
end
