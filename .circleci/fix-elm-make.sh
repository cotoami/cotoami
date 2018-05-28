#!/bin/bash

# https://github.com/elm-lang/elm-compiler/issues/1473#issuecomment-245704142
if [ ! -d ~/sysconfcpus/bin ]; then
  git clone https://github.com/obmarg/libsysconfcpus.git;
  cd libsysconfcpus;
  ./configure --prefix=$HOME/sysconfcpus;
  make && make install;
  cd ..;
fi

# replace elm-make https://github.com/elm-lang/elm-compiler/issues/1473#issuecomment-250637064
cd assets
if [ ! -f $(npm bin)/elm-make-old ]; then
  mv $(npm bin)/elm-make $(npm bin)/elm-make-old
  printf "#\041/bin/bash\n\necho \"Running elm-make with sysconfcpus -n 2\"\n\n$HOME/sysconfcpus/bin/sysconfcpus -n 2 elm-make-old \"\$@\"" > $(npm bin)/elm-make
  chmod +x $(npm bin)/elm-make
fi
