" ssh-vagrant-machine.vim - Run commands in vagrant machine
" Author:       Anton Davydov <http://fikys.github.io/>
" Version:      0.1

if !exists('g:ssh_vagrant_machine_uotput_type')
  let g:ssh_vagrant_machine_uotput_type = 'new_tab'
endif

if !exists('g:ssh_vagrant_machine_username')
  let g:ssh_vagrant_machine_username = 'deployer'
endif

if !exists('g:ssh_vagrant_machine_password')
  let g:ssh_vagrant_machine_password = 'password'
endif

if !exists('g:ssh_vagrant_machine_environment')
  let g:ssh_vagrant_machine_environment = 'dev'
endif

function! s:sshVagrantMachineRunInitialize()
ruby <<EOF
  $username    = VIM::evaluate "g:ssh_vagrant_machine_username"
  $password    = VIM::evaluate "g:ssh_vagrant_machine_password"
  $output_type = VIM::evaluate "g:ssh_vagrant_machine_uotput_type"
  $environment = VIM::evaluate "g:ssh_vagrant_machine_environment"
EOF
endfunction

function! s:sshVagrantMachineRun(command)
  call <SID>sshVagrantMachineRunInitialize()

  ruby SSHVagrantMachine.new($hostname, $username, $password, $output_type).run_command VIM::evaluate "a:command" 
endfunction
command -nargs=1 SSHVagrantMachineRun :call <SID>sshVagrantMachineRun(<f-args>)

function! s:sshVagrantMachineRunRoutes()
  call <SID>sshVagrantMachineRunInitialize()

  ruby SSHVagrantMachine.new($hostname, $username, $password, $output_type).run_routes
endfunction
command SSHVagrantMachineRunRoutes :call <SID>sshVagrantMachineRunRoutes()

function! s:sshVagrantMachineRunRspec()
  call <SID>sshVagrantMachineRunInitialize()

  ruby SSHVagrantMachine.new($hostname, $username, $password, $output_type).run_rspec
endfunction
command SSHVagrantMachineRunRspec :call <SID>sshVagrantMachineRunRspec()

ruby << EOF
require 'net/ssh/session'

class SSHVagrantMachine
  def initialize(hostname, username, password, output_type)
    @username    = username
    @password    = password
    @output_type = output_type
    @environment = $environment
  end

  def run_command(command)
    @hostname    = get_hostname
    session = Net::SSH::Session.new(@hostname, @username, @password)
    session.open
    session.run('cd /vagrant')
    VIM::command 'tabedit' if @output_type == 'new_tab'
    session.run(command) do |part| 
      part.each_line do |line|
        line = line.gsub(/[\n\r]/, "")
        case @output_type
        when 'new_tab'
          VIM::Buffer.current.append(VIM::Buffer.current.count, line)
        when 'info'
          puts line
        end
      end
    end
    session.close
  rescue
    puts 'Error SSH connections!'
  end

  def run_rspec
    run_command 'rspec'
  end

  def run_routes
    run_command 'rake routes'
  end

  private
    def get_hostname
      VIM::command 'let g:ssh_vagrant_machine_user_path = getcwd()'
      @project_path = VIM::evaluate "g:ssh_vagrant_machine_user_path"
      @file = File.open("#{@project_path}/Vagrantfile", "r")
      @data = @file.read
      @file.close
      @data = @data[/#{@environment}.vm.network.*/][/\".*\"/].gsub(/\"/, "")
    end
end
EOF
