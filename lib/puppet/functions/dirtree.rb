#
# dirtree.rb
#

Puppet::Functions.create_function(:dirtree) do
# module Puppet::Parser::Functions
#   newfunction(:dirtree, type: :rvalue, doc: <<-EOS
# This function accepts a string or array of strings containing an absolute directory
# path and will return an array of each parent directory of the path(s).
#
# An optional second parameter can be supplied that contains a path to exclude
# from the resulting array.
#
# *Examples:*
# #    dirtree('/usr/share/puppet')
#    Will return: ['/usr', '/usr/share', '/usr/share/puppet']
#
#    dirtree('C:\\windows\\system32\\drivers')
#    Will return: ["C:\\windows", "C:\\windows\\system32", "C:\\windows\\system32\\drivers"]
#
#    dirtree('/usr/share/puppet', '/usr')
#    Will return: ['/usr/share', '/usr/share/puppet']
#
#    dirtree('C:\\windows\\system32\\drivers', 'C:\\windows')
#    Will return: ['C:\\windows\\system32', 'C:\\windows\\system32\\drivers']
#    EOS
#  ) do |arguments|
#    paths   = arguments[0]
#    exclude = arguments[1] || '/'
#
#
#
# `dirtree( <paths>, [<exclude>], [<windows_separator>] )`
# `dirtree( [<paths>], <options hash> )`

#  local_types do
#    type 'PathsType           = Variant[String, Array]'
#    type 'ExcludeType         = Variant[String, Array]'
#    type 'SeparatorType       = String'
#    type "OptionsWithPaths    = Struct[{\
#      paths             => PathsType,\
#      exclude           => Optional[ExcludeType],\
#      windows_separator => Optional[SeparatorType]\
#    }]"
#    type "OptionsWithoutPaths = Struct[{\
#      exclude           => Optional[ExcludeType],\
#      windows_separator => Optional[SeparatorType]\
#    }]"
#  end
#
#  # Dirtree without paths. Paths then becomes a required entry in the options hash
#  dispatch :dirtree_1 do
#    param       'OptionsWithPaths', :options_hash
#    return_type 'Array'
#  end
#
#  # Dirtree using paths and options hash
#  dispatch :dirtree_2 do
#    param       'PathsType',           :paths
#    param       'OptionsWithoutPaths', :options_hash
#    return_type 'Array'
#  end
#
#  dispatch :dirtree_3 do
#    param          'PathsType',     :paths
#    optional_param 'ExcludeType',   :exclude
#    optional_param 'SeparatorType', :windows_separator
#    return_type    'Array'
#  end
#
#  def dirtree_1(options_hash)
#    dirtree(*hash_args(options_hash))
#  end
#
#  def dirtree_2(paths, options_hash)
#    dirtree(paths, *hash_args(options_hash))
#  end
#
#  def dirtree_3(paths, exclude, windows_separator = '\\')
#    dirtree(paths, exclude, windows_separator)
#  end
#
#  def hash_args(options_hash)
#    [
#      options_hash['paths'],
#      options_hash['exclude'],
#      options_hash['windows_separator']
#    ]
#  end

  dispatch :dirtree do
    param 'Variant[String, Array]', :paths
    optional_param 'Variant[String, Array]', :exclude
#    optional_param 'String', :windows_separator
    return_type 'Array'
  end

  def dirtree(paths, exclude = '/')#, windows_separator = '\\')
    unless Puppet::Util.absolute_path?(exclude, :posix) || Puppet::Util.absolute_path?(exclude, :windows)
      raise Puppet::ParseError, "dirtree(): #{exclude.inspect} is not an absolute exclusion path."
    end

    paths = [ paths ] if paths.is_a?(String)

    # If exclude path in windows format, ensure path separators are all "\\"
    exclude = exclude.tr('/', '\\') if Puppet::Util.absolute_path?(exclude, :windows)

    result = []
    paths.each do |path|
      is_posix = Puppet::Util.absolute_path?(path, :posix)
      is_windows = Puppet::Util.absolute_path?(path, :windows)

      unless is_posix || is_windows
        raise Puppet::ParseError, "dirtree(): #{path.inspect} is not an absolute path."
      end

      # If path is in windows format, ensure path separators are all "\\"
      path = path.tr('/', '\\') if is_windows

      sep = is_posix ? '/' : '\\'

      # If the last character is the separator, discard it
      path = path.chop if (path[-1, 1] == sep)
      exclude = exclude.chop if (exclude[-1, 1] == sep)

      # Start trimming and pushing to the new array
      # If the path is a posix path, the string will be empty when done parsing
      # If the path is a windows path, the string will have the drive letter and a colon when done parsing.
      # If the path is already shorter then the exclude path, no output will be generated.
      while (path != '' and is_posix) || (path.length > 2 and is_windows) && !exclude.start_with?(path)
#        if is_posix || (windows_separator == sep)
          result.unshift(path)
#        else
#          result.unshift(path.tr(sep, windows_separator))
#        end
        path = path[0..path.rindex(sep)].chop
      end
    end

    return result.uniq
  end
end

# vim: set ts=2 sw=2 et :
