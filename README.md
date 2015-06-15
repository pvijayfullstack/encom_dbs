
# Rails Multi-Database Best Practices Roundup

For full details, please read the blog post here: http://technology.customink.com/blog/2015/06/14/rails-multi-database-best-practices-roundup

### Setup

First bundle install and then create the default DBs.

```
$ bundle install
$ bundle exec rake db:create:all
$ bundle exec rake db:setup
```

Now create the secondary DBs.

```
$ echo "CREATE DATABASE encom_dbs_development" | mysql -u root &&
  echo "CREATE DATABASE encom_dbs_test" | mysql -u root &&
  echo "CREATE DATABASE encom_dbs_production" | mysql -u root

$ mysql -u root encom_dbs_development < db/encom_mysql.sql &&
  mysql -u root encom_dbs_test < db/encom_mysql.sql &&
  mysql -u root encom_dbs_production < db/encom_mysql.sql
```

