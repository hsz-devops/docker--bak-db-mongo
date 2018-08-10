FROM ez123/cron:alpine
MAINTAINER HighSkillz <webdev@highskillz.com>

ENV \
    DUMP_CRONTAB="0 0 * * *" \
    DUMP_UID="0" \
    DUMP_GID="0" \
    USE_DATE_IN_DEST="1" \
    MONGODUMP_OPTIONS="" \
    DUMP_USER_IF_NEW=dumpcron \
    BAK_NAME="untitled"

COPY ./src/mongodump-entrypoint.sh /entrypoint.d/mongodump.sh
COPY ./src/run-mongodump.sh    /run-mongodump.sh

RUN set -x; \
    apk add --no-cache --update \
        sudo \
        bash \
        coreutils \
        mongodb-tools \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    \
    && chmod +x \
        /entrypoint.d/*.sh \
        /run-*.sh \
    && mkdir -p \
        /mnt_dir/9.dst \
    && chmod a+rwx \
        /mnt_dir \
        /mnt_dir/9.dst \
    && echo done...

VOLUME ["/mnt_dir/9.dst"]
