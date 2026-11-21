# pico-sdk

added as submodule here

we're just using this to build the picodvi so there's no point installing it globally.

to build the pico-sdk:

```sh
cd pico-sdk
git submodule update --init  
cmake -S . -B build
```

# picodvi

added as sumbodule here

```sh
cd picodvi/software
mkdir build
cd build
PICO_SDK_PATH=../../../pico-sdk cmake -DPICO_COPY_TO_RAM=1 ..
```