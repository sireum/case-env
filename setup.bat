vagrant destroy
where git >nul 2>nul
IF ERRORLEVEL 0 (
  git log -n 1 --date=format:%Y%m%d --pretty=format:%cd.%h > vm-version.txt 2> nul
)
set FIRST_RUN=true
vagrant up --no-provision
vagrant ssh -c 'bash /vagrant/snapshot.sh'
vagrant ssh -c 'sudo apt update'
vagrant ssh -c 'sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y'
vagrant ssh -c 'sudo DEBIAN_FRONTEND=noninteractive apt install -y build-essential linux-headers-amd64 linux-image-amd64 python-pip'
vagrant halt
set FIRST_RUN=false
vagrant up || exit /b
vagrant reload
