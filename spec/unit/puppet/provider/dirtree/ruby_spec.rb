# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:dirtree).provider(:ruby) do
  let(:params) do
    {
      name: '/some/path'
    }
  end
  let(:resource) do
    Puppet::Type.type(:dirtree).new(
      provider: :ruby,
      **params.select { |k,v| !v.nil? }
    )
  end
  let(:provider_class) { subject.class }
  let(:provider) { subject.class.new(resource) }

  it do
    expect(resource.provider).to be_an_instance_of Puppet::Type::Dirtree::ProviderRuby
  end

  context 'property :ensure => present' do
    context 'when .exist? == false' do
      before :each do
        allow(provider).to receive(:exists?).and_return(false)
      end
      it 'requests changes' do
        expect(provider).not_to be_exists
      end
    end

    context 'when .exist? == true' do
      before :each do
        allow(provider).to receive(:exists?).and_return(true)
      end
      it 'does not request changes' do
        expect(provider).to be_exists
      end
    end
  end

  context 'parameter :parents' do
    before :each do
      # avoid actually attempting to create paths during testing
      allow(FileUtils).to receive(:mkdir_p).with(resource[:path])
      allow(FileUtils).to receive(:mkdir).with(resource[:path])
    end

    context 'when true' do
      let(:params) do
        super().merge({
          parents: true
        })
      end

      it do
        provider.create
        expect(FileUtils).to have_received(:mkdir_p).with(resource[:path])
      end
    end

    context 'when false' do
      let(:params) do
        super().merge({
          parents: false
        })
      end

      it do
        provider.create
        expect(FileUtils).to have_received(:mkdir).with(resource[:path])
      end
    end
  end
end
