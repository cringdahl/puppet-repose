require 'spec_helper'
describe 'repose::filter::cors', type: :define do
  let :pre_condition do
    'include repose'
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'with ensure absent' do
        let(:title) { 'default' }
        let(:params) do
          {
            ensure: 'absent',
          }
        end

        it {
          is_expected.to contain_file('/etc/repose/cors.cfg.xml').with_ensure(
            'absent',
          )
        }
      end

      context 'providing a validator' do
        let(:title) { 'validator' }
        let(:params) do
          {
            ensure: 'present',
            filename: 'cors.cfg.xml',
            allowed_origins: [{ 'is_regex' => 'true', 'origin' => '.*' }],
            allowed_methods: [],
            resources: [],
          }
        end

        it {
          is_expected.to contain_file('/etc/repose/cors.cfg.xml').with(
            ensure: 'file',
            owner: 'repose',
            group: 'repose',
            mode: '0660',
            content: '<?xml version="1.0" encoding="UTF-8"?>
<cross-origin-resource-sharing xmlns="http://docs.openrepose.org/repose/cross-origin-resource-sharing/v1.0">
    <allowed-origins>
        <origin regex="true">.*</origin>
    </allowed-origins>
</cross-origin-resource-sharing>
',
          )
        }
      end
      context 'providing a validator2' do
        let(:title) { 'validator2' }
        let(:params) do
          {
            ensure: 'present',
            filename: 'cors.cfg.xml',
            allowed_origins: [{ 'is_regex' => 'true', 'origin' => '.*' }],
            allowed_methods: ['OPTIONS'],
            resources: [
              {
                'name'            => '/v2.0/tokens',
                'comment'         => '<!-- v2.0/tokens allows for OPTIONS, POST, and GET -->',
                'allowed_methods' => [
                  'POST',
                  'GET',
                  'OPTIONS',
                ],
              },
            ],
          }
        end

        it {
          is_expected.to contain_file('/etc/repose/cors.cfg.xml').with(
            ensure: 'file',
            owner: 'repose',
            group: 'repose',
            mode: '0660',
            content: '<?xml version="1.0" encoding="UTF-8"?>
<cross-origin-resource-sharing xmlns="http://docs.openrepose.org/repose/cross-origin-resource-sharing/v1.0">
    <allowed-origins>
        <origin regex="true">.*</origin>
    </allowed-origins>
    <allowed-methods>
        <method>OPTIONS</method>
    </allowed-methods>
    <resources>
      <!-- v2.0/tokens allows for OPTIONS, POST, and GET -->
      <resource path="/v2.0/tokens">
        <allowed-methods>
          <method>POST</method>
          <method>GET</method>
          <method>OPTIONS</method>
        </allowed-methods>
      </resource>
    </resources>
</cross-origin-resource-sharing>
',
          )
        }
      end
    end
  end
end
