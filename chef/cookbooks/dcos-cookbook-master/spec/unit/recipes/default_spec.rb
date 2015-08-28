#
# Cookbook Name:: dcos
# Spec:: default
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

describe 'dcos::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'installs dcos-installer package' do
      expect(chef_run).to install_package('dcos-installer')
    end

    it 'install mesosphere GPG key' do
      expect(chef_run).to create_remote_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-mesosphere')
    end

    it 'install dcos-el-repo package' do
      expect(chef_run).to install_rpm_package('dcos-el-repo')
    end

    it 'creates dcos-config /etc directory' do
      expect(chef_run).to create_directory('/etc/mesosphere/setup-packages/dcos-config--setup/etc')
    end

    it 'creates mesosphere setup-flags directory' do
      expect(chef_run).to create_directory('/etc/mesosphere/setup-flags')
    end

    it 'creates mesosphere roles directory' do
      expect(chef_run).to create_directory('/etc/mesosphere/roles')
    end

    it 'includes the docker recipe' do
      expect(chef_run).to include_recipe('dcos::_docker')
    end

    it 'enables the dcos-setup service' do
      expect(chef_run).to run_execute('systemctl enable dcos-setup')
    end

    it 'starts the dcos-setup service' do
      expect(chef_run).to run_execute('systemctl start dcos-setup')
    end
  end
end
