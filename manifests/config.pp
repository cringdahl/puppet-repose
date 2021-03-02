# == Class: repose::repose9
#
# This class is able to install or remove repose 9 on a node.
#
#
# === Parameters
#
# The default values for the parameters are set in repose::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
# [*ensure*]
# String. Controls if the managed resources shall be <tt>present</tt> or
# <tt>absent</tt>. If set to <tt>absent</tt>:
# * The managed software packages are being uninstalled.
# * Any traces of the packages will be purged as good as possible. This may
# include existing configuration files. The exact behavior is provider
# dependent. Q.v.:
# * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
# * {Puppet's package provider source code}[http://j.mp/wtVCaL]
# * System modifications (if any) will be reverted as good as possible
# (e.g. removal of created users, services, changed log settings, ...).
# * This is thus destructive and should be used with care.
# Defaults to <tt>present</tt>.
#
# [*autoupgrade*]
# Boolean. If set to <tt>true</tt>, any managed package gets upgraded
# on each Puppet run when the package provider is able to find a newer
# version than the present one. The exact behavior is provider dependent.
# Q.v.:
# * Puppet type reference: {package, "upgradeable"}[http://j.mp/xbxmNP]
# * {Puppet's package provider source code}[http://j.mp/wtVCaL]
# Defaults to <tt>false</tt>.
#
# The default values for the parameters are set in repose::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
# [*daemon_home*]
# String. Daemon home path
# Defaults to <tt>/usr/share/lib/repose</tt>
#
# [*log_path*]
# String. Log file directory path
# Defaults to <tt>/var/log/repose</tt>
#
# [*user*]
# String. User to run the valve as
# Defaults to <tt>repose</tt>
#
# [*daemonize*]
# String. the path to the daemonize binary
# Defaults to <tt>/usr/sbin/daemonize</tt>
#
# [*daemonize_opts*]
# String. The daemonize options to be passed into daemonize.
# DEPRECATED. This does nothing for repose 7+. This is replaced by a different
# variable in the sysconfig file but we are not supporting overwriting it.
# at this time.
# Defaults to <tt>-c $DAEMON_HOME -p $PID_FILE -u $USER -o $LOG_PATH/stdout.log -e $LOG_PATH/stderr.log -l /var/lock/subsys/$NAME</tt>
#
# [*java_options*]
# String. Additional java options to pass to java_opts
# NOTE: this also sets JAVA_OPTS for repose 7+
# Defaults to <tt>undef</tt>
#
# [*saxon_home*]
# String. Home directory for Saxon. Sets SAXON_HOME
# Defaults to <tt>undef</tt>
#
# === Examples
#
# * Installation:
#
# class { 'repose::repose9': }
#
# * Removal/decommissioning:
#
# class { 'repose::repose9': ensure => 'absent' }
#
#
# === Authors
#
# * Josh Bell <mailto:josh.bell@rackspace.com>
# * Alex Schultz <mailto:alex.schultz@rackspace.com>
# * Greg Swift <mailto:greg.swift@rackspace.com>
# * c/o Cloud Integration Ops <mailto:cit-ops@rackspace.com>
#
class repose::config (
  String $daemon_home,
  String $log_path,
  String $user,
  String $daemonize,
  String $daemonize_opts,
  String $ensure  = $repose::ensure,
  Optional[String] $java_options = undef,
  Optional[String] $saxon_home   = undef,
  Array $log_files         = [ '/var/log/repose/repose.log' ],
  String $rotate_frequency = 'daily',
  Integer $rotate_count    = 4,
  Boolean $compress        = true,
  Boolean $delay_compress  = true,
  Boolean $use_date_ext    = true,
) {

  $file_ensure = $ensure ? {
    absent  => absent,
    default => file,
  }
  $dir_ensure = $ensure ? {
      absent  => absent,
      default => directory,
  }

## files/directories
  File {
    mode    => $repose::dirmode,
    owner   => $repose::owner,
    group   => $repose::group,
  }

  file { $repose::configdir:
    ensure => $dir_ensure,
  }

  file { '/etc/security/limits.d/repose':
    ensure => $file_ensure,
    source => 'puppet:///modules/repose/limits',
  }

  file { '/etc/sysconfig/repose':
    ensure => $file_ensure,
    owner  => root,
    group  => root,
  }

  # setup augeas with our shellvars lense
  Augeas {
    incl => '/etc/sysconfig/repose',
    require => File['/etc/sysconfig/repose'],
    lens => 'Shellvars.lns',
  }

  # default repose valve sysconfig options
  $repose_sysconfig = [
    "set DAEMON_HOME '${daemon_home}'",
    "set LOG_PATH '${log_path}'",
    "set USER '${user}'",
    "set daemonize '${daemonize}'",
    "set daemonize_opts '\"${daemonize_opts}\"'",
    "set java_opts '\"\${java_opts} ${java_options}\"'",
    "set JAVA_OPTS '\"\${JAVA_OPTS} ${java_options}\"'",
  ]

  # if saxon_home provided for saxon license
  if $saxon_home {
    $saxon_sysconfig = [
      "set SAXON_HOME '${saxon_home}'",
      "set SAXON_HOME/export ''"
    ]
  } else {
    $saxon_sysconfig = 'rm SAXON_HOME'
  }

  logrotate::rule { 'repose_logs':
    path          => $log_files,
    rotate        => $rotate_count,
    missingok     => true,
    compress      => $compress,
    delaycompress => $delay_compress,
    dateext       => $use_date_ext,
  }

  # only run if ensure is not absent
  if ! ($ensure == absent) {
    # run augeas with our changes
    augeas {
      'repose_sysconfig':
        context => '/files/etc/sysconfig/repose',
        changes => [ $repose_sysconfig, $saxon_sysconfig ]
    }
  }
}
