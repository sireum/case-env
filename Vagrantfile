# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  ENV['VAGRANT_INSTALL_LOCAL_PLUGINS'] = "true"
  
  config.vagrant.plugins = "vagrant-vbguest"

  config.vm.box = "bento/debian-10"
  config.vm.box_version = "202007.17.0"
  config.vm.provider :virtualbox do |vb|
    vb.cpus = 4
    vb.memory = 8092
    vb.gui = true
    vb.linked_clone = false
    vb.customize ["modifyvm", :id, "--vram", "64"]
    vb.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
  end

  if ENV['FIRST_RUN'] == 'true'
    config.vbguest.auto_update = false
  end

  config.vm.provision "file", source: "case-setup.sh", destination: "case-setup.sh"

  config.vm.provision "file", source: "addons", destination: "addons"

  config.vm.provision "file", source: "bin", destination: "bin"

  config.vm.provision "file", source: "vm-version.txt", destination: "vm-version.txt"

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    bash case-setup.sh || exit -1
    rm -R case-setup.sh addons
  SHELL

  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    adduser vagrant vboxsf
    echo "Installing xfce-desktop ..."
    tasksel install xfce-desktop
    #apt install -y materia-gtk-theme papirus-icon-theme
  SHELL

end
