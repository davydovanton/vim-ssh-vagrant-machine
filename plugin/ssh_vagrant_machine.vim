if !exists('g:ssh_vagrant_machine_uotput_type')
  let g:ssh_vagrant_machine_uotput_type = 'new_tab'
endif

if !exists('g:ssh_vagrant_machine_hostname')
  let g:ssh_vagrant_machine_hostname = '10.0.0.200'
endif

if !exists('g:ssh_vagrant_machine_username')
  let g:ssh_vagrant_machine_username = 'deployer'
endif

if !exists('g:ssh_vagrant_machine_password')
  let g:ssh_vagrant_machine_password = 'password'
endif

function! s:sshVagrantMachineRunInitialize()
ruby <<EOF
  $hostname    = VIM::evaluate "g:ssh_vagrant_machine_hostname"
  $username    = VIM::evaluate "g:ssh_vagrant_machine_username"
  $password    = VIM::evaluate "g:ssh_vagrant_machine_password"
  $output_type = VIM::evaluate "g:ssh_vagrant_machine_uotput_type"
EOF
endfunction

function! s:sshVagrantMachineRunLsAll()
  call <SID>sshVagrantMachineRunInitialize()

  ruby SSHVagrantMachine.new($hostname, $username, $password, $output_type).run_ls_all
endfunction
 
command SSHVagrantMachineRunLsAll :call <SID>sshVagrantMachineRunLsAll()

ruby << EOF
require 'net/ssh'

class SSHVagrantMachine
  def initialize(hostname, username, password, output_type)
    @hostname    = hostname
    @username    = username
    @password    = password
    @output_type = output_type
  end

  def run_command(command)
    ssh = Net::SSH.start(@hostname, @username, password: @password)
    @output = ssh.exec!("cd /vagrant/ && #{command}")
    VIM::command 'tabedit' if @output_type == 'new_tab'
    @output.each_line do |line| 
      line = line.gsub(/\n/, "")
      case @output_type
      when 'new_tab'
        VIM::Buffer.current.append(VIM::Buffer.current.count, line)
      when 'info'
        puts line
      end
    end
    ssh.close
  rescue
    puts 'Error SSH connections!'
  end

  def run_ls_all
    run_command 'ls -Al'
  end
end
EOF
