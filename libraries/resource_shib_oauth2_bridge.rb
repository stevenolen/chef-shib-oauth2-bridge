require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class ShibOauth2Bridge < Chef::Resource::LWRPBase
      self.resource_name = :shib_oauth2_bridge
      actions :create, :delete
      default_action :create

      attribute :name, kind_of: String, name_attribute: true
      attribute :repo, kind_of: String, default: 'https://github.com/ucla/shib-oauth2-bridge.git'
      attribute :revision, kind_of: String, default: 'master'
      attribute :port, kind_of: Integer, default: 8080
      attribute :hostname, kind_of: String, default: 'localhost'
      attribute :db_host, kind_of: String, default: '127.0.0.1'
      attribute :db_port, kind_of: Integer, default: 3306
      attribute :db_name, kind_of: String, default: 'auth' # set to name attr?
      attribute :db_user, kind_of: String, default: 'auth'
      attribute :db_password, kind_of: String, default: 'tsktsk'
      attribute :clients, kind_of: Array, required: true
    end
  end
end
