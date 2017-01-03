require 'spec_helper'

describe 'wrap_frontend::vhost' do
  let(:pre_condition) { [ 'include apache' ] }
  let(:title) { 'host.example.com' }

  shared_examples 'vhost' do | vhostname, facts, params |

    params = {} if params.nil? or not params.class == Hash

    # mandatory parameters will not be provided by a default
    params.merge!({ :vhostname => vhostname })
    environment = 'test_env'

    p = {
      :nonstop                     => false,
      :ip                          => facts[:ipaddress],
      :docroot                     => "/var/www/html/#{vhostname}",
      :manage_docroot              => true,
      :servername                  => vhostname,
      :serveraliases               => [],
      :options                     => ['+FollowSymLinks','+Includes'],
      :override                    => ['None'],
      :directoryindex              => 'default.shtml default.htm index.html index.html.var',
      :logroot                     => "/var/log/httpd/vhosts/#{vhostname}",
      :access_log_format           => true,
      :access_log_env_var          => false,
      :access_logs                 => [
        { 'file'   => 'access.log',
          'format' => 'common',
        },
        { 'file'   => 'access_json.log',
          'format' => 'custom_elk_json',
        },
      ],
      :error_log                   => true,
      :error_log_file              => 'error.log',
      :error_documents             => [],
      :no_proxy_uris               => ['/server-status'],
      :no_proxy_uris_match         => [],
      :proxy_preserve_host         => false,
      :proxy_error_override        => false,
      :redirect_source             => '/',
      :setenv                      => [],
      :setenvif                    => [],
      :block                       => [],
      :ensure                      => 'present',
      :pin_to                      => environment,
    }.merge(params)

    let(:params) { params }
    let(:environment) { environment }

    common_params = {
      :ip                   => p[:ip],
      :docroot              => p[:docroot],
      :manage_docroot       => p[:manage_docroot],
      :servername           => p[:servername],
      :serveraliases        => p[:serveraliases],
      :options              => p[:options],
      :override             => p[:override],
      :directoryindex       => p[:directoryindex],
      :logroot              => p[:logroot],
      :access_log_format    => p[:access_log_format],
      :access_log_env_var   => p[:access_log_env_var],
      :access_logs          => p[:access_logs],
      :error_log            => p[:error_log],
      :error_log_file       => p[:error_log_file],
      :error_document       => p[:error_document],
      :no_proxy_uris        => p[:no_proxy_uris],
      :no_proxy_uris_match  => p[:no_proxy_uris_match],
      :proxy_preserve_host  => p[:proxy_preserve_host],
      :proxy_error_override => p[:proxy_error_override],
      :redirect_source      => p[:redirect_source],
      :setenv               => p[:setenv],
      :setenvif             => p[:setenvif],
      :block                => p[:block],
      :ensure               => p[:ensure],
    }

    wrap_params = {
      :vhostname            => p[:vhostname],
      :nonstop              => p[:nonstop],
      :pin_to               => p[:pin_to],
    }

    it { is_expected.to compile }

    it do
      is_expected.to contain_wrap_frontend__vhost(title).with(common_params.merge(wrap_params))
    end

    it do
      is_expected.to contain_apache__vhost(p[:vhostname]).with(common_params)
    end

    # put all optional/undef parameters in this array
    [ 'priority', 'log_level', 'aliases', 'directories', 'scriptalias', 'proxy_dest', 'proxy_dest_match',
      'proxy_dest_match set', 'proxy_dest_reverse_match', 'proxy_pass', 'proxy_pass_match', 'redirect_dest',
      'redirect_status', 'redirectmatch_status', 'redirectmatch_dest', 'headers', 'request_headers',
      'rewrites', 'custom_fragment', 'action' ].each do |label|
      if p[label.to_sym]
        describe "with #{label} set" do
          it do
            is_expected.to contain_wrap_frontend__vhost(title).with(
              label.to_sym => p[label.to_sym],
            )
          end
          it do
            is_expected.to contain_apache__vhost(p[:vhostname]).with(
              label.to_sym => p[label.to_sym],
            )
          end
        end
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:environment) { 'production' }
      context 'without no parameters' do
        let(:facts) do
          facts.merge!( {
            :concat_basedir => '/tmp/foo',
            :role           => 'internal_frontend',
          } )
        end
        it_behaves_like 'vhost', 'vhost_under_test', facts , { :nonstop => false }
      end

      context 'with custom parameters' do
        let(:facts) do
          facts.merge!( {
            :role           => 'nonstop_internal_frontend',
            :concat_basedir => '/tmp/foo',
          } )
        end
        custom_params = {
          :nonstop                     => true,
          :ip                          => '11.22.33.44',
          :docroot                     => '/custom_docroot',
          :manage_docroot              => true,
          :priority                    => 50,
          :servername                  => 'custem_servername',
          :serveraliases               => [ 'custom_server_allias' ],
          :options                     => ['+FollowSymLinks'],
          :override                    => ['All'],
          :directoryindex              => 'custom.html',
          :logroot                     => '/custom/log/dir',
          :log_level                   => 'debug',
          :access_log_format           => true,
          :access_log_env_var          => false,
          :access_logs                 => [
            { 'file'   => 'custom.log',
              'format' => 'common',
            },
            { 'file'   => 'another_custom.log',
              'format' => 'other_format',
            },
          ],
          :aliases                     => [
            { 'aliasmatch' => '^/image/(.*)\.jpg$',
              'path'       => '/files/jpg.images/$1.jpg',
            },
            { 'alias' => '/image',
              'path'  => '/ftp/pub/image',
            },
          ],
          :directories                 => [
            { 'path'     => '/var/www/files',
              'provider' => 'files',
              'deny'     => 'from all',
            },
            { 'path'     => '/var/www/otherfile',
              'provider' => 'files',
              'deny'     => 'from all',
            },
          ],
          :error_log                   => true,
          :error_log_file              => 'custom_error_log',
          :error_documents             => [
            { 'error_code' => '503',
              'document'   => '/service-unavail',
            },
          ],
          :scriptalias                 => '/custom/alias/dir',
          :proxy_dest                  => '"http://custom_backend.example.com/',
          :proxy_dest_match            => '^(/.*\.gif)$" "http://backend.example.com:8000$1',
          :proxy_dest_reverse_match    => '^(/.*\.jpeg)$" "http://other_backend.example.com:8080$1',
          :proxy_pass                  => [
            { 'path' => '/a', 'url' => 'http://backend-a/' },
            { 'path' => '/b', 'url' => 'http://backend-b/' },
          ],
          :proxy_pass_match            => [
            {  'path' => '^/(.*\.gif)$',
               'url'  => 'http://backend.example.com:8000/$1',
            },
            {  'path' => '^/(.*\.png)$',
               'url'  => 'http://backend.example.com:8000/$1',
            },
          ],
          :no_proxy_uris               => ['/server-status', '/another-server'],
          :no_proxy_uris_match         => [ 'http//some\dd\.host.com' ],
          :proxy_preserve_host         => true,
          :proxy_error_override        => true,
          :redirect_source             => ['/images','/downloads'],
          :redirect_dest               => ['http://img.example.com/','http://downloads.example.com/'],
          :redirect_status             => ['temp','permanent'],
          :redirectmatch_status        => ['404','404'],
          :redirectmatch_regexp        => ['\.git(/.*|$)/','\.svn(/.*|$)'],
          :redirectmatch_dest          => ['http://www.example.com/1','http://www.example.com/2'],
          :headers                     => 'set foo-checksum "expr=%{md5:foo}"',
          :request_headers             => [
            'append MirrorID "mirror 12"',
            'unset MirrorID',
          ],
          :rewrites                    => [
            { 'comment'      => 'Lynx or Mozilla v1/2',
              'rewrite_cond' => ['%{HTTP_USER_AGENT} ^Lynx/ [OR]', '%{HTTP_USER_AGENT} ^Mozilla/[12]'],
              'rewrite_rule' => ['^index\.html$ welcome.html'],
            },
            {
              'comment'      => 'Internet Explorer',
              'rewrite_cond' => ['%{HTTP_USER_AGENT} ^MSIE'],
              'rewrite_rule' => ['^index\.html$ /index.IE.html [L]'],
            },
          ],
          :setenv                      => ['SPECIAL_PATH /foo/bin'],
          :setenvif                    => ['Request_URI "\.xbm$" object_is_image=xbm'],
          :block                       => ['scm'],
          :ensure                      => 'present',
          :custom_fragment             => '
            FileETag MTime Size
            # CORS, allow fonts from different domain
            <FilesMatch \"\\.(eot|svg|ttf|woff)$\">
              Header set Access-Control-Allow-Origin \"*\"
            </FilesMatch>',
          :action                      => 'news-handler',
          :pin_to                      => 'frontend01',
        }

        it_behaves_like 'vhost', 'custom_vhost_param', facts, custom_params

      end
      context 'with single element hashes in parameters - those tests fail, but should pass' do
        let(:facts) do
          facts.merge!( {
            :role           => 'nonstop_internal_frontend',
            :concat_basedir => '/tmp/foo',
          } )
        end
        single_hash_params = {
          :nonstop                     => true,
          :servername                  => 'custem_servername',
          :access_logs                 => [
            { 'file'   => 'custom.log',
              'format' => 'common',
            },
          ],
          :aliases                     => [
            { 'aliasmatch' => '^/image/(.*)\.jpg$',
              'path'       => '/files/jpg.images/$1.jpg',
            },
          ],
          :directories                 => [
            { 'path'     => '/var/www/files',
              'provider' => 'files',
              'deny'     => 'from all',
            },
          ],
          :proxy_pass                  => [
            { 'path' => '/a', 'url' => 'http://backend-a/' },
          ],
          :proxy_pass_match            => [
            {  'path' => '^/(.*\.gif)$',
               'url'  => 'http://backend.example.com:8000/$1',
            },
          ],
          :rewrites                    => [
            { 'comment'      => 'Lynx or Mozilla v1/2',
              'rewrite_cond' => ['%{HTTP_USER_AGENT} ^Lynx/ [OR]', '%{HTTP_USER_AGENT} ^Mozilla/[12]'],
              'rewrite_rule' => ['^index\.html$ welcome.html'],
            },
          ],
          :pin_to                      => 'frontend01',
        }

        it_behaves_like 'vhost', 'custom_vhost_param', facts, single_hash_params

      end
      context 'nonstop on internal frontend' do
        let(:facts) do
          facts.merge( {
            :role           => 'internal_frontend',
            :concat_basedir => '/tmp/foo',
          } )
        end
        let(:params) do
          {
            :nonstop   => true,
            :vhostname => 'host.example.com',
          }
        end
        it 'should fail' do
          expect { catalogue }.to raise_error(Puppet::Error, /Refusing to collect/)
        end
      end
      context 'frontend on nonstop internal frontend' do
        let(:facts) do
          facts.merge( {
            :role           => 'nonstop_internal_frontend',
            :concat_basedir => '/tmp/foo'
          } )
        end
        let(:params) do
          {
            :nonstop   => false,
            :vhostname => 'host.example.com',
          }
        end
        it 'should fail' do
          expect { catalogue }.to raise_error(Puppet::Error, /Refusing to collect/)
        end
      end
    end
  end
end
