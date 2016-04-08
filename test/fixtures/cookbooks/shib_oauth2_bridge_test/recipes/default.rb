include_recipe 'shib-oauth2-bridge::shibd'
include_recipe 'shib-oauth2-bridge::shib-ds'
include_recipe 'yum-epel'

mysql_service 'default' do
  port '3306'
  version '5.6'
  initial_root_password 'changeme'
  action [:create, :start]
end

execute 'add test db info' do
  command "sleep 5s; /usr/bin/mysql -h 127.0.0.1 -uroot -pchangeme -e \"CREATE DATABASE IF NOT EXISTS auth; GRANT ALL ON auth.* to 'auth' identified by 'tsktsk';\""
end

yum_repository 'remi' do
  description 'Les RPM de Remi - Repository'
  mirrorlist 'http://rpms.famillecollet.com/enterprise/6/remi/mirror'
  gpgkey 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'
  action :create
end

yum_repository 'remi-php55' do
  description 'Les RPM de Remi PHP55 - Repository'
  mirrorlist 'http://rpms.famillecollet.com/enterprise/6/php55/mirror'
  gpgkey 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'
  action :create
end

%w(php php-mcrypt php-mysql php-mbstring).each do |pkg|
  package pkg
end

shib_oauth2_bridge 'default' do
  clients [
    {id: 'app', name: 'app', secret: 'appsecret', redirect_uri: 'http://localhost:3000/auth/oauth2/shibboleth'},
    {id: 'app2', name: 'app2', secret: 'appsecret', redirect_uri: ['http://example.com', 'http://example.com/2']}
  ]
end
