Puppet::Type.newtype(:dirtree) do
  desc 'Ensure the presence of a directory structure on the client'

  ensurable do
    desc 'Manage the state of this type.'
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent)
    defaultto :present
  end

  newparam(:path, namevar: true) do
    desc 'The path of the directory'
    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "Directory tree paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:parents) do
    desc 'Create parents recursively'
    newvalues true, false
    defaultto false
  end

  validate do
    raise(Puppet::ParseError, 'The dirtree type does not support removal. Use the File type.') if self[:ensure] == :absent
  end
end
