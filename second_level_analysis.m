% Second-level analysis
% grouping data from all subjects

% metadata
%SUBS = {'pilot02','pilot03','U101','U102','U103','U104'};
SUBS = {'U101','U102','U103','U104'};
CONTRASTS = {'Confirm - Baseline', 'Disconfirm - Baseline', 'Disconfirm - Confirm'};
ROIS = {'VC','ACC'};
NUM_LAYERS = 10;
RUN_TYPE = 'bold';

% relevant directories
BASEDIR = '/data/lavlab/layer-7t-predictive-coding';
OUTDIR = sprintf('%s/unpublished-results',BASEDIR);
CODEDIR = sprintf('%s/code',BASEDIR);
DATADIR = sprintf('%s/data',BASEDIR);
addpath(genpath(CODEDIR));

% analysis dirs
FLADIR = sprintf('%s/first-level-analysis',OUTDIR);
MASKDIR = sprintf('%s/layer-masks',OUTDIR);

%% 1.1: LOADING PROFILE ACTIVATION DETAILS

MEANS = zeros(length(SUBS),length(ROIS),length(CONTRASTS),NUM_LAYERS);
SDS = zeros(length(SUBS),length(ROIS),length(CONTRASTS),NUM_LAYERS);

for s = 1:length(SUBS)

    % retrieves subject info
    sub = SUBS{s};
    SUBDIR = sprintf('%s/sub-%s/%s',MASKDIR,sub,RUN_TYPE);

    for r = 1:length(ROIS)
        for c = 1:length(CONTRASTS)

            % locates profile details
            filename = sprintf('%s/%s-profile-c%d.txt',SUBDIR,ROIS{r},c);
            INFO = load(filename);

            MEANS(s,r,c,:) = INFO(:,2);
            SDS(s,r,c,:) = INFO(:,3); 

        end
    end
end

%% 1.2: PLOTTING ACTIVATION PATTERNS

ROI_LIMITS = [2,1];

for r = 1:length(ROIS)
    for c = 1:length(CONTRASTS)

        tmp_means = squeeze(MEANS(:,r,c,:)); % subs x activation matrix
        tmp_sds = squeeze(SDS(:,r,c,:)); % subs x activation matrix
        subplot(length(ROIS),length(CONTRASTS),length(CONTRASTS)*(r-1)+c)

        % plot each subject separately
        for s = 1:length(SUBS)

            %errorbar(1:NUM_LAYERS, tmp_means(s,:), tmp_sds(s,:),'Color','blue','LineStyle','--','Marker','+')
            plot(1:NUM_LAYERS,tmp_means(s,:),'Color','blue','LineStyle','--','Marker','+')
            hold on

        end

        % plot median among all subjects
        % ADD ERROR BARS TO THE MEAN
        plot(1:NUM_LAYERS,mean(tmp_means),'Color','black','Marker','o')
        title(sprintf('%s in %s',CONTRASTS{c},ROIS{r}))

        % FIX PLOT SCALES TO HAVE THEM ALL EQUAL [make this better for future]
        ylim([-1,ROI_LIMITS(r)])

    end
end