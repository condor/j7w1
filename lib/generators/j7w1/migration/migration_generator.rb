require 'rails/generators'
require 'rails/generator/migration'

module J7W1
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc "This generator provides the tables which the J7W1 uses."

    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        migration_number = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        migration_number += 1
        migration_number.to_s
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    def create_migration_file
      if self.class.orm_has_migration?
        migration_template 'migration.rb', 'db/migrate/j7w1_application_devices'
      end
    end
    
  end
end
