FROM ez123/db-mongo:3.6

MAINTAINER HighSkillz <webdev@highskillz.com>

COPY ./src/entrypoint /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["mongodump"]
