
# Rails Multi-Database Best Practices Roundup

For full details, please read the blog post here: http://technology.customink.com/blog/2015/06/22/rails-multi-database-best-practices-roundup

### Rails 4.2.x

Please use the [3-2-stable](https://github.com/customink/encom_dbs/tree/3-2-stable) branch for Rails 3.2.x.

### Setup

First bundle install and then create the default DBs.

```
$ bundle install
$ bundle exec rake db:create:all
$ bundle exec rake db:setup
```

### SecondBase Integration Tests

* db:drop:all - SUCCESS! (all envs)
* db:create:all - SUCCESS! (all envs)
* db:create - SUCCESS! (only dev/test envs)
* db:drop - SUCCESS! (only dev/test envs)

