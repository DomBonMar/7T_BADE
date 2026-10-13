function out = PROC_view_moco(runs,runtype,INDIR,OUTDIR)

% generates plot to view average motion per run
% GOAL: coregister to the run with least motion

out = 1;
N_RUNS = length(runs);

fprintf("Generating plot for %s motion\n",runtype)

for r = 1:N_RUNS

    [~,file,~] = fileparts(runs(r));
    filename = sprintf('%s/rp_%s.txt',INDIR,file);
    moco_info = load(filename);
    
    subplot(1,N_RUNS,r)
    plot(moco_info)
    title(sprintf('Motion for %s',file))

end

% saves figure as plot
saveas(gcf, sprintf("%s/moco-details-%s.jpg",OUTDIR,runtype));

out = 0;

end