#! /bin/bash 

TARGET=$1
filename=$(basename "$TARGET")
FILENAME="${filename%.*}"

if [ -d "$HOME/.docker/machine/machines/$FILENAME" ] ; then
  echo "that machine already exists"
  exit 0
fi

# cleanup
rm -r ~/$FILENAME

# extract
unzip $TARGET -d ./$FILENAME

# add correct $HOME var
cat ./$FILENAME/config.json | sed -e "s:{{HOME}}:$HOME:g" > ./$FILENAME/config.json.fixed
mv ./$FILENAME/config.json.fixed ./$FILENAME/config.json

mkdir -p $HOME/.docker/machine/machines/$FILENAME

# move it into docker machines files
cp -r ./$FILENAME $HOME/.docker/machine/machines/

# update the stupid raw driver
machine-driverfix $FILENAME

echo "ok!"
