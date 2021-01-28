require 'spec_helper'
describe 'repose::filter::highly_efficient_record_processor', :type => :define do
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
          should contain_file('/etc/repose/highly-efficient-record-processor.cfg.xml').
            with_ensure('file').
            with_content(/pre-filter-logger-name="org.openrepose.herp.pre.filter"/).
            with_content(/post-filter-logger-name="org.openrepose.herp.post.filter"/).
            with_content(/service-code="repose"/).
            with_content(/region="USA"/).
            with_content(/data-center="DFW"/).
            with_content(/crush="false"/)
        }
      end

      context 'with ensure absent' do
        let(:title) { 'default' }
        let(:params) { {
          :ensure => 'absent'
        } }
        it {
          should contain_file('/etc/repose/highly-efficient-record-processor.cfg.xml').with_ensure(
            'absent')
        }
      end

      context 'with filter_out' do
        let(:title) { 'default' }
        let(:params) { {
          'filter_out' => [
            { 'match' => [
                { 'field' => 'userName', 'regex' => 'foo' },
                { 'field' => 'region', 'regex' => 'DFW' }
              ]
            },
            { 'match' => [
                { 'field' => 'userName', 'regex' => 'bar' },
                { 'field' => 'parameters.abc', 'regex' => '123' }
              ]
            }

          ]
        } }
        it {
          should contain_file('/etc/repose/highly-efficient-record-processor.cfg.xml').
            with_ensure('file').
            with_content(/field="userName" regex="foo"/).
            with_content(/field="region" regex="DFW"/).
            with_content(/field="userName" regex="bar"/).
            with_content(/field="paramters.abc" regex="123"/)
        }

      end
    end
  end
end