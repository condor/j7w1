require 'rails/generators'
require 'rails/generators/migration'

module J7W1
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    class_option :from_11, type: :boolean, default: :false,
      desc: 'Generates migration script from v0.0.11 or earlier.'


    def self.orm
      Rails::Generators.options[:rails][:orm]
    end

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', (orm.to_s unless orm.class.eql?(String)) )
    end

    def self.orm_has_migration?
      [:active_record].include? orm
    end

    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        migration_number = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        migration_number += 1
        migration_number.to_s
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    desc "This generator provides the tables which the J7W1 uses."
    def create_migration_file
      if self.class.orm_has_migration?
        if options['from_11']
          migration_template 'migration_from_11e.rb', 'db/migrate/add_j7_w1_application_devices_disabled'
        else
          migration_template 'migration.rb', 'db/migrate/create_j7_w1_application_devices'
        end
      end
    end
    
  end
end
