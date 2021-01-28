require 'spec_helper'
describe 'repose::filter::http_logging', :type => :define do
  let :pre_condition do
    'include repose'
  end
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end


      context 'default parameters' do
        let(:title) { 'default' }
        it {
          should raise_error(Puppet::Error, /expects a value for parameter 'log_files'/)
        }
      end

      context 'with ensure absent' do
        let(:title) { 'default' }
        let(:params) { {
          :ensure => 'absent',
          :log_files => [ { } ],
        } }
        it {
          should contain_file('/etc/repose/http-logging.cfg.xml').with_ensure(
            'absent')
        }
      end

      context 'providing a log_file' do
        let(:title) { 'log_file' }
        let(:params) { {
          :ensure     => 'present',
          :filename   => 'http-logging.cfg.xml',
          :log_files  => [ {
            'id'       => 'my-log',
            'format'   => 'my format',
            'location' => '/var/log/repose/http.log'
          } ]
        } }
        it {
          should contain_file('/etc/repose/http-logging.cfg.xml').with(
            'ensure' => 'file',
            'owner'  => 'repose',
            'group'  => 'repose',
            'mode'   => '0660').
            with_content(/<http-log id="my-log" format="my format">/).
            with_content(/<file location=\"\/var\/log\/repose\/http.log\"\/>/)
        }
      end
    end
  end
end