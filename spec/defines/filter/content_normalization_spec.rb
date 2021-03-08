require 'spec_helper'
describe 'repose::filter::content_normalization', type: :define do
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
          is_expected.to contain_file('/etc/repose/content-normalization.cfg.xml')
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
          is_expected.to contain_file('/etc/repose/content-normalization.cfg.xml').with_ensure(
            'absent',
          )
        }
      end

      context 'with headers and media_types' do
        let(:title) { 'headers' }
        let(:params) do
          {
            header_filters: [{
              'name'    => 'blacklist',
              'id'      => 'ReposeHeaders',
              'headers' => ['X-Authorization', 'X-User-Name'],
            }],
            media_types: [
              { 'name' => 'application/xml', 'variant-extension' => 'xml' },
              { 'name' => 'application/json', 'variant-extension' => 'json' },
            ],
          }
        end

        it {
          # "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<content-normalization xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'\n                       xmlns='http://docs.api.rackspacecloud.com/repose/content-normalization/v1.0'>\n    <header-filters>\n        <blacklist id=\"ReposeHeaders\">\n            <header id=\"X-Authorization\"/>\n            <header id=\"X-User-Name\"/>\n        </blacklist>\n    </header-filters>\n    <media-types>\n        <media-type name=\"application/xml\" variant-extension=\"xml\" />\n        <media-type name=\"application/json\" variant-extension=\"json\" />\n    </media-types>\n</content-normalization>\n"
          is_expected.to contain_file('/etc/repose/content-normalization.cfg.xml')
            .with_content(%r{<blacklist id=\"ReposeHeaders\">})
            .with_content(/<header id=\"X-Authorization\"\/>/)
            .with_content(/<header id=\"X-User-Name\"\/>/)
            .with_content(/<\/blacklist>/)
            .with_content(%r{<media-types>})
            .with_content(/<media-type name=\"application\/xml\" variant-extension=\"xml\" \/>/)
            .with_content(/<media-type name=\"application\/json\" variant-extension=\"json\" \/>/)
            .with_content(/<\/media-types>/)
        }
      end
    end
  end
end
