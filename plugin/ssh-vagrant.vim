function! s:sshVagrantMachineRun()
  :ruby << EOF
EOF
endfunction
 
command SSHVagrantMachineRun :call <SID>sshVagrantMachineRun()
