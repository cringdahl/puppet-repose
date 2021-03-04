require 'spec_helper'
describe 'repose::filter::atom_feed', :type => :define do
  let :pre_condition do
    'include repose'
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'default parameters' do
        let(:title) { 'some_feed' }
        it {
          should raise_error(Puppet::Error, /feed_uri is required/)
        }
      end

      context 'bad ordering' do
        let(:title) { 'some_feed' }
        let(:params) { {
            :feed_uri    => 'http://foo.bar',
            :entry_order => 'banana'
        } }
        it {
          should raise_error(Puppet::Error, /"banana" is not a valid entry_order parameter value/)
        }
      end

      context 'incomplete auth' do
        let(:title) { 'some_feed' }
        let(:params) { {
            :feed_uri      => 'http://foo.bar',
            :auth_username => 'banana'
        } }
        it {
          should raise_error(Puppet::Error, /If used auth_uri, auth_username, and auth_password are all required/)
        }
      end

      context 'with ensure absent' do
        let(:title) { 'some_feed' }
        let(:params) { {
            :feed_uri           => 'http://foo.bar',
            :connection_pool_id => 'pool_id',
            :entry_order        => 'reverse-read',
            :auth_uri           => 'http://bar.foo',
            :auth_username      => 'gandalf',
            :auth_password      => 'youshallnotpass',
            :auth_timeout       => '42',
        } }
        it {
          should contain_concat__fragment('feed-some_feed').
              with_target('/etc/repose/atom-feed-service.cfg.xml').
              with_order('50')
        }
      end
    end
  end
end