### some notes, nothing very thrilling

we're just using this to build the picodvi so there's no point installing it globally.

to build the pico-sdk:

```sh
cd pico-sdk
git submodule update --init  
cmake -S . -B build
```