#!/usr/bin/env bash
set -ex

echo $UID $GID $(whoami)

[ -z "$1" ] && echo "Cron job UID parameter not specified" && exit -1
[ -z "$2" ] && echo "Cron job GID parameter not specified" && exit -2

### extract year, month, day to create sub-directories and format date to append to backup name.
T_STAMP=$(date -u  "+%Y%m%d_%H%M%SZ")
echo "current timestamp is: ${T_STAMP}"

BACKUP_ROOT="/mnt_dir"
BACKUP_ROOT_DST="${BACKUP_ROOT}/9.dst"

ls -la "${BACKUP_ROOT}"     ||true
ls -la "${BACKUP_ROOT_DST}" ||true

[ -d "${BACKUP_ROOT_DST}" ] || exit -4

if [ "${USE_DATE_IN_DEST}" == "1" ]; then
    CURRENT_YEAR="${T_STAMP:0:4}"
    CURRENT_MONTH="${T_STAMP:4:2}"
    CURRENT_DAY="${T_STAMP:6:2}"
    BACKUP_DIR_DST="${BACKUP_ROOT_DST}/${CURRENT_YEAR}/${CURRENT_MONTH}/${CURRENT_DAY}"
else
    BACKUP_DIR_DST="${BACKUP_ROOT_DST}"
fi

### create backups directory if not present
mkdir -p "${BACKUP_DIR_DST}"

ls -la "${BACKUP_DIR_DST}" ||true
[ -d "${BACKUP_DIR_DST}" ] || exit -5

## make sure folder is writeable by the user
## but not recursivelly (there may already be some files from previous backups in same day)
chown "$1":"$2" "${BACKUP_DIR_DST}"

echo "backup directory: ${BACKUP_DIR_DST}"

# BAK_ARCHIVE_NAME="${BACKUP_DIR_DST}/${BAK_NAME}.${T_STAMP}.tar.gz"


# -----------------------------------
### start creating mysqldump command
mongodump_cmd="mongodump "

if [ "${MONGODB__SSL_DISABLED}" != "yes" ]; then
    mongodump_cmd="${mongodump_cmd} --ssl --sslAllowInvalidCertificates"
fi

if [ "${MONGODB__REPLICATION_ENABLED}" == "yes" ]; then
    if [ -z "${MONGODB__REPLSET_NAME}" ]; then
        echo "Error: Missing replica set name!"
        exit -6
    fi
    if [ -z "${MONGODB__HOSTS}" ]; then
        echo "Error: Missing target Mongodb server host addresses!"
        exit -7
    fi

    mongodump_cmd="${mongodump_cmd} --host '${MONGODB__REPLSET_NAME}/${MONGODB__HOSTS}' "
else
    if [ -z "${MONGODB__HOSTS}" ]; then
        echo "Using localhost:27017 as the database to backup."
    else
        mongodump_cmd="${mongodump_cmd} --host '${MONGODB__HOSTS}'"
    fi
fi

[ -n "${MONGODB__USERNAME}" ] && mongodump_cmd="${mongodump_cmd} --username '${MONGODB__USERNAME}''"
[ -n "${MONGODB__PASSWORD}" ] && mongodump_cmd="${mongodump_cmd} --password '${MONGODB__PASSWORD}' "
[ -n "${MONGODB__AUTH_DB}"  ] && mongodump_cmd="${mongodump_cmd} --authenticationDatabase '${MONGODB__AUTHENTICATION_DB}' "


if [ "${MONGODB__BAK_ALL_DB}" == "1" ]; then
    echo "Dumping all databases..."
else
    if [ "${MONGODB__DB_NAME}" == "" ]; then
        echo "Error: Missing target Mongodb database name!"
        exit -8
    fi
    echo "Dumping only [${MONGODB__DB_NAME}] database..."

    mongodump_cmd="${mongodump_cmd} --db ${MONGODB__DB_NAME}"
fi

mongodump_cmd="${mongodump_cmd} --dumpDbUsersAndRoles"

mongodump_cmd="${mongodump_cmd} --gzip --archive ${BACKUP_DIRECTORY}/${BACKUP_NAME}.${T_STAMP}.mongoarch.gz"
echo "the final command is ${mongodump_cmd}"

### execute mongodump command, then archive the dump directory and remove the actual dump directory
eval "sudo -u '$1' -g '$2' ${mongodump_cmd}"
