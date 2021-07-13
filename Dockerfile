FROM fluent/fluentd:v1.13.0-debian-1.0

USER root

RUN buildDeps="sudo make gcc g++ libc-dev" \
   && apt-get update \
   && apt-get install -y --no-install-recommends $buildDeps \
   && sudo apt-get install -y libmariadb-dev \
   && sudo gem install fluent-plugin-mysql-bulk \
   && sudo gem sources --clear-all \
   && SUDO_FORCE_REMOVE=yes

RUN apt-get purge -y --auto-remove \
   -o APT::AutoRemove::RecommendsImportant=false $buildDeps \
   && rm -rf /var/lib/apt/lists/* \
   && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

USER fluent
