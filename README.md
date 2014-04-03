Puppet hazelcast module
=======================

Puppet module for the [hazelcast](http://www.hazelcast.com) in-memory data grid.

This module is intended for development purposes only - do not use in production.

It will currently deploy the management center to tomcat7, which will the be available at `http://yourHost:8080/mancenter`

## Usage

### Minimal 

` include 'hazelcast'` 

### Custom configuration


```puppet

	{ "hazelcast": 
		version => '3.2',
		user => 'myUser',
		password => 'superSecretPw'
	}

```

## Supported versions

See `manifests/init.pp` for supported versions

## Dependencies

- [puppetlabs/puppetlabs-java](https://github.com/puppetlabs/puppetlabs-java)