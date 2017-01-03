define wrap_frontend::vhost (
  $vhostname,
  $nonstop,
  $ip                          = $::ipaddress,
  $docroot                     = "/var/www/html/${vhostname}",
  $manage_docroot              = true,
  $priority                    = undef,
  $servername                  = $vhostname,
  $serveraliases               = [],
  $options                     = ['+FollowSymLinks','+Includes'],
  $override                    = ['None'],
  $directoryindex              = 'default.shtml default.htm index.html index.html.var',
  $logroot                     = "${::apache::logroot}/vhosts/${vhostname}",
  $log_level                   = undef,
  $access_log_format           = true,
  $access_log_env_var          = false,
  $access_logs                 = [
    { file   => 'access.log',
      format => 'common',
    },
    { file   => 'access_json.log',
      format => 'custom_elk_json',
    },
  ],
  $aliases                     = undef,
  $directories                 = undef,
  $error_log                   = true,
  $error_log_file              = 'error.log',
  $error_documents             = [],
  $scriptalias                 = undef,
  $proxy_dest                  = undef,
  $proxy_dest_match            = undef,
  $proxy_dest_reverse_match    = undef,
  $proxy_pass                  = undef,
  $proxy_pass_match            = undef,
  $no_proxy_uris               = ['/server-status'],
  $no_proxy_uris_match         = [],
  $proxy_preserve_host         = false,
  $proxy_error_override        = false,
  $redirect_source             = '/',
  $redirect_dest               = undef,
  $redirect_status             = undef,
  $redirectmatch_status        = undef,
  $redirectmatch_regexp        = undef,
  $redirectmatch_dest          = undef,
  $headers                     = undef,
  $request_headers             = undef,
  $rewrites                    = undef,
  $setenv                      = [],
  $setenvif                    = [],
  $block                       = [],
  $ensure                      = 'present',
  $custom_fragment             = undef,
  $action                      = undef,
  $pin_to                      = $::environment,
) {

  # validation is done while collecting
  validate_bool($nonstop)

  # next check only is executed when using this define as real,
  # when used as exported resources this will be  silently ignored
  # The resource will never be collected on the wrong type of frontend

  if $::role =~ /internal_frontend/ {
    if $nonstop {
      # collecting on the nonstop internal frontend
      if $::role !~ /nonstop/ {
        fail("Refusing to collect nonstop frontend vhost definition on a ${::role} node !")
      }
    } else {
      if $::role =~ /nonstop/ {
        fail("Refusing to collect frontend vhost definition on a ${::role} node !")
      }
    }
  }

  # vaidation is handled by the apache::vhost reource type

  # following is needed to pass the parameters correctly to the
  # 'apache::vhost' defined type

  if $access_logs == undef {
    $_access_logs_type = undef
  } elsif is_array($access_logs) {
    $_access_logs_type = 'array'
  } elsif is_hash($access_logs) {
    $_access_logs_type = 'hash'
  } else {
    # catalog will fail anyway so we just do nothing
  }

  if $directories == undef {
    $directories_type = undef
  } elsif is_array($directories) {
    $directories_type = 'array'
  } elsif is_hash($directories) {
    $directories_type = 'hash'
  } else {
    # catalog will fail anyway so we just do nothing
  }

  if $rewrites == undef {
    $rewrites_type = undef
  } elsif is_array($rewrites) {
    $rewrites_type = 'array'
  } elsif is_hash($rewrites) {
    $rewrites_type = 'hash'
  } else {
    # catalog will fail anyway so we just do nothing
  }

  if $aliases == undef {
    $aliases_type = undef
  } elsif is_array($aliases) {
    $aliases_type = 'array'
  } elsif is_hash($aliases) {
    $aliases_type = 'hash'
  } else {
    # catalog will fail anyway so we just do nothing
  }

  if $error_documents == undef {
    $error_documents_type = undef
  } elsif is_array($error_documents) {
    $error_documents_type = 'array'
  } elsif is_hash($error_documents) {
    $error_documents_type = 'hash'
  } else {
    # catalog will fail anyway so we just do nothing
  }

  if $proxy_pass == undef {
    $proxy_pass_type = undef
  } elsif is_array($proxy_pass) {
    $proxy_pass_type = 'array'
  } elsif is_hash($proxy_pass) {
    $proxy_pass_type = 'hash'
  } else {
    # catalog will fail anyway so we just do nothing
  }
  if $proxy_pass_match == undef {
    $proxy_pass_match_type = undef
  } elsif is_array($proxy_pass_match) {
    $proxy_pass_match_type = 'array'
  } elsif is_hash($proxy_pass_match) {
    $proxy_pass_match_type = 'hash'
  } else {
    # catalog will fail anyway so we just do nothing
  }

  $params_apache_vhost = {
    ensure                   => $ensure,
    ip                       => $ip,
    docroot                  => $docroot,
    manage_docroot           => $manage_docroot,
    priority                 => $priority,
    servername               => $servername,
    serveraliases            => $serveraliases,
    options                  => $options,
    override                 => $override,
    directoryindex           => $directoryindex,
    logroot                  => $logroot,
    log_level                => $log_level,
    access_log_format        => $access_log_format,
    access_log_env_var       => $access_log_env_var,
    access_logs              => $_access_logs_type ? {
      'array' => $access_logs,
      'hash'  => [$access_logs],
      default => undef,
    },
    aliases                  => $aliases,
    directories              => $directories_type ? {
      'array' => $directories,
      'hash'  => [$directories],
      default => undef,
    },
    error_log                => $error_log,
    error_log_file           => $error_log_file,
    error_documents          => $error_documents_type ? {
      'array' => $error_documents,
      'hash'  => [$error_documents],
      default => undef,
    },
    scriptalias              => $scriptalias,
    proxy_dest               => $proxy_dest,
    proxy_dest_match         => $proxy_dest_match,
    proxy_dest_reverse_match => $proxy_dest_reverse_match,
    proxy_pass               => $proxy_pass_type ? {
      'array' => $proxy_pass,
      'hash'  => [$proxy_pass],
      default => undef,
    },
    proxy_pass_match         => $proxy_pass_match_type ? {
      'array' => $proxy_pass_match,
      'hash'  => [$proxy_pass_match],
      default => undef,
    },
    no_proxy_uris            => $no_proxy_uris,
    no_proxy_uris_match      => $no_proxy_uris_match,
    proxy_preserve_host      => $proxy_preserve_host,
    proxy_error_override     => $proxy_error_override,
    redirect_source          => $redirect_source,
    redirect_dest            => $redirect_dest,
    redirect_status          => $redirect_status,
    redirectmatch_status     => $redirectmatch_status,
    redirectmatch_regexp     => $redirectmatch_regexp,
    redirectmatch_dest       => $redirectmatch_dest,
    headers                  => $headers,
    request_headers          => $request_headers,
    rewrites                 => $rewrites_type ? {
      'array' => $rewrites,
      'hash'  => [$rewrites],
      default => undef,
    },
    setenv                   => $setenv,
    setenvif                 => $setenvif,
    block                    => $block,
    custom_fragment          => $custom_fragment,
    action                   => $action,
  }

  ensure_resource('apache::vhost', $vhostname, $params_apache_vhost)

}
