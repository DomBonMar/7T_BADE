function out = PROC_view_moco(runs,runtype,OUTDIR)

% generates plot to view average motion per run
% GOAL: coregister to the run with least motion

out = 1;
N_RUNS = length(runs);

fprintf("Generating plot for %s motion\n",runtype)

for r = 1:N_RUNS

    [~,filename,~] = fileparts(runs(r));
    filename = sprintf('%s/rp_%s.txt',FUNCDIR,filename);
    moco_info = load(filename);
    
    subplot(1,r,r)
    plot(moco_info)
    title(sprintf('Motion for %s run %d',runtype,r))

end

% saves figure as plot
saveas(gcf, sprintf("%s/moco-details-%s.jpg",OUTDIR,runtype));

out = 0;

end