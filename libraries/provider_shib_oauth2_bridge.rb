require 'chef/provider/lwrp_base'
# require_relative 'helpers'

class Chef
  class Provider
    class ShibOauth2Bridge < Chef::Provider::LWRPBase
      # Chef 11 LWRP DSL Methods
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      # Mix in helpers from libraries/helpers.rb
      # include ShibOauth2BridgeCookbook::Helpers

      action :create do
        httpd_service_name = 'shib-oauth2-bridge-' + new_resource.name
        httpd_service httpd_service_name do
          action [:create, :start]
        end

        httpd_module 'rewrite' do
          instance httpd_service_name
          action :create
        end
        
        httpd_config 'shib-bridge' do
          instance httpd_service_name
          source 'auth.conf.erb'
          cookbook 'shib-oauth2-bridge'
          variables(
            name: httpd_service_name
          )
          # notifies :restart, "service[httpd-#{httpd_service_name}]"
          action :create
        end

        directory "/var/www/#{httpd_service_name}" do
          recursive true
        end
      end
    end
  end
end
