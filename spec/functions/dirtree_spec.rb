# frozen_string_literal: true

require 'spec_helper'

describe 'dirtree' do
  #  it 'function exists' do
  #    expect(Puppet::Parser::Functions.function('dirtree')).to eq('function_dirtree')
  #  end

  context 'raises a ParseError' do
    it 'if the first argument is not a String or Array' do
      #      is_expected.to run.with_params().and_raise_error(ArgumentError, 'dirtree(): expected first argument to be a String or an Array, got nil')
      is_expected.to run.with_params().and_raise_error(ArgumentError, "'dirtree' expects between 1 and 2 arguments, got none")
    end

    it 'if the first argument is not an absolute path' do
      is_expected.to run.with_params('usr/share/puppet').and_raise_error(Puppet::ParseError, 'dirtree(): "usr/share/puppet" is not an absolute path.')
    end

    it 'if the second argument is not a String' do
      #      is_expected.to run.with_params('/usr/share/puppet', 1).and_raise_error(Puppet::ParseError, 'dirtree(): expected second argument to be a String, got 1')
      is_expected.to run.with_params('/usr/share/puppet', 1).and_raise_error(ArgumentError, "'dirtree' parameter 'exclude' expects a value of type String or Array, got Integer")
      #      is_expected.to run.with_params('/usr/share/puppet', 1).and_raise_error(ArgumentError, /The function 'dirtree' was called with arguments it does not accept./)
    end

    it 'if the second argument is not an absolute path' do
      is_expected.to run.with_params('/usr/share/puppet', 'usr/share').and_raise_error(Puppet::ParseError, 'dirtree(): "usr/share" is not an absolute exclusion path.')
    end
  end

  context 'returns an array of the directory tree' do
    it 'when posix path' do
      is_expected.to run.with_params('/usr/share/puppet').and_return(['/usr', '/usr/share', '/usr/share/puppet'])
    end

    it 'when windows path uses double backslash' do
      is_expected.to run.with_params('C:\\windows\\system32').and_return(['C:\\windows', 'C:\\windows\\system32'])
    end

    it 'when windows path uses single backslash' do
      is_expected.to run.with_params('C:\windows\system32').and_return(['C:\windows', 'C:\windows\system32'])
    end

    it 'when windows path uses single forward slash' do
      is_expected.to run.with_params('C:/windows/system32').and_return(['C:\windows', 'C:\windows\system32'])
    end

    it 'when windows path uses single forward slash output forward' do
      is_expected.to run.with_params('C:/windows/system32').and_return(['C:\windows', 'C:\windows\system32'])
    end

    it 'when windows path has spaces' do
      is_expected.to run.with_params('C:\Program Files\PuppetLabs').and_return(['C:\Program Files', 'C:\Program Files\PuppetLabs'])
    end
  end

  it 'returns an array of all paths given an array of paths' do
    expect(subject.execute([
      '/usr/share/puppet',
      '/var/lib/puppet/ssl',
      '/var/lib/puppet/modules'
    ])).to match_array([
      '/usr',
      '/usr/share',
      '/usr/share/puppet',
      '/var',
      '/var/lib',
      '/var/lib/puppet',
      '/var/lib/puppet/modules',
      '/var/lib/puppet/ssl'
    ])
  end

  context 'returns an array' do
    it 'of the posix directory tree without the first directory' do
      is_expected.to run.with_params('/usr/share/puppet', '/usr').and_return(['/usr/share', '/usr/share/puppet'])
    end

    it 'of the posix directory tree without anything below the 2nd argument' do
      is_expected.to run.with_params('/usr/share/puppet', '/usr/share').and_return(['/usr/share/puppet'])
    end

    it 'of the windows directory tree without the first directory' do
      is_expected.to run.with_params('C:\\windows\\system32\\drivers', 'C:\\windows').and_return([
        'C:\\windows\\system32',
        'C:\\windows\\system32\\drivers'
      ])
    end

    it 'without the first directory if there\'s a trailing slash on the exclude' do
      is_expected.to run.with_params('/var/lib/puppet/ssl', '/var/lib/').and_return(['/var/lib/puppet', '/var/lib/puppet/ssl'])
    end
  end

  context 'returns an empty array' do
    it 'of the posix directory tree if the path is implicitely excluded by the 2nd argument' do
      is_expected.to run.with_params('/usr/share', '/usr/share/puppet').and_return([])
    end

    it 'of the windows directory tree if all given paths are excluded by the 2nd argument' do
      is_expected.to run.with_params(['C:\\windows', 'C:\\windows\\system32'], 'C:\\windows\\system32\\drivers').and_return([])
    end
  end

  it 'returns an array of all paths given an array of paths without the specified directory' do
    is_expected.to run.with_params(
      [
        '/usr/share/puppet',
        '/var/lib/puppet/ssl',
        '/var/lib/puppet/modules'
      ],
      '/var/lib'
    ).and_return([
      '/usr',
      '/usr/share',
      '/usr/share/puppet',
      '/var/lib/puppet',
      '/var/lib/puppet/ssl',
      '/var/lib/puppet/modules'
    ])
    #    expect(subject.execute([
    #      '/usr/share/puppet',
    #      '/var/lib/puppet/ssl',
    #      '/var/lib/puppet/modules'
    #    ], '/var/lib')).to match_array([
    #      '/usr',
    #      '/usr/share',
    #      '/usr/share/puppet',
    #      '/var/lib/puppet',
    #      '/var/lib/puppet/ssl',
    #      '/var/lib/puppet/modules'
    #    ])
  end
end
