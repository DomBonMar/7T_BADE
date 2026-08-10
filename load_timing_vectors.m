% reads timing vector files

CODEDIR = '/data/lavlab/layer-7t-predictive-coding/code/';

N_RUNS = 3;
CONDITIONS = ["confirm", "disconfirm","baseline"];
SUB = "pilot02";

filename = sprintf("%s%s_timing_vectors_v4.mat",CODEDIR,SUB);
data = load(filename);

% use data.{SUB}_run{X}_{condition} to index the timing vectors
%%
% merge all the data across 3 conditions
for cond = CONDITIONS
    full_data.(cond) = [];
    for run = 1:N_RUNS
        label = sprintf("%s_run%d_%s",SUB,run,cond);
        tps = data.(label);
        full_data.(cond) = horzcat(full_data.(cond),tps);
    end
end
