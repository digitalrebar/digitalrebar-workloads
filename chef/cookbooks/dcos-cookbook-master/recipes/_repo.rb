#
# Cookbook Name:: dcos
# Recipe:: _repo
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

remote_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-mesosphere' do
  owner 'root'
  group 'root'
  mode '0644'
  source node['dcos']['el-repo']['pubkey']
  checksum node['dcos']['el-repo']['pubkey_hash']
end

rpm_package 'dcos-el-repo' do
  source node['dcos']['el-repo']['rpm']
end
