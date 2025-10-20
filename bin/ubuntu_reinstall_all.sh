# mkdir -p ~/vobs/github/eggonlea
# cd ~/vobs/github/eggonlea
# git clone git@github.com:eggonlea/tools.git

WHICH_PATH=`which $0`
echo "cmd : $WHICH_PATH"

REAL_PATH=`realpath $WHICH_PATH`
echo "real: $REAL_PATH"

BIN_DIR=`dirname $REAL_PATH`
echo "bin : $BIN_DIR"

BASE_DIR=`dirname $BIN_DIR`
echo "base: $BASE_DIR"

BAK_DIR=$BASE_DIR/bak
echo "bak : $BAK_DIR"

set -x

# personal tools and configuration
ln -f -s -T $BIN_DIR ~/bin
ln -f -s $BAK_DIR/*.desktop ~/.local/share/applications/
ln -f -s $BAK_DIR/bash_aliases ~/.bash_aliases
ln -f -s $BAK_DIR/gitconfig ~/.gitconfig
mkdir -p ~/.config/git
ln -s $BAK_DIR/gitignore_global ~/.config/git/ignore

sudo ln -s $BAK_DIR/51-android.rules /etc/udev/rules.d/

# general apps
sudo apt install meld vim byobu fcitx-pinyin fcitx fcitx-googlepinyin git-core repo

# Android dev apps
sudo apt-get install git-core gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig
