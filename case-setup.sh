#!/bin/bash
# Requirement: Debian 11.1 (bullseye)

set -Eeuxo pipefail

: "${BASE_DIR:=$HOME/CASE}"
: "${SIREUM_INIT_V:=20211209.0919}"
: "${SIREUM_V:=d9f6de056e52566a4be092aa8371daf8bb5f99b5}"
: "${AGREE_V:=agree_2.8.0}"
: "${BRIEFCASE_V:=briefcase_0.7.0}"
: "${ECLIPSE_V:=2021-03}"
: "${AWAS_V:=1.2022.01051723.29d9922}"
: "${HAMR_V:=1.2022.01051723.29d9922}"
: "${OSATE_V:=2.10.2-vfinal}"
: "${RESOLUTE_V:=resolute_3.0.0}"
: "${FMIDE_V:=latest}" # or fixed

export DEBIAN_FRONTEND=noninteractive
export SIREUM_HOME=$BASE_DIR/Sireum
export PATH=$PATH:$HOME/bin:$SIREUM_HOME/bin/linux/java/bin:$SIREUM_HOME/bin:$BASE_DIR/camkes/build/capDL-tool

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

ROOT_CMD=""
if command_exists sudo; then
    ROOT_CMD='sudo -E bash -c'
elif command_exists su; then
    ROOT_CMD='su -c'
else
    cat >&2 <<-'EOF'
    Error: this installer needs the ability to run commands as root.
    We are unable to find either "sudo" or "su" available to make this happen.
EOF
    exit 1
fi

as_root() {
    set +x
    local shell_cmd
    local cmd
    local user
    cmd=( "$@" )
    shell_cmd='bash -c'
    user="$(id -un 2>/dev/null || true)"

    if [ "$user" != 'root' ]; then
        shell_cmd="$ROOT_CMD"
    fi
    printf -v cmd_str '%s ' "${cmd[@]}"
    set -x
    $shell_cmd "$cmd_str"
}

mkdir -p $BASE_DIR

as_root apt-get update
as_root apt install -y git


# seL4
if [[ -z "${NO_SEL4}" ]]; then
  if [[ ! -z "${NO_SEL4_BOX}" ]]; then
    bash $HOME/bin/sel4.sh
  fi
fi

echo 'en_US.UTF-8 UTF-8' | as_root tee /etc/locale.gen > /dev/null
as_root dpkg-reconfigure --frontend=noninteractive locales
echo "LANG=en_US.UTF-8" | as_root tee -a /etc/default/locale > /dev/null
echo "export LANG=en_US.UTF-8" >> "$HOME/.bashrc"
export LANG=en_US.UTF-8


# Sireum
bash $HOME/bin/sireum-install.sh $SIREUM_INIT_V $SIREUM_V
echo "export SIREUM_HOME=$SIREUM_HOME" >> "$HOME/.bashrc"
echo "export JAVA_HOME=\$SIREUM_HOME/bin/linux/java" >> "$HOME/.bashrc"
echo "export PATH=\$PATH:\$JAVA_HOME/bin:\$SIREUM_HOME/bin" >> "$HOME/.bashrc"


# FMIDE
if [[ -z "${NO_FMIDE}" ]]; then
  bash $SIREUM_HOME/bin/install/fmide.cmd --agree $AGREE_V --briefcase $BRIEFCASE_V --eclipse $ECLIPSE_V --hamr $HAMR_V --awas $AWAS_V --osate $OSATE_V --resolute $RESOLUTE_V $FMIDE_V
  echo "export PATH=\$PATH:\${SIREUM_HOME}/bin/linux/fmide" >> "$HOME/.bashrc"
fi


# Examples
if [[ -z "${NO_EXAMPLES}" ]]; then
  bash $HOME/bin/examples.sh
fi


# CLion
if [[ ! -z "${WITH_CLION}" ]]; then
  bash $SIREUM_HOME/bin/install/clion.cmd
fi


# CompCert
if [[ ! -z "${WITH_COMPCERT}" ]]; then
  as_root apt install -y unzip zip libgmp-dev
  bash $SIREUM_HOME/bin/install/compcert.cmd
fi
