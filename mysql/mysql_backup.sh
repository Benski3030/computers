# Backup Mysql Databases

### Backup a single database
`mysqldump -u root -p database_name > database_name.sql`

### Backup multiple databases
`mysqldump -u root -p --databases database_name_a database_name_b > databases_a_b.sql`

### Backup all databases
`mysqldump -u root -p --all-databases > all_databases.sql`
