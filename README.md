Knife Joyent
===

This is a [Knife](http://wiki.opscode.com/display/chef/Knife) plugin for Joyent CloudAPI. This plugin gives knife
the ability to create, bootstrap, and manage servers on the [Joyent Public Cloud](http://www.joyentcloud.com/) as well as Cloud providers powered by Joyent's [SmartDataCenter](http://www.joyent.com/products/smartdatacenter/) product offering.

For more information on Joyent CloudAPI, see: [CloudAPI Documentation](http://api.joyentcloud.com/docs)

## Installation

With chef already installed ``(> 0.10.0)``:

    gem install knife-joyent

## Usage

For a list of commands:

    knife joyent --help

Currently available commands:

    knife joyent flavor list <options>
    knife joyent image list <options>
    knife joyent key add -f <keyfile> -k <name>
    knife joyent key delete <name>
    knife joyent key list
    knife joyent server create (options)
    knife joyent server delete <server_id>
    knife joyent server list <options>
    knife joyent server reboot <server_id>
    knife joyent server resize <server_id> -f <flavor>
    knife joyent server start <server_id>
    knife joyent server stop <server_id>
    knife joyent server metadata update <server_id> -m <json>
    knife joyent server metadata delete <server_id> <options>
    knife joyent snapshot create <server_id> <snapshot_name>
    knife joyent snapshot delete <server_id> <snapshot_name>
    knife joyent snapshot list <server_id>
    knife joyent tag create <server_id> <tag> <value>
    knife joyent tag delete <server_id> <tag>
    knife joyent tag delete <server_id> -A
    knife joyent tag list <server_id>

## Example Usage

The following command will provision an Ubuntu 12.04 with 1GB of memory and bootstrap it with chef

    knife joyent server create \
        --flavor "Small 1GB" \
        --image d2ba0f30-bbe8-11e2-a9a2-6bc116856d85 \
        --node-name 'chefbuntu-x' \
        --server-name 'chefbuntu-x'

Please see ``knife joyent server create --help`` for more options

## Configuration

The following options can be specified in your knife configuration file
``knife.rb``

#### Required

You can authenticate against CloudAPI using either:

a username and password

    knife[:joyent_username] = "Your Joyent CloudAPI username"
    knife[:joyent_password] = "Your Joyent CloudAPI password"

or, your ssh key

    knife[:joyent_username] = "Your Joyent CloudAPI username"
    knife[:joyent_keyname] = "Name of key stored on Joyent"
    knife[:joyent_keyfile] = "/path/to/your/private/key"

#### Optional

**joyent_api_url**

Specify a custom API endpoint, this is required if you want to specify
where you want to provision your machines, or if you are using knife with a
provider powered by [SmartDataCenter](http://www.joyent.com/products/smartdatacenter/).

    # Defaults to https://us-west-1.api.joyentcloud.com/
    knife[:joyent_api_url] = "https://us-sw-1.api.joyentcloud.com/"

**joyent_metadata**

Metadata to apply to each provisioned machine via the Metadata API. This should take
the form of a hash with a single level of nesting. See the
[Metadata API](http://wiki.joyent.com/wiki/display/sdc/Using+the+Metadata+API) for more info.

    knife[:joyent_metadata] = {
      "some_data" => "value"
    }

**provisioner**

Machines provisioned will be tagged with key ``provisioner`` containing the value specified.
This is useful for tracking source of provisions for accounts where machines are provisioned
by/from different sources / users.

## Contributors

 - [Sean Omera](https://github.com/someara) - Opscode
 - [Eric Saxby](https://github.com/sax) - ModCloth
 - [Stephen Lauck](https://github.com/stephenlauck) - ModCloth

## Chef for smartos

To bootstrap chef on SmartOS, use this [bootstrap template](https://gist.github.com/stephenlauck/3836791)

## License

Copyright 2012 Joyent, Inc

Author: Kevin Chan <kevin@joyent.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
