#
# Cookbook Name:: shibd
# Recipe:: default
#
# Copyright (C) 2015 Steve Nolen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
yum_repository 'security_shibboleth' do
  description 'Shibboleth (CentOS_CentOS-6)'
  baseurl 'http://download.opensuse.org/repositories/security:/shibboleth/CentOS_CentOS-6/'
  gpgkey 'http://download.opensuse.org/repositories/security:/shibboleth/CentOS_CentOS-6/repodata/repomd.xml.key'
  action :create
end

package 'shibboleth'

# add case statement to handle uctrust configs for next.
template '/etc/shibboleth/shibboleth2.xml' do
  source 'shibboleth2.xml.erb'
  owner 'shibd'
  group 'root'
  notifies :restart, 'service[shibd]', :delayed
end

template '/etc/shibboleth/attribute-map.xml' do
  source 'attribute-map.xml.erb'
  owner 'shibd'
  group 'root'
  notifies :restart, 'service[shibd]', :delayed
end

service 'shibd' do
  supports restart: true, status: true
  action [:enable, :start]
end
