#!/usr/bin/env ruby

module Ftpd
  class FtpServer < TlsServer

    DEFAULT_SERVER_NAME = 'wconrad/ftpd'
    DEFAULT_SESSION_TIMEOUT = 300 # seconds

    # The number of seconds to delay before replying.  This is for
    # testing, when you need to test, for example, client timeouts.
    # Defaults to 0 (no delay).
    #
    # Change to this attribute only take effect for new sessions.

    attr_accessor :response_delay

    # The class for formatting for LIST output.  Defaults to
    # {Ftpd::ListFormat::Ls}.  Changes to this attribute only take
    # effect for new sessions.

    attr_accessor :list_formatter

    # @return [Integer] The authentication level
    # One of:
    # * Ftpd::AUTH_USER
    # * Ftpd::AUTH_PASSWORD (default)
    # * Ftpd::AUTH_ACCOUNT

    attr_accessor :auth_level

    # The session timeout.  When a session is awaiting a command, if
    # one is not received in this many seconds, the session is
    # disconnected.  Defaults to {DEFAULT_SESSION_TIMEOUT}.  If nil,
    # then timeout is disabled.
    # @return [Numeric]

    attr_accessor :session_timeout

    # The server's name, sent in a STAT reply.  Defaults to
    # {DEFAULT_SERVER_NAME}.

    attr_accessor :server_name

    # The server's version, sent in a STAT reply.  Defaults to the
    # contents of the VERSION file.

    attr_accessor :server_version

    # The logger.  Defaults to nil (no logging).
    # @return [Logger]

    attr_accessor :log

    # Allow PORT command to specify data ports below 1024.  Defaults
    # to false.  Setting this to true makes it easier for an attacker
    # to use the server to attack another server.  See RFC 2577
    # section 3.
    # @return [Boolean]

    attr_accessor :allow_low_data_ports

    # Create a new FTP server.  The server won't start until the
    # #start method is called.
    #
    # @param driver A driver for the server's dynamic behavior such as
    #               authentication and file system access.
    #
    # The driver should expose these public methods:
    # * {Example::Driver#authenticate authenticate}
    # * {Example::Driver#file_system file_system}

    def initialize(driver)
      super()
      @driver = driver
      @response_delay = 0
      @list_formatter = ListFormat::Ls
      @auth_level = AUTH_PASSWORD
      @session_timeout = 300
      @server_name = DEFAULT_SERVER_NAME
      @server_version = read_version_file
      @allow_low_data_ports = false
      @log = nil
    end

    private

    def session(socket)
      Session.new(:socket => socket,
                  :driver => @driver,
                  :list_formatter => @list_formatter,
                  :response_delay => response_delay,
                  :tls => @tls,
                  :auth_level => @auth_level,
                  :session_timeout => @session_timeout,
                  :server_name => @server_name,
                  :server_version => @server_version,
                  :log => log,
                  :allow_low_data_ports => allow_low_data_ports).run
    end

    def read_version_file
      File.open(version_file_path, 'r', &:read).strip
    end

    def version_file_path
      File.expand_path('../../VERSION', File.dirname(__FILE__))
    end

  end
end
