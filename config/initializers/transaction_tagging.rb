EncomDbs32::Application.configure do
  config.after_initialize do

    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
      private
      def begin_db_transaction
        execute "BEGIN -- Base"
      end
      def commit_db_transaction
        execute "COMMIT -- Base"
      end
      def rollback_db_transaction
        execute "ROLLBACK -- Base"
      end
      def create_savepoint
        execute("SAVEPOINT #{current_savepoint_name} -- Base")
      end
      def rollback_to_savepoint
        execute("ROLLBACK TO SAVEPOINT #{current_savepoint_name} -- Base")
      end
      def release_savepoint
        execute("RELEASE SAVEPOINT #{current_savepoint_name} -- Base")
      end
    end

    ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.class_eval do
      private
      def begin_db_transaction
        execute "BEGIN -- MySQL"
      rescue Exception
      end
      def commit_db_transaction
        execute "COMMIT -- MySQL"
      rescue Exception
      end
      def rollback_db_transaction
        execute "ROLLBACK -- MySQL"
      rescue Exception
      end
      def create_savepoint
        execute("SAVEPOINT #{current_savepoint_name} -- MySQL")
      end
      def rollback_to_savepoint
        execute("ROLLBACK TO SAVEPOINT #{current_savepoint_name} -- MySQL")
      end
      def release_savepoint
        execute("RELEASE SAVEPOINT #{current_savepoint_name} -- MySQL")
      end
    end

    ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
      private
      def begin_db_transaction
        exec_query "BEGIN -- MySQL"
      rescue Mysql::Error
      end
    end

  end
end

