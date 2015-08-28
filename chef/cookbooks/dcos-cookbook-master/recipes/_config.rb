#
# Cookbook Name:: dcos
# Recipe:: _config
#
# Copyright 2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

directory '/etc/mesosphere/setup-packages/dcos-config--setup/etc' do
  recursive true
end

directory '/etc/mesosphere/setup-flags'

directory '/etc/mesosphere/roles'

node['dcos']['roles'].each do |role|
  file "/etc/mesosphere/roles/#{role}" do
    action :create
  end
end

template '/etc/mesosphere/setup-flags/repository-url' do
  source 'repository-url.erb'
end

template '/etc/mesosphere/setup-packages/dcos-config--setup/pkginfo.json' do
  source 'pkginfo.json.erb'
end

template '/etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-dns.json' do
  source 'mesos-dns.json.erb'
end

template '/etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-master' do
  source 'mesos-master.erb'
end

template '/etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-slave' do
  source 'mesos-slave.erb'
end

template '/etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-slave-public' do
  source 'mesos-slave-public.erb'
end

template '/etc/mesosphere/setup-packages/dcos-config--setup/etc/cloudenv' do
  source 'cloudenv.erb'
  user 'root'
  group 'root'
  mode 600
end

template '/etc/mesosphere/setup-packages/dcos-config--setup/etc/exhibitor' do
  source 'exhibitor.erb'
end
