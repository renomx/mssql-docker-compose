RESTORE DATABASE [AdventureWorksLT2019]
        FROM DISK=N'/var/opt/mssql/backup/AdventureWorksLT2019.bak'
        WITH NORECOVERY,
        MOVE N'AdventureWorksLT2012_Data' TO N'/var/opt/mssql/data/AdventureWorksLT2019.mdf',
        MOVE N'AdventureWorksLT2012_Log' TO N'/var/opt/mssql/data/AdventureWorksLT2019.ldf';