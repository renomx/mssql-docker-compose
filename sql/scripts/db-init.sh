#!bin/bash

echo "#######    STARTED CONFIGURATION   #######"

SLEEP_TIME=$INIT_WAIT

#run the setup script to create the DB and the schema in the DB
#if this is the primary node, remove the certificate files.
#if docker containers are stopped, but volumes are not removed, this certificate will be persisted
echo "<#############>    IS_AOAG_PRIMARY: ${IS_AOAG_PRIMARY}    <#############>"
#if [ $IS_AOAG_PRIMARY = "true" ]
#then
#     SQL_SCRIPT="aoag_primary.sql"
#     #rm /var/opt/mssql/shared/aoag_certificate.key 2> /dev/null
#     #rm /var/opt/mssql/shared/aoag_certificate.cert 2> /dev/null
#     rm $SHARED_PATH/aoag_certificate.key 2> /dev/null
#     rm $SHARED_PATH/aoag_certificate.cert 2> /dev/null

# else
#     SQL_SCRIPT="aoag_secondary.sql"
# fi

BAK_FILE="AdventureWorksLT2019.bak"

echo "<#############>    Moving Backup File ${BAK_FILE} to ${BACKUP_PATH}    <#############>"
mv  $BAK_FILE $BACKUP_PATH

sleep ${SLEEP_TIME}

echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
. ~/.bashrc
if [ "$IS_AOAG_PRIMARY" = 1 ]
then
    SQL_SCRIPT="restore_primary.sql"

    echo "<#############>   moving db1 restore script ${SCRIPTS_PATH}   <#############>"
    mv $SQL_SCRIPT $SCRIPTS_PATH

    echo "---> Restoring AdventureWorksLT2019 on db1 using port $TCP_PORT using $SCRIPTS_PATH/$SQL_SCRIPT"
    echo "<#############>    running set up script ${SQL_SCRIPT}    <#############>"
    sqlcmd -S localhost,$TCP_PORT -U sa -P $SA_PASSWORD -d master -i "$SCRIPTS_PATH/$SQL_SCRIPT" -C
 else
    SQL_SCRIPT="restore_secondary.sql"

    echo "---> Restoring AdventureWorksLT2019 on db2 using port $TCP_PORT using $SCRIPTS_PATH/$SQL_SCRIPT"
    echo "<#############>   moving db2 restore script ${SCRIPTS_PATH}   <#############>"
    mv $SQL_SCRIPT $SCRIPTS_PATH

    echo "<#############>    running set up script ${SQL_SCRIPT}    <#############>"
    sqlcmd -S localhost,$TCP_PORT -U sa -P $SA_PASSWORD -d master -i "$SCRIPTS_PATH/$SQL_SCRIPT" -C
fi

# systemctl restart mssql-server.service

# #wait for the SQL Server to come up
# echo "<#############>    Sleeping for ${SLEEP_TIME} seconds ..."
# sleep ${SLEEP_TIME}

# #use the SA password from the environment variable
# echo "<#############>    running set up script ${SQL_SCRIPT}"
# /opt/mssql-tools/bin/sqlcmd \
#     -S localhost,$TCP_PORT \
#     -U sa \
#     -P $SA_PASSWORD \
#     -d master \
#     -i $SQL_SCRIPT

# # create failove sql agent job
# echo "<#############>    running sql agent failover job"
# /opt/mssql-tools/bin/sqlcmd \
#     -S localhost,$TCP_PORT \
#     -U sa \
#     -P $SA_PASSWORD \
#     -d master \
#     -i "aoag_failover_job.sql"



# systemctl restart mssql-server.service

echo "#######     COMPLETED CONFIGURATION    #######"