#
# Cookbook Name:: dcos
# Spec:: _config
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

require 'spec_helper'

describe 'dcos::_config' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'creates repository-url from template' do
      expect(chef_run).to create_template('/etc/mesosphere/setup-flags/repository-url')
    end

    it 'creates pkginfo.json from template' do
      expect(chef_run).to create_template('/etc/mesosphere/setup-packages/dcos-config--setup/pkginfo.json')
    end

    it 'creates mesos-dns from template' do
      expect(chef_run).to create_template('/etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-dns.json')
    end

    it 'creates mesos-master from template' do
      expect(chef_run).to create_template('/etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-master')
    end

    it 'creates mesos-slave from template' do
      expect(chef_run).to create_template('/etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-slave')
    end

    it 'creates mesos-slave-public from template' do
      expect(chef_run).to create_template('/etc/mesosphere/setup-packages/dcos-config--setup/etc/mesos-slave-public')
    end

    it 'creates cloudenv from template' do
      expect(chef_run).to create_template('/etc/mesosphere/setup-packages/dcos-config--setup/etc/cloudenv').with(
        user: 'root',
        group: 'root',
        mode: 600
      )
    end

    it 'creates exhibitor from template' do
      expect(chef_run).to create_template('/etc/mesosphere/setup-packages/dcos-config--setup/etc/exhibitor')
    end
  end
end
