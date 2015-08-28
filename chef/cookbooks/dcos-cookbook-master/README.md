# Mesosphere DCOS #

The Mesosphere DCOS cookbook deploys and configures multi-node deployments of DCOS on Red Hat/CentOS 7.1.

## Requirements ##

Red Hat or CentOS 7.1.

## Usage ##

The cookbook is primarily driven by attributes documented in the [attributes file](attributes/default.rb). The `node['dcos']['roles']` attribute is a list of DCOS roles to apply to the node (default is `slave`), you can create a Chef role and apply it to nodes as necessary to specify `master`, `slave` and `slave_public` as appropriate. Any additional configuration should probably be set as override attributes in an Environment to ensure all nodes receive those global settings.

### Example Role dcos_master.rb ###
````ruby
name "dcos_master"
description "DCOS master role"
run_list "recipe[dcos]"
default_attributes "dcos" => { "roles" => [ "master" ] }
````

## Recipes ##

This `default` recipe is the "public" recipe for DCOS configuration and deployment. The other recipes are not intended to be used stand-alone and are driven by this recipe. The basic workflow for this recipe is:

1. includes `dcos::_repo` to add the yum repository
1. installs the `dcos-installer` package
1. includes `dcos::_docker` to enable and start the `docker` service
1. includes `dcos::_config` to create the directories, files and templates configuring DCOS
1. starts `dcos-setup` in systemd
1. waits for the leader and exits

## Testing ##

To run all the tests ensure you have the [ChefDK](https://downloads.chef.io/chef-dk/), [Vagrant](https://www.vagrantup.com/) and [VirtualBox](virtualbox.org) installed.

### ChefSpec ###

There are [ChefSpec](https://docs.chef.io/chefspec.html) tests for unit testing this cookbook. To execute them use the command

    chef exec rspec

### Test Kitchen ###

The `.kitchen.yml` for this cookbook supports running the 2 configuration variations on CentOS 7.1 (`standalone` and `master`) and provides examples for potential configurations. To see the available integration tests:

    chef exec kitchen list

and to run them (this may take > 20 minutes)

    chef exec kitchen converge

and to clean up when complete

    chef exec kitchen destroy

For more information please refer to the command line help or the [Chef Documentation for Test Kitchen](https://docs.chef.io/kitchen.html).

## Contributing ##
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors ##
- Author:: Kennon Kwok (<kennon@chef.io>)
- Author:: Matt Ray (<matt@chef.io>)

```text
Copyright 2015 Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
