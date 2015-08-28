#
# Cookbook Name:: dcos
# Recipe:: default
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

include_recipe 'dcos::_repo'

package 'dcos-installer'

include_recipe 'dcos::_docker'

include_recipe 'dcos::_config'

execute 'systemctl enable dcos-setup'

execute 'systemctl start dcos-setup'

execute 'wait for leader' do
  command 'ping -c 1 leader.mesos'
  retries 1800
  retry_delay 1
end

log 'dcos-started' do
  message 'DCOS node initialized successfully'
end
