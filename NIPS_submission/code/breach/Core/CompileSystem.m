function CompileSystem(Sys)
%COMPILESYSTEM compiles the C function defining the dynamics, enabling
% simulations. Prerequisites are the presence in the current directory of
% properly defined files dynamics.cpp, dynamics.h and dynamics.mk
% 
% Synopsis: CompileSystem(Sys)
% 
% Input:
%  - Sys  system structure, usually created by CreateSystem script
%

h = waitbar(0,'Compiling System, please wait...');

try
    % find out host architecture
    
    ext = mexext;
    switch(ext)
        case {'mexw64', 'mexw32'}
            obj_ext = '.obj';
        otherwise
            obj_ext = '.o';
    end
    
    dr = which('Breach');
    breach_dir = dr(1:end-14);
    
    breach_src_dir = [breach_dir filesep 'Core' filesep 'src'];
    
    sundials_dir = [breach_dir filesep 'Toolboxes' filesep 'sundials'];
    sundials_inc_dir = [sundials_dir filesep 'include'];
    sundials_cvodes_src_dir = [sundials_dir filesep 'src' filesep 'cvodes'];
    sundials_nvm_src_dir = [sundials_dir filesep 'sundialsTB' filesep 'nvector' filesep 'src'];
    cvodesTB_src_dir =  [breach_dir filesep 'Core' filesep 'cvodesTB++' filesep 'src'];
    
    % Blitz
    
    blitz_inc_dir = [breach_dir filesep 'Toolboxes' filesep 'blitz' filesep 'include'];
    blitz_lib = [breach_dir filesep 'Toolboxes' filesep 'blitz' filesep 'lib' filesep 'libblitz' obj_ext];
    
    % out directories
    
    obj_out_dir = [breach_src_dir  filesep 'obj'];
    cv_obj_out_dir = [breach_src_dir  filesep 'cv_obj'];
    sys_src_dir = Sys.Dir;
    
    % flags
    
    switch(ext)
        case {'mexw64', 'mexw32'} % (for Windows 64 and 32 bits resp.)
            compile_flags = [' -DDIMX=' int2str(Sys.DimX) ' '];
        case {'mexglx', 'mexa64'} % (for Linux 32 and 64 bits resp.)
            compile_flags = [' -DDIMX=' int2str(Sys.DimX) ' -D_DEBUG=0' ' -cxx '];
        otherwise % mexmac, mexmaci, mexmaci64 (for Mac PowerPC, intel 32 bits and intel 64 bits resp.) ; mexsol (for Solaris)
            compile_flags = [' -DDIMX=' int2str(Sys.DimX) ' '];
    end
    
    inc_flags = [' -I' qwrap(sys_src_dir) ...
        ' -I' qwrap(breach_src_dir) ...
        ' -I' qwrap(sundials_inc_dir) ...
        ' -I' qwrap(sundials_cvodes_src_dir) ...
        ' -I' qwrap(cvodesTB_src_dir) ...
        ' -I' qwrap(sundials_nvm_src_dir) ...
        ' -I' qwrap(blitz_inc_dir) ...
        ' -I' qwrap([blitz_inc_dir filesep 'blitz']) ...
        ];
    
    % source files
    
    cvodesTB_src_files = [qwrap([cvodesTB_src_dir filesep 'cvmFun.cpp']) ...
        qwrap([cvodesTB_src_dir filesep 'cvmWrap.cpp']) ...
        qwrap([cvodesTB_src_dir filesep 'cvmOpts.cpp']) ...
        ];
    
    cv_obj_files = [
        qwrap([cv_obj_out_dir filesep 'cvmFun' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodea' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes_dense' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes_spbcgs' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'nvector_serial' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'sundials_dense' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'sundials_smalldense' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvmOpts' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes_band' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes_diag' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes_spgmr' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'nvm_ops' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'sundials_iterative' obj_ext ])  ...
        qwrap([cv_obj_out_dir filesep 'sundials_spbcgs' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvmWrap' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes_bandpre' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes_io' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes_spils' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'nvm_serial' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'sundials_math' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'sundials_spgmr' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodea_io' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes_bbdpre' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'cvodes_sptfqmr' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'sundials_band' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'sundials_nvector' obj_ext])  ...
        qwrap([cv_obj_out_dir filesep 'sundials_sptfqmr' obj_ext]) ];
    
    
    src_files = [qwrap([sys_src_dir filesep 'dynamics.cpp']) ...
        qwrap([breach_src_dir filesep 'mextools.cpp']) ...
        qwrap([breach_src_dir filesep 'traj.cpp']) ...
        qwrap([breach_src_dir filesep 'param_set.cpp']) ...
        qwrap([breach_src_dir filesep 'breach.cpp']) ...
        ];
    
    obj_files = [qwrap([obj_out_dir filesep 'dynamics' obj_ext ]) ...
        qwrap([obj_out_dir filesep 'mextools' obj_ext ]) ...
        qwrap([obj_out_dir filesep 'traj' obj_ext ]) ...
        qwrap([obj_out_dir filesep 'param_set' obj_ext ]) ...
        qwrap([obj_out_dir filesep 'breach' obj_ext ]) ...
        ];
    
    % compile commands
    
    compile_cvodes_cmd = ['mex -c -outdir ' qwrap(cv_obj_out_dir) ' ' compile_flags ' ' inc_flags ' ' cvodesTB_src_files ];
    compile_obj_cmd = ['mex -c -outdir ' qwrap(obj_out_dir) ' ' compile_flags ' ' inc_flags ' ' src_files ];
    compile_cvm_cmd = ['mex -output cvm ' compile_flags obj_files cv_obj_files qwrap(blitz_lib) ];
    
    % execute commands
    
    waitbar(1 / 4);
    cd(sys_src_dir);
    fprintf([regexprep(compile_cvodes_cmd,'\','\\\\') '\n' ]);
    eval(compile_cvodes_cmd);
    waitbar(2 / 4);
    fprintf([regexprep(compile_obj_cmd,'\','\\\\') '\n']);
    eval(compile_obj_cmd);
    waitbar(3 / 4);
    fprintf([regexprep(compile_cvm_cmd,'\','\\\\') '\n']);
    eval(compile_cvm_cmd);
    waitbar(4 / 4);
    close(h);
    
catch ME
    close(h);
    warndlg(['Problem during compilation ! Last error reported: ' ME.message] )
end

end

function qst = qwrap(st)
% necessary for dealing with £¨% spaces in dirnames...

qst = ['''' st ''' '];

end
