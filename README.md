Haipa Vagrant Provider
=================================


`vagrant-haipa` is a Vagrant provider plugin that supports the management of Hyper-V virtual machines with [Haipa](http://www.haipa.io).

Features include:
- Create and destroy Haipa Machines
- Power on and off Haipa Machines


Install
-------
Install the provider plugin using the Vagrant command-line interface:

`vagrant plugin install vagrant-haipa`


Configure
---------
Once the provider has been installed, you will need to configure your project to use it. See the following example for a basic `Vagrantfile` implementation:

```ruby
  config.vm.define :ubuntu do |ubuntu|
    ubuntu.vm.provider :haipa do |provider|
      provider.vm_config = {
         'Memory' => {
          'Startup' => 2048
        },
        'Disks' => [
          {
            "Template" => 'c:\hyperv-templates\ubuntu-xenial.vhdx',
            "Size" => 20
          }
        ],  
        'NetworkAdapters' => [
          {
            "Name" => "eth0",
            "SwitchName" => "Default Switch",
          }                                                          
        ]
      }
    end
  end
end
```


**Supported Configuration Attributes**

The following attributes are available to further configure the provider:
- `provider.vm_config`
    * A Hash with the Haipa vm configuration
- `provider.provision`
    * A Hash with the Haipa provision configuration

Run
---
After creating your project's `Vagrantfile` with the required configuration
attributes described above, you may create a new Machine with the following
command:

    $ vagrant up --provider=haipa

This command will create a new machine, setup your SSH key for authentication,
create a new user account, and run the provisioners you have configured.

**Supported Commands**

The provider supports the following Vagrant sub-commands:
- `vagrant destroy` - Destroys the machine instance.
- `vagrant ssh` - Logs into the machine instance using the configured user account.
- `vagrant halt` - Powers off the machine instance.
- `vagrant provision` - Runs the configured provisioners and rsyncs any specified `config.vm.synced_folder`.
- `vagrant status` - Outputs the status (active, off, not created) for the machine instance.


Troubleshooting
---------------
Before submitting a GitHub issue, please ensure both Vagrant and vagrant-haipa are fully up-to-date.
* For the latest Vagrant version, please visit the [Vagrant](https://www.vagrantup.com/) website
* To update Vagrant plugins, run the following command: `vagrant plugin update`


Contribute
----------
To contribute, fork then clone the repository, and then the following:

**Developing**

1. Install [Bundler](http://bundler.io/)
2. Currently the Bundler version is locked to 1.7.9, please install this version.
    * `sudo gem install bundler -v '1.7.9'`
3. Then install vagrant-haipa dependencies:
    * `bundle _1.7.9_ install`
4. Do your development and run a few commands, one to get started would be:
    * `bundle _1.7.9_ exec vagrant haipa-list images`
5. You can then run a test:
    * `bundle _1.7.9_ exec rake test`
6. Once you are satisfied with your changes, please submit a pull request.

**Testing**

1. Build and package your newly developed code:
    * `rake gem:build`
2. Then install the packaged plugin:
    * `vagrant plugin install pkg/vagrant-haipa-*.gem`
3. Once you're done testing, roll-back to the latest released version:
    * `vagrant plugin uninstall vagrant-haipa`
    * `vagrant plugin install vagrant-haipa`
4. Once you're satisfied developing and testing your new code, please submit a pull request for review.
