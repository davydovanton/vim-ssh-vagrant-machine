ssh-vagrant-machine.vim
=======================

Плагин позволяет выполнять любые команды в вашей vagrant машине(в директории /vagrant/), используя ssh. 
Результат выполнения команд может быть либо записан в ноый файл(по умолчанию) или отобразиться в info области.
Для выбора вывода по умолчанию следует указать:

    `let g:ssh_vagrant_machine_uotput_type = '<params>'`

Где `<params>` может принимать 2 значения: `info` - для info области и `new_tab` - для создания нового таба с новым файлом в который будет записан вывод вызываемой вами команды.

Пока реализованны команды:

`SSHVagrantMachineRun("<command>")` - выполняет указанную комманду.

`SSHVagrantMachineRunRspec`  - запускает rspec.

`SSHVagrantMachineRunRoutes` - отображает все роуты вашего rails приложения.


Так же, пока задаются в ручную значения username, hostname, password для ssh соединения( переменные `ssh_vagrant_machine_hostname`, `ssh_vagrant_machine_username`, `ssh_vagrant_machine_password` соответственно).

Для работы плагина требуется гем `net-ssh-session`
  
     `gem install net-ssh-session`


Installation
------------

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/fikys/vim-ssh-vagrant-machine.git

Once help tags have been generated, you can view the manual with
`:help surround`.

Contributing
------------

See the contribution guidelines for
[pathogen.vim](https://github.com/tpope/vim-pathogen#readme).

License
-------

Copyright (c) Anton Davydov.  Distributed under the same terms as Vim itself.
See `:help license`.
