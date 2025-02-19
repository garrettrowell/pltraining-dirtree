dirtree
=======

This module provides the `dirtree` function and resource type, both used for
recursive directory management.

> This module is maintained by Puppet, but we have no plans for future feature development. We will keep it working with current versions of Puppet, but new feature development will come from community contributions. It does not qualify for Puppet Support plans.
> 
> [tier:maintenance-mode]

## Usage

### `dirtree()` function

This function accepts a string containing an absolute directory path
and will return an array of the tree containing all the directories of that path.

The first parameter can also be an array of absolute directory paths, which will
be transformed into an array of all trees containing all directories in the paths.

An optional second parameter can be supplied that contains a path to exclude
from the resulting array. This excludes all intermediate paths between the system 'root'
(i.e. '/' or 'X:') and the given exclude path as well.

Best efforts have been made to make this function compatible with both Windows and Linux systems.

#### Examples

    dirtree('/usr/share/puppet')
    Will return: ['/usr', '/usr/share', '/usr/share/puppet']

    dirtree('C:\\windows\\system32\\drivers')
    Will return: ["C:\\windows", "C:\\windows\\system32", "C:\\windows\\system32\\drivers"]

    dirtree(['/usr/share/puppet', '/var/lib/puppet/ssl', '/var/lib/puppet/modules'])
    Will return: ['/usr', '/usr/share', '/usr/share/puppet',
                  '/var', '/var/lib', '/var/lib/puppet', '/var/lib/puppet/ssl',
                  '/var/lib/puppet/modules']

    dirtree('/usr/share/puppet', '/usr')
    Will return: ['/usr/share', '/usr/share/puppet']

    dirtree('/usr/share', '/usr/share/puppet')
    Will return: []

    dirtree('C:\\windows\\system32\\drivers', 'C:\\windows')
    Will return: ['C:\\windows\\system32', 'C:\\windows\\system32\\drivers']

You can use the `dirtree` function in a class to enumerate all required directories if needed.

    class dirtree {
      # rubysitedir = /usr/lib/ruby/site_ruby/1.8
      $dirtree = dirtree("/var/lib/puppet/ssl", '/var/lib')

      # $dirtree = ['/usr/lib/puppet', '/var/lib/puppet/ssl']
      ensure_resource('file', $dirtree, {'ensure' => 'directory'})
    }

--------

### `dirtree` resource type

This resource type will simply ensure the existence of a directory. It cannot
and will not manage ownership or permissions. You should use the `file` resource
type for that. It's simply for use in the edge case in which you must use a
directory which you cannot fully manage, for one reason or another.

#### Examples

    dirtree { 'a temp dir':
      ensure  => present,
      path    => '/tmp/foo/bar/baz',
      parents => true,
    }

    dirtree { 'another temp dir with the same path':
      ensure  => present,
      path    => '/tmp/foo/bar/baz',
    }

    file { '/tmp/foo/bar/baz':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }


Changes
------

* dirtree v0.2.2
    * Added clarification and code, that exclude path also works, if given paths are short than itself.
    * Included the `dirtree` resource type.
    * More robust handling of Windows path separators.

* dirtree v0.2.1
    * Added the ability to pass an array of paths.  Thanks to [Ben Ford](https://github.com/binford2k)

* dirtree v0.2.0
    * Added optional second parameter specifying portion of the path to exclude.

Support
-------

Please file tickets and issues using [GitHub Issues](https://github.com/puppetlabs/pltraining-dirtree/issues)


License
-------
   Copyright 2013 Alex Cline <alex.cline@gmail.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

