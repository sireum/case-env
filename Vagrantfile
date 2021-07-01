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

  config.vm.provision "shell", privileged: false, env: {
      "BASE_DIR" => ENV['BASE_DIR'],
      "SIREUM_INIT_V" => ENV['SIREUM_INIT_V'],
      "SIREUM_V" => ENV['SIREUM_V'],
      "AGREE_V" => ENV['AGREE_V'],
      "BRIEFCASE_V" => ENV['BRIEFCASE_V'],
      "ECLIPSE_V" => ENV['ECLIPSE_V'],
      "HAMR_V" => ENV['HAMR_V'],
      "OSATE_V" => ENV['OSATE_V'],
      "RESOLUTE_V" => ENV['RESOLUTE_V'],
      "FMIDE_V" => ENV['FMIDE_V'],
      "SEL4_SCRIPTS_V" => ENV['SEL4_SCRIPTS_V'],
      "SEL4_V" => ENV['SEL4_V'],
      "CAMKES_V" => ENV['CAMKES_V'],
      "NO_SEL4" => ENV['NO_SEL4'],
      "NO_CAKEML" => ENV['NO_CAKEML'],
      "NO_FMIDE" => ENV['NO_FMIDE'],
      "NO_EXAMPLES" => ENV['NO_EXAMPLES'],
      "WITH_SIREUM_IVE" => ENV['WITH_SIREUM_IVE'],
      "WITH_CLION" => ENV['WITH_CLION'],
      "WITH_COMPCERT" => ENV['WITH_COMPCERT'],
  }, inline: <<-SHELL
    echo "BASE_DIR=$BASE_DIR"
    echo "SIREUM_INIT_V=$SIREUM_INIT_V"
    echo "SIREUM_V=$SIREUM_V"
    echo "AGREE_V=$AGREE_V"
    echo "BRIEFCASE_V=$BRIEFCASE_V"
    echo "ECLIPSE_V=$ECLIPSE_V"
    echo "HAMR_V=$HAMR_V"
    echo "OSATE_V=$OSATE_V"
    echo "RESOLUTE_V=$RESOLUTE_V"
    echo "FMIDE_V=$FMIDE_V"
    echo "SEL4_SCRIPTS_V=$SEL4_SCRIPTS_V"
    echo "SEL4_V=$SEL4_V"
    echo "CAMKES_V=$CAMKES_V"
    echo "NO_SEL4=$NO_SEL4"
    echo "NO_CAKEML=$NO_CAKEML"
    echo "NO_FMIDE=$NO_FMIDE"
    echo "NO_EXAMPLES=$NO_EXAMPLES"
    echo "WITH_SIREUM_IVE=$WITH_SIREUM_IVE"
    echo "WITH_CLION=$WITH_CLION"
    echo "WITH_COMPCERT=$WITH_COMPCERT"
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
