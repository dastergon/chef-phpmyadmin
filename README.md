chef-phpmyadmin
===============

A Chef cookbook for the popular MySQL management application PHPMyAdmin

You can clone it and import it to Chef as

	cd cookbooks
	git clone git://github.com/priestjim/chef-phpmyadmin.git phpmyadmin
	knife cookbook upload phpmyadmin

Requirements
============

This cookbook requires the following cookbooks to be present and installed:

* chef-php from https://github.com/priestjim/chef-php

It also suggests the following:

* nginx
* apache2
* percona

Supported Operating Systems
===========================

This cookbook supports the following Linux distributions:

* Ubuntu
* Debian
* Fedora
* CentOS
* RedHat

It also supports **Chef 10.14** and higher

Attributes
==========

This cookbook supports the following attributes:

## version
The desired PMA version

## checksum
The sha256 checksum of the PMA desired version

## mirror
The desired PMA download mirror

## fpm
Enables the PMA FPM instance for serving via NGINX

## home
The desired PMA installation home

## user
The user PMA runs as

## group
The group PMA runs as

## socket
The socket that FPM will be exposing for PMA

## blowfish_secret
The PMA blowfish secret

## upload_dir
The directory PMA will be using for uploads

## save_dir
The directory PMA will be using for file saves

## maxrows
The maximum rows PMA shall display in a table view

## protect_binary
Define the binary field protection PMA will be using

## default_lang
The default language PMA will be using

## query_history
Enable or disable the Javascript query history

## query_history_size
Set the maximum size of the Javascript query history

LWRP Methods
============

This cookbook defines a phpmyadmin_db LWRP for dynamic DB definitions. This LWRP allows the following methods:

## name
This is the description of the defined database. It also gets converted to lowercase and spaces substituted to underscores for the database filename.

This is the *name* *attribute*

## host
The database host. It can be either a hostname or an IP.

## port
The database port.

## username
The database username.

## password
The database password

## hide_dbs
An array of databases we do not want to be shown. This will be concatenated in a form of '^db1|db2$' etc.

## pma_username
If you have configured your database server for PMA, you can define here the PMA username

## pma_password
If you have configured your database server for PMA, you can define here the PMA password

## pma_database
If you have configured your database server for PMA, you can define here the PMA database name

Usage
=====

The cookbook installs the selected PMA version to /opt/phpmyadmin (or anywhere else you may have defined in the 'home' attribute) and optionally defines an FPM pool for NGINX or Apache2/mod_fcgid

To define a database config you can use the phpmyadmin_db LWRP such as:

	phpmyadmin_db 'Test DB' do
		host '127.0.0.1'
		port 3306
		username 'root'
		password 'password'
		hide_dbs %w{ information_schema mysql phpmyadmin performance_schema }
	end

This will create a file in /opt/phpmyadmin/conf.d/test_db.inc.php and will be automatically included when you display the PMA page.

License
=======

Copyright 2012 Panagiotis Papadomitsos.

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0