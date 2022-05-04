% load all files
clear; addpath('psignifit');

% Subjects = {'BW','XY','MKE','BH','MH'};
Subjects = {'BW','XY','MKE','BH'};
dot_lengths = 500; %dot_lengths = [250, 500, 700];
curve_x = linspace(0.3,0.7,1000);
Curves = NaN(numel(Subjects),numel(dot_lengths),numel(curve_x));

all_P_reds = []; all_conf = [];
% ax = np;
Colors_sub = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560];
for isubject = 1:numel(Subjects)

	Colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
	% ax = np(numel(dot_lengths),1); 

	for l_dot = dot_lengths
	% for l_dot = 500
		[P_reds,resp_lr,rt_rep,confidence_rep] = load_data(['../../Results/' Subjects{isubject} '_' num2str(l_dot)]);
		% result = fit_psych(resp_lr,P_reds); % fit psychometric curve

		all_P_reds = [all_P_reds;P_reds];
		all_conf   = [all_conf; confidence_rep'];
		% plot confidence rating with psychometric curve
			% plt_curve_conf(result,P_reds,confidence_rep,ax(l_dot==dot_lengths),'c',Colors_sub(isubject,:));
			% ax.YAxis(1).Color = 'k'; ax.YAxis(2).Color = 'k';
			% set(gcf,'Position',[0 0 250 500]);

		% plot confidence rating heatmap
			% plt_confidence(P_reds,confidence_rep,result,ax(l_dot==dot_lengths));
			% set(gcf,'Position',[0 0 250 600]);
			% title(ax(l_dot==dot_lengths),sprintf('%d ms',l_dot));


		% get fit for all subjects
			% [~,Curves(cellfun(@(x) strcmp(x,Subjects{isubject}),Subjects),l_dot==dot_lengths,:)] = get_y(result,curve_x);

		% plot psychmetric curve
			% data_color = Colors(l_dot==dot_lengths,:);
			% hdata = scatter(result.data(:,1),result.data(:,2)./result.data(:,3),'filled','SizeData',sqrt(30000./sum(result.data(:,3)).*result.data(:,3)),'MarkerEdgeColor','none','MarkerFaceColor',data_color,'MarkerFaceAlpha',0.5);
			% fitline(l_dot==dot_lengths) = plot(result.x,result.y,'Color',data_color);
	    
	end
	
	% export_fig(sprintf('../Results/confidence_curve_%s.png',Subjects{isubject}),'-m3');
	% legend(fitline,{'250','500','700'});
	% title(subjectID);
end
return
save tmp P_reds resp_lr rt_rep confidence_rep result




%% psychometric curve + confidence 
	load('../Results/all_conf.mat');
	load('../Results/all_curves.mat');
	sub_ind = [1 2 3 4 5];
	Colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];


	% calculate points
	all_P_reds = all_P_reds(:);
	all_conf   = all_conf(:);
	bin_edges = 0.3:0.05:0.7;
	p_bin = discretize(all_P_reds,bin_edges);
	Ps = bin_edges(1:end-1) + (bin_edges(2)-bin_edges(1))/2;
	% calculate curve
	sample_ind = 1:249:1000;
	sample_y   = squeeze(Curves(sub_ind,:,sample_ind));
	M = squeeze(mean(sample_y(:,2,:),1));
	V = squeeze(std(sample_y(:,2,:),[],1));

	ax = np;

	% average trace
	yyaxis(ax,'left');
	h_1 = plot(ax,curve_x,squeeze(mean(Curves(sub_ind,2,:),1)),'-','Color',[1 0 0]);
	errorbar(ax,curve_x(sample_ind),M,V,'.','Color',[1 0 0],'MarkerSize',10,'LineStyle','none','LineWidth',1);

	h_2 = plot(ax,curve_x,1-squeeze(mean(Curves(sub_ind,2,:),1)),'-','Color',[0 1 0]);
	errorbar(ax,curve_x(sample_ind),1-M,V,'.','Color',[0 1 0],'MarkerSize',10,'LineStyle','none','LineWidth',1);

	set(ax,'YTick',0:0.2:1,'YLim',[0 1.25]);
	ylabel(ax,'% response');
	ax.YAxis(1).Color = [0 0 0];


	% confidence dots
	yyaxis(ax,'right');
	for ip = 1:numel(p_bin)
		for conf = 1:5
			sz = sum((p_bin==ip)&(all_conf==conf));
			if (sz>0)
				h = scatter(ax,Ps(ip),conf,sz*10,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',0.3,'MarkerEdgeColor','none');
			end
		end
	end
	ax.YAxis(2).Color = [0 0 0];
	ylabel(ax,{'confidence rating'});
	set(ax,'YTick',1:5,'YLim',[0 7]);

	% figure setting
	xlabel(ax,'% red dots');
	l = legend([h_1 h_2 h],{'Red Response','Green Response','# trs'});


return

%% average psychometric curve
	sub_ind = [1 2 3 4 5];

	ax = np(numel(sub_ind)+1);
	arrayfun(@(i) plot(ax(i==sub_ind),curve_x,squeeze(Curves(i,:,:))), sub_ind);
	arrayfun(@(i) title(ax(i==sub_ind),Subjects{i}), sub_ind);

	% average trace
	h = plot(ax(end),curve_x,squeeze(mean(Curves(sub_ind,:,:),1)));

	% pick sample x
	sample_ind = 1:249:1000;
	sample_y   = squeeze(Curves(sub_ind,:,sample_ind));
	% plot actual errorbar
	Colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
	arrayfun(@(i) errorbar(ax(end),curve_x(sample_ind),squeeze(mean(sample_y(:,i,:),1)),squeeze(std(sample_y(:,i,:),[],1)),'.','Color',Colors(i,:),'MarkerSize',10,'LineStyle','none','LineWidth',1), 1:3);
	title(ax(end),'average');
	legend(h,arrayfun(@(x) num2str(x), dot_lengths, 'UniformOutput',false));

	% use my custom script
		% ax = np; Colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
		% arrayfun(@(i) plot_multiple_lines(squeeze(Curves(sub_ind,i,:)),ax,'base_color',Colors(i,:)), 1:3);


%% separate plotting of response
	ax = np;
	data_color = [0 0 1];
	hdata = scatter(result.data(:,1),result.data(:,2)./result.data(:,3),'filled','SizeData',sqrt(30000./sum(result.data(:,3)).*result.data(:,3)),'MarkerEdgeColor','none','MarkerFaceColor',data_color,'MarkerFaceAlpha',0.5);
	plot(result.x,result.y,'Color',data_color);

% quick analysis of response
% repeated_p = unique(P_reds(i_tr_start+1:end));
% plot(repeated_p,arrayfun(@(x) sum(resp_lr(P_reds==x)==80)/sum(P_reds==x), repeated_p));
% arrayfun(@(x) sum(P_reds==x), repeated_p);
% plot(unique(P_reds),arrayfun(@(x) sum(P_reds==x), unique(P_reds)));