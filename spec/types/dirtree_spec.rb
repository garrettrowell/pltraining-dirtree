# frozen_string_literal: true

require 'spec_helper'

describe 'dirtree' do
  let(:title) { '/some/path' }
  let(:valid_params) do
    [
      :path,
      :parents
    ]
  end
  let(:params) do
    {
      name: title,
    }
  end

  let(:resource) do
    Puppet::Type.type(:dirtree).new(
      **params.select { |_k,v| !v.nil? }
    )
  end

  it 'is a valid type' do
    is_expected.to be_valid_type
      .with_provider(:ruby)
      .with_properties(:ensure)
      .with_parameters(valid_params)
  end

  context 'raises an error when' do
    context 'path is not absolute' do
      let(:title) { 'some/path' }
      it do
        expect { resource }.to raise_error(Puppet::ResourceError, "Parameter path failed on Dirtree[#{title}]: Directory tree paths must be fully qualified, not '#{title}'")
      end
    end

    context 'ensure => absent' do
      let(:params) do
        super().merge({
          ensure: :absent,
        })
      end

      it do
        expect { resource }.to raise_error(Puppet::ResourceError, "Validation of Dirtree[#{title}] failed: The dirtree type does not support removal. Use the File type.")
      end
    end
  end

end
