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
Once the provider has been installed, you will need to configure your project to use it. See the following example for a basic multi-machine `Vagrantfile` implementation that manages two Haipa Machines:

```ruby
Vagrant.configure('2') do |config|

  config.vm.define "machine1" do |config|
      config.vm.provider :haipa do |provider, override|
        override.vm.box = 'haipa'
        override.vm.box_url = "https://github.com/haipa/vagrant-haipa/raw/master/box/haipa.box"
      end
  end

  config.vm.define "droplet2" do |config|
      config.vm.provider :digital_ocean do |provider, override|
        override.vm.box = 'haipa'
        override.vm.box_url = "https://github.com/haipa/vagrant-haipa/raw/master/box/haipa.box"
        override.nfs.functional = false
      end
  end
end
```

**Supported Configuration Attributes**

The following attributes are available to further configure the provider:
- `provider.image`
    * A string representing the image to use when creating a new machine. It defaults to `ubuntu-14-04-x64`.
    List available images with the `vagrant haipa-list images` command.

- `provider.region`
    * A string representing the region to create the new machine in. It defaults to `default`. List available regions with the `vagrant digitalocean-list regions` command.
- `provider.flavor`
    * A string representing the flavor to use when creating a new Droplet (e.g. `medium`). It defaults to `default`. List available sizes with the `vagrant haipa-list flavors` command.
- `provider.vm_config`
    * A Hash with the Haipa vm configuration


Run
---
After creating your project's `Vagrantfile` with the required configuration
attributes described above, you may create a new Droplet with the following
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
- `vagrant reload` - Reboots the machine instance.
- `vagrant rebuild` - Destroys the machine instance and recreates it with the same IP address which was previously assigned.
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
