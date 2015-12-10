require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class ShibOauth2Bridge < Chef::Provider::LWRPBase
      # Chef 11 LWRP DSL Methods
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      # Mix in helpers from libraries/helpers.rb
      include ShibOauth2BridgeCookbook::Helpers

      action :create do
        httpd_service_name = 'shib-oauth2-bridge-' + new_resource.name
        httpd_service httpd_service_name do
          listen_ports ["#{new_resource.port}"]
          action [:create, :start]
        end

        httpd_module 'rewrite' do
          instance httpd_service_name
          action :create
        end

        link '/usr/lib64/httpd/modules/mod_shib.so' do
          to '/usr/lib64/shibboleth/mod_shib_22.so'
        end
        
        httpd_config 'shib-bridge' do
          instance httpd_service_name
          source 'auth.conf.erb'
          cookbook 'shib-oauth2-bridge'
          variables(
            name: httpd_service_name,
            hostname: new_resource.hostname,
            port: new_resource.port
          )
          notifies :restart, "httpd_service[#{httpd_service_name}]"
          action :create
        end

        app_path = "/var/www/#{httpd_service_name}"
        %w(config/local vendor storage).each do |d|
          directory "#{app_path}/shared/#{d}" do
            recursive true
          end
        end

        execute "download/install composer" do
          cwd "#{app_path}/shared"
          command 'curl -sS https://getcomposer.org/installer | php'
          not_if { ::File.exist?("#{app_path}/shared/composer.phar") }
        end

        # app.php
        template "#{app_path}/shared/config/app.php" do
          source 'app.php.erb'
          cookbook 'shib-oauth2-bridge'
          notifies :restart, "httpd_service[#{httpd_service_name}]"
        end

        # database.php
        template "#{app_path}/shared/config/database.php" do
          source 'database.php.erb'
          cookbook 'shib-oauth2-bridge'
          variables(
            db_password: new_resource.db_password,
            db_user: new_resource.db_user,
            db_name: new_resource.db_name,
            db_host: new_resource.db_host,
            db_port: new_resource.db_port
          )
          notifies :restart, "httpd_service[#{httpd_service_name}]"
        end

        bridge_resource = new_resource
        deploy_branch bridge_resource.name do
          deploy_to app_path
          repo bridge_resource.repo
          revision bridge_resource.revision
          symlink_before_migrate(
            'config/app.php' => 'app/config/local/app.php',
            'config/database.php' => 'app/config/local/database.php',
            'composer.phar' => 'composer.phar',
            'vendor' => 'vendor',
            'storage' => 'app/storage'
          )
          migrate true
          migration_command "php composer.phar install; php artisan migrate --package='lucadegasperi/oauth2-server-laravel' --env=local; php artisan migrate --env=local"
          purge_before_symlink %w(config/local vendor storage)
          before_symlink do
            execute 'db:seed' do
              cwd release_path
              command "php artisan db:seed --env=local; touch #{app_path}/shared/.seeded"
              not_if { ::File.exist?("#{app_path}/shared/.seeded") }
            end
          end
          restart_command "service httpd-#{httpd_service_name} restart"
        end

        # insert clients into db. wow this is awkward.
        new_resource.clients.each do |c|
          execute "insert client" do
            command insert_client_query(c)
            not_if { client_exists?(c) }
          end
        end
      end
    end
  end
end
