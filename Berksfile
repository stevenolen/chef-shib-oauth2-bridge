source 'https://supermarket.chef.io'

metadata

cookbook 'httpd', '= 0.3.1'

group :integration do
  cookbook 'mysql', '~> 6.0'
  cookbook 'yum', '~> 3.8.0'
  cookbook 'shib_oauth2_bridge_test', path: 'test/fixtures/cookbooks/shib_oauth2_bridge_test'
end
