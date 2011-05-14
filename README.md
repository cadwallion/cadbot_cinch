CadBot
====

An IRC bot system written on top of the [Cinch](https://github.com/cinchrb/cinch/) IRC Bot Framework.

Installation
----
To start, clone the repository and install dependencies.  CadBot users Bundler to manage deps for the core and the plugins:

```
git clone git://github.com/cadwallion/cadbot_cinch.git
cd cadbot_cinch && bundle install
```

You're most of the way there.  In the config/ directory there is a file named 'bots.example.yml' that contains all of the relevant bot information you will need.  Rename this file 'bots.yml' and edit the file to point to the network(s) you want to connect to, the database connection information, and plugin information.

Usage
----

Once you're installed, it's as easy as:

```
ruby main.rb
```

Your bot should now be connected based on your bots.yml.  All logging is set to log/#{network["name"]}.log so check your debugging information there.

Plugins
----

CadBot takes the Cinch::Plugin model and encompasses auto-loading based on directories you specify.  By default, CadBot looks in the plugins/ directory for plugin folders.  Plugins must include Cinch::Plugin in order to be loaded.  For more details on writing plugins for Cinch, consult the [Cinch](https://github.com/cinchrb/cinch/) documentation.

To customize the plugin directory, add the following to your 'bots.yml':

``` yaml
plugins:
	path: /your/new/plugin/location/
```

You can also specify the default prefix and suffix values within the plugins section of bots.yml


Shared Database
----

Another additional feature added by CadBot on top of Cinch is a shared Redis database client connection.  This can be used by plugins for all sorts of possibilities.  See the [Sed](https://github.com/cadwallion/cadbot_cinch/blob/master/plugins/sed/sed.rb) plugin for examples of implementation.

As with plugin directory, you can specify connection information in the bots.yml under the 'database' section.  Acceptable parameters:
 - socket
 - host
 - port


Contribute
----

Want to improve on Cadbot?  You are more than welcome to join me in improving the project.  Submit an issue or fork it and send a pull request.  Have a question?  Send me a message on GitHub or you can find me in IRC irc.mmoirc.com:6667 #coding.