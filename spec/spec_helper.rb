require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

if ENV['DEBUG']
  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)
end

ENV['TRUSTED_NODE_DATA'] = 'yes'

include RspecPuppetFacts

at_exit { RSpec::Puppet::Coverage.report! }

