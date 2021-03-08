require 'spec_helper'
describe 'repose::filter::destination_router', type: :define do
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
          is_expected.to raise_error(Puppet::Error, %r{targets is a required parameter})
        }
      end

      context 'with ensure absent' do
        let(:title) { 'default' }
        let(:params) do
          {
            ensure: 'absent',
          }
        end

        it {
          is_expected.to contain_file('/etc/repose/destination-router.cfg.xml').with_ensure(
            'absent',
          )
        }
      end

      context 'with targets' do
        let(:title) { 'validator' }
        let(:params) do
          {
            targets: [
              { 'id' => 'target01', 'quality' => 0 },
              { 'id' => 'target02', 'quality' => 0.5 },
              { 'id' => 'target03', 'quality' => 1 },
            ],
          }
        end

        it {
          is_expected.to contain_file('/etc/repose/destination-router.cfg.xml')
            .with_content(%r{<destination-router xmlns='http:\/\/docs.openrepose.org\/repose\/destination-router\/v1.0'>})
            .with_content(%r{<target id=\"target01\" quality="0"\/>})
            .with_content(%r{<target id=\"target02\" quality="0.5"\/>})
            .with_content(%r{<target id=\"target03\" quality="1"\/>})
            .with_content(%r{<\/destination-router>})
        }
      end
    end
  end
end
