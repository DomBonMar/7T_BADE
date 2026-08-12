function save_and_run(fname,cmd,OUTDIR)

    % saves command into file and runs the process
    fid = fopen(fname,'w');
    fprintf(fid,'%s',cmd);
    fclose(fid);
    
    cd(OUTDIR)
    system(sprintf('source %s',fname))

end