require 'securerandom'

module ShibOauth2BridgeCookbook
  module Helpers
    include Chef::DSL::IncludeRecipe
    def insert_client_query(client)
      @query = delete_client_query(client)
      @query += "INSERT INTO oauth_clients (id, secret, name, created_at, updated_at) VALUES ('#{client[:id]}', '#{client[:secret]}', '#{client[:name]}', now(), now());"
      @query += "INSERT INTO oauth_client_endpoints (client_id, redirect_uri, created_at, updated_at) VALUES ('#{client[:id]}', '#{client[:redirect_uri]}', now(), now());"
      @query += "INSERT INTO oauth_client_scopes (client_id, scope_id, created_at, updated_at) VALUES ('#{client[:id]}', 1, now(), now());\""
      @query
    end
    def delete_client_query(client)
      @query = mysql_details
      @query += "\"delete from oauth_clients where id = '#{client[:id]}';" 
      @query += "delete from oauth_client_endpoints where client_id = '#{client[:id]}';"
      @query += "delete from oauth_client_scopes where client_id = '#{client[:id]}';"
      @query
    end
    def client_exists?(client)
      @query = mysql_details
      @query += "\"select count(*) from oauth_clients oc join oauth_client_endpoints oce join oauth_client_scopes ocs on (oc.id=oce.client_id AND oc.id=ocs.client_id)"
      @query += " where oc.id = '#{client[:id]}' and oc.secret = '#{client[:secret]}' and oc.name = '#{client[:name]}' and oce.redirect_uri = '#{client[:redirect_uri]}' and ocs.scope_id = 1;\""
      @cmd = Mixlib::ShellOut.new("#{@query}")
      @cmd.run_command
      @cmd.stdout.to_i == 1
    end
    def mysql_details
      @query = '/usr/bin/mysql'
      @query += " --host #{new_resource.db_host}"
      @query += " --port #{new_resource.db_port}"
      @query += " -u #{new_resource.db_user}"
      @query += " -p#{new_resource.db_password}"
      @query += " -D #{new_resource.db_name} -r -B -N -e"
      @query
    end
  end
end
