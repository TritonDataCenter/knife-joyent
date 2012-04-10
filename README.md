Knife Joyent
===

This is a Knife plugin for Joyent CloudAPI. This plugin gives knife
the ability to create, bootstrap, and manage servers on the Joyent Public Cloud
as well as Cloud providers powered by Joyent's SmartDataCenter product.

## Installation

With chef already installed (> 0.10.0):

    gem install knife-joyent

## Usage

For available commands:

    knife joyent --help

## Configuration

The following options can be specified in your knife configuration file

### Required

You can authenticate against CloudAPI using either:

a username and password

    knife[:joyent_username] = "Your Joyent CloudAPI username"
    knife[:joyent_password] = "Your Joyent CloudAPI password"

or, your ssh key

    knife[:joyent_username] = "Your Joyent CloudAPI username"
    knife[:joyent_keyname] = "Name of key stored on Joyent"
    knife[:joyent_keyfile] = "/path/to/your/private/key"

### Optional

    # Specify a custom API endpoint, this is required if you want to specify 
    # where you want to provision your machines, or if you are using knife with a
    # provider powered by SmartDataCenter.
    #
    # Defaults to https://us-west-1.api.joyentcloud.com/
    knife[:joyent_api_url] = "https://us-sw-1.api.joyentcloud.com/"

## License

Licensed under the Apache License, Version 2.0 (the “License”); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0
