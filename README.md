Stripped module to demonstrate some weird behaviour when passing an  array of hashes, with only one hash
===

This is a simple wrapper around the apache::vhost defined resource.

The problem we tried to solve here :

This wrap_frontend::vhost defined resources should be defined by the backend application needing a frontend vhost definition.
It is possible that the backend application is installed on multiple nodes.  The frontends will collect those exported wrap_frontend::vhost resources.

To avoid duplicated resources of the 'apache::vhost' definitions, we use the ensure_resource function.

Everything works fine unless we define an attribute that requires an array of hashes, with only one hash.

Somewhere on the way, those hashes are converted to an array of arrays.

This is what we get when running rspec tests :

````
  expected that the catalogue would contain Apache::Vhost[custom_vhost_param] with access_logs set to [{"file"=>"custom.log", "format"=>"common"}] but it is set to [["file", "custom.log"], ["format", "common"]]
````

Still looking how to solve this issue.

The environment
====

* puppet version 3.8.7
* ruby 2.1.9p490

Note about the rspec file
===
I used this module to play a bit with rspec 'shared_examples'.  Main goal of this exercise is looking for some ways
to make puppet-rspec more maintainable and more attractive avoiding a lot of repetition. (DRY)



Running the rspec
===

````
bundle install --without development system_tests
bundle exec rake spec
````

After debugging
===
After adding some debug output of the attributes causing our puppet-rspec fail, it seems the problem is not in the puppet parsing process, but either in puppet-rspec parsing the generated catalog.
If we look at the generated catalog when using single element hashes, we see the hashes still are hashes.
(even if this could cause some problem, because apache::vhost does check for some attributes if arrays are passed or not).

Could it be possible that rspec-puppet is flattening those attriute ?

The result we found in the catalog ( atrributes causing troubles are marked with an '*'):

````
Wrap_frontend::Vhost[host.example.com]{
  :name                 => "host.example.com",
  :nonstop              => true,
  :servername           => "custem_servername",
* :access_logs          => {"file"=>"custom.log", "format"=>"common"},
* :aliases              => {"aliasmatch"=>"^/image/(.*)\\.jpg$", "path"=>"/files/jpg.images/$1.jpg"},
* :directories          => {"path"=>"/var/www/files", "provider"=>"files", "deny"=>"from all"},
* :proxy_pass           => {"path"=>"/a", "url"=>"http://backend-a/"},
* :proxy_pass_match     => {"path"=>"^/(.*\\.gif)$", "url"=>"http://backend.example.com:8000/$1"},
* :rewrites             => {"comment"=>"Lynx or Mozilla v1/2", "rewrite_cond"=>["%{HTTP_USER_AGENT} ^Lynx/ [OR]", "%{HTTP_USER_AGENT} ^Mozilla/[12]"], "rewrite_rule"=>["^index\\.html$ welcome.html"]},
  :pin_to               => "frontend01",
  :vhostname            => "custom_vhost_param",
  :ip                   => "10.0.2.15",
  :docroot              => "/var/www/html/custom_vhost_param",
  :manage_docroot       => true,
  :serveraliases        => [],
  :options              => ["+FollowSymLinks", "+Includes"],
  :override             => "None", :directoryindex=>"default.shtml default.htm index.html index.html.var",
  :logroot              => "/var/log/httpd/vhosts/custom_vhost_param",
  :access_log_format    => true,
  :access_log_env_var   => false,
  :error_log            => true,
  :error_log_file       => "error.log",
  :error_documents      => [],
  :no_proxy_uris        => "/server-status",
  :no_proxy_uris_match  => [],
  :proxy_preserve_host  => false,
  :proxy_error_override => false,
  :redirect_source      => "/",
  :setenv               => [],
  :setenvif             => [],
  :block                => [],
  :ensure               => "present"
},
````

 Resulting in the apavhe::vhost reource :

 ````
Apache::Vhost[custom_vhost_param]{
  :name                   => "custom_vhost_param",
  :ensure                 => "present",
  :ip                     => "10.0.2.15",
  :docroot                => "/var/www/html/custom_vhost_param",
  :manage_docroot         => true,
  :servername             => "custem_servername",
  :serveraliases          => [],
  :options                => ["+FollowSymLinks", "+Includes"],
  :override               => "None",
  :directoryindex         => "default.shtml default.htm index.html index.html.var",
  :logroot                => "/var/log/httpd/vhosts/custom_vhost_param",
  :access_log_format      => true,
  :access_log_env_var     => false,
* :access_logs            => {"file" => "custom.log", "format"=>"common"},
* :aliases                => {"aliasmatch" => "^/image/(.*)\\.jpg$", "path"=>"/files/jpg.images/$1.jpg"},
* :directories            => {"path" => "/var/www/files", "provider"=>"files", "deny"=>"from all"},
  :error_log              => true,
  :error_log_file         => "error.log",
  :error_documents        => [],
* :proxy_pass             => {"path"=>"/a", "url"=>"http://backend-a/"},
* :proxy_pass_match       => {"path"=>"^/(.*\\.gif)$", "url"=>"http://backend.example.com:8000/$1"},
  :no_proxy_uris          => "/server-status",
  :no_proxy_uris_match    => [],
  :proxy_preserve_host    => false,
  :proxy_error_override   => false,
  :redirect_source        => "/",
* :rewrites               => {"comment"=>"Lynx or Mozilla v1/2", "rewrite_cond"=>["%{HTTP_USER_AGENT} ^Lynx/ [OR]", "%{HTTP_USER_AGENT} ^Mozilla/[12]"], "rewrite_rule"=>["^index\\.html$ welcome.html"]},
  :setenv                 => [],
  :setenvif               => [],
  :block                  => [],
  :virtual_docroot        => false,
  :ip_based               => false,
  :add_listen             => true,
  :docroot_owner          => "root",
  :docroot_group          => "root",
  :ssl                    => false,
  :ssl_cert               => "/etc/pki/tls/certs/localhost.crt",
  :ssl_key                => "/etc/pki/tls/private/localhost.key",
  :ssl_certs_dir          => "/etc/pki/tls/certs",
  :ssl_proxyengine        => false,
  :default_vhost          => false,
  :vhost_name             => "*",
  :logroot_ensure         => "directory",
  :access_log             => true,
  :access_log_file        => false,
  :access_log_pipe        => false,
  :access_log_syslog      => false,
  :scriptaliases          => [],
  :suphp_addhandler       => "php5-script",
  :suphp_engine           => "off",
  :php_flags              => {},
  :php_values             => {},
  :php_admin_flags        => {},
  :php_admin_values       => {},
  :setenvifnocase         => [],
  :additional_includes    => [],
  :use_optional_includes  => false,
  :apache_version         => "2.4",
  :auth_kerb              => false,
  :krb_method_negotiate   => "on",
  :krb_method_k5passwd    => "on",
  :krb_authoritative      => "on",
  :krb_auth_realms        => [],
  :krb_verify_kdc         => "on",
  :krb_servicename        => "HTTP",
  :krb_save_credentials   => "off"
},
````

Validation in apache::vhost
===

````
411   if !is_array($access_logs) {
412     fail("Apache::Vhost[${name}]: access_logs must be an array of hashes")
413   }
````

````
563  if $directories {
564    if !is_hash($directories) and !(is_array($directories) and is_hash($directories[0])) {
565      fail("Apache::Vhost[${name}]: 'directories' must be either a Hash or an Array of Hashes")
566    }
     ...
````

````
199  if $rewrites {
200    validate_array($rewrites)
       ...
````

For *proxy_pass* and proxy_pass match, we need to have a look in the \_proxy.erb template.

for *aliases*, we need to check the \_aliases.erb template.

For both attributes, We can use here a hash or array.  The function flatten is used in them.


Early Conclusion
===

Following attributes could cause some problems :

* access_log
* rewrites

For both of them an array is expected, but we pass a hash instead.
