Knife Joyent
===

This is a Knife plugin for Joyent CloudAPI. This plugin gives knife
the ability to create, bootstrap, and manage servers on the Joyent Public Cloud
as well as Cloud providers powered by Joyent's SmartDataCenter product.

## Installation

With chef already installed (> 0.10.0):

    gem install knife-joyent

## Help

    $ knife joyent --help
    Available joyent subcommands: (for details, knife SUB-COMMAND --help)

    ** JOYENT COMMANDS **
    knife joyent flavor list <options>
    knife joyent image list <options>
    knife joyent key add -f <keyfile> -k <name>
    knife joyent key delete -k <name>
    knife joyent machine list <options>
    knife joyent server list <options>

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
