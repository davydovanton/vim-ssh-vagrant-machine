ruby_file ssh_vagrant_machine.rb

function! s:sshVagrantMachineRun()
  if !exists('g:ssh_vagrant_machine_uotput_type')
    let g:ssh_vagrant_machine_uotput_type = 'new_tab'
  endif

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

  hostname = '10.0.0.200'
  username = 'deployer'
  password = 'password'
  output_type = VIM::evaluate "g:ssh_vagrant_machine_uotput_type"

  machine = SSHVagrantMachine.new(hostname, username, password, output_type)
  machine.run_ls_all

EOF
endfunction
 
command SSHVagrantMachineRun :call <SID>sshVagrantMachineRun()
