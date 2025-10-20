#!/bin/bash

#git branch --edit-description # the first line will be the subject of cover letter generated below
#git format-patch --base=auto --cover-letter --subject-prefix "PATCH net-next" -v10 --signoff origin/main -o outgoing_v10
#git format-patch --base=auto --cover-letter -v11 --signoff origin/main -o outgoing_v11
#git format-patch --base=auto --cover-letter -v17 --signoff linux-next/master -o outgoing_v17

#./scripts/checkpatch.pl --strict --codespell outgoing/*.patch
#./scripts/get_maintainer.pl outgoing/*.patch

git send-email \
  --to=dualli@google.com \
  --to=corbet@lwn.net \
  --to=davem@davemloft.net \
  --to=edumazet@google.com \
  --to=kuba@kernel.org \
  --to=pabeni@redhat.com \
  --to=donald.hunter@gmail.com \
  --to=gregkh@linuxfoundation.org \
  --to=arve@android.com \
  --to=tkjos@android.com \
  --to=maco@android.com \
  --to=joel@joelfernandes.org \
  --to=brauner@kernel.org \
  --to=cmllamas@google.com \
  --to=surenb@google.com \
  --to=omosnace@redhat.com \
  --to=shuah@kernel.org \
  --to=arnd@arndb.de \
  --to=masahiroy@kernel.org \
  --to=bagasdotme@gmail.com \
  --to=horms@kernel.org \
  --to=tweek@google.com \
  --to=paul@paul-moore.com \
  --to=linux-kernel@vger.kernel.org \
  --to=linux-doc@vger.kernel.org \
  --to=netdev@vger.kernel.org \
  --to=selinux@vger.kernel.org \
  --to=linux-security-module@vger.kernel.org \
  --to=hridya@google.com \
  --cc=smoreland@google.com \
  --cc=ynaffit@google.com \
  --cc=kernel-team@android.com \
  --validate \
  --no-signed-off-by-cc \
  --suppress-cc=all \
  --confirm=cc \
  --in-reply-to="" \
  --dry-run \
  outgoing_v17_resend/*.patch

#  --dry-run \
