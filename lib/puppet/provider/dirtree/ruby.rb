Puppet::Type.type(:dirtree).provide(:ruby) do
  desc 'Ruby provider for the dirtree type'

  mk_resource_methods

  def exists?
    File.directory? resource[:path]
  end

  def create
    case resource[:parents]
    when :true
      FileUtils.mkdir_p resource[:path]
    else
      FileUtils.mkdir resource[:path]
    end
  end

  def destroy
    true
  end
end
