function [fitX,fitY] = get_y(result,fitX)
if nargin<2
    fitX = [];
end
extrapolLength = .2;
if result.options.logspace
    xOK = result.data(result.data(:,1)>0,1);
    xlength   = log(max(xOK))-log(min(xOK));
    if isempty(fitX) fitX = exp(linspace(log(min(xOK)),log(max(xOK)),1000)); end
    xLow      = exp(linspace(log(min(xOK))-extrapolLength*xlength,log(min(xOK)),100));
    xHigh     = exp(linspace(log(max(xOK)),log(max(xOK))+extrapolLength*xlength,100));
else
    xlength   = max(result.data(:,1))-min(result.data(:,1));
    if isempty(fitX) fitX = linspace(min(result.data(:,1)),max(result.data(:,1)),1000); end
    xLow      = linspace(min(result.data(:,1))-extrapolLength*xlength,min(result.data(:,1)),100);
    xHigh     = linspace(max(result.data(:,1)),max(result.data(:,1))+extrapolLength*xlength,100);
end
fitY = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),fitX)+result.Fit(4);

end
