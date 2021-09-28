#!/bin/bash
set -Eeuxo pipefail

: "${GIT_USER:=Snail}"
: "${GIT_EMAIL:=<>}"
: "${BASE_DIR:=$HOME/CASE}"
: "${SEL4_SCRIPTS_V:=144c3f46fc8a5169b678b3da3552eedd26211ce2}"
: "${SEL4_V:=f52106a48a64953e889006b93ad3b9253457f72a}"
: "${CAMKES_V:=c77211b08f435a0fee79d18127f0d83ce49dfb80}"

export DESKTOP_MACHINE=no
export MAKE_CACHES=no
export DEBIAN_FRONTEND=noninteractive

git config --global user.name $GIT_USER
git config --global user.email $GIT_EMAIL
git config --global color.ui true

cd $BASE_DIR
git clone https://github.com/SEL4PROJ/seL4-CAmkES-L4v-dockerfiles
SEL4_SCRIPTS=$BASE_DIR/seL4-CAmkES-L4v-dockerfiles/scripts
cd $SEL4_SCRIPTS
git checkout $SEL4_SCRIPTS_V
sed -i 's/setuptools/"setuptools<58.0"/g' base_tools.sh
sed -i 's/setuptools/"setuptools<58.0"/g' sel4.sh
cd $BASE_DIR

bash $SEL4_SCRIPTS/base_tools.sh

bash $SEL4_SCRIPTS/sel4.sh

. $SEL4_SCRIPTS/utils/common.sh

bash $SEL4_SCRIPTS/camkes.sh
echo "export PATH=\$PATH:$BASE_DIR/camkes/build/capDL-tool" >> "$HOME/.bashrc"

# seL4 cache
rm -fR ~/.sel4_cache $BASE_DIR/sel4test
mkdir -p ~/.sel4_cache
try_nonroot_first mkdir -p "$BASE_DIR/sel4test" || chown_dir_to_user "$BASE_DIR/sel4test"
cd "$BASE_DIR/sel4test"
repo init -u "https://github.com/seL4/sel4test-manifest.git" --depth=1 -b $SEL4_V
repo sync -j 4
mkdir build-x86_64
mkdir build-odroidxu4
cd build-x86_64
../init-build.sh -DPLATFORM=x86_64
ninja
cd ../build-odroidxu4
../init-build.sh -DPLATFORM=exynos5422 -DAARCH32=1
ninja

# CAmkES cache
rm -fR $BASE_DIR/camkes
try_nonroot_first mkdir -p "$BASE_DIR/camkes" || chown_dir_to_user "$BASE_DIR/camkes"
cd "$BASE_DIR/camkes"
repo init -u "https://github.com/seL4/camkes-manifest.git" --depth=1 -b $CAMKES_V
repo sync -j 4
mkdir build
cd build
../init-build.sh
ninja

if [[ -z "${NO_CAKEML}" ]]; then
  bash $SEL4_SCRIPTS/cakeml.sh
fi

git config --global --unset user.name $GIT_USER
git config --global --unset user.email $GIT_EMAIL
