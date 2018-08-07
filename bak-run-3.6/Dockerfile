FROM ez123/db-mongo:3.6

MAINTAINER HighSkillz <webdev@highskillz.com>

COPY ./src/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
# CMD ["mongodump"]
