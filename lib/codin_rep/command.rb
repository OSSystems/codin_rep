# -*- coding: utf-8 -*-
# codin_rep - Gem para acesso de REPs da Telebyte
# Copyright (C) 2016  O.S. Systems Softwares Ltda.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Rua Clóvis Gularte Candiota 132, Pelotas-RS, Brasil.
# e-mail: contato@ossystems.com.br

require 'codin_rep/communication'

module CodinRep
  class Command
    class UnknownHeader < StandardError
      def initialize(header, command_executed, expected_header=nil)
        @header = header
        @command_executed = command_executed
        @expected_header = expected_header
      end

      def message
        message = "The REP returned an unknown header '#{@header}' for the command '#{@command_executed}'."
        message += " Expected header was '#{@expected_header}'." if @expected_header
      end
    end

    class MalformedResponsePayload < StandardError
      def initialize(command_executed)
        @command_executed = command_executed
      end

      def message
        "Payload response from '#{@command_executed}' command is malformed."
      end
    end

    COMMAND_PREFIX = "PGREP".freeze

    def initialize(host_address, tcp_port)
      @host_address = host_address
      @tcp_port = tcp_port
      @communication = Communication.new(@host_address, @tcp_port, get_timeout_time, get_max_attempts)
    end

    def execute
      @command_data = generate_header
      @command_data += generate_command_payload
      @response = communicate!
      check_response_header
      @payload = get_response_payload
      return get_data_from_response_payload
    rescue
      @communication.close
      raise
    ensure
      @communication.close if should_close_connection?
    end

    def get_timeout_time
      3
    end

    def get_max_attempts
      3
    end

    def generate_header
      # COMMAND_CODE should be set on the specific command class:
      COMMAND_PREFIX.dup + self.class::COMMAND_CODE.dup
    end

    def generate_command_payload
      raise_not_implemented_error
    end

    def check_response_header
      raise_not_implemented_error
    end

    def get_data_from_response_payload
      raise_not_implemented_error
    end

    def get_expected_response_size
      raise_not_implemented_error
    end

    def should_close_connection?
      !!@response
    end

    private
    def raise_not_implemented_error
      calling_method = caller[0][/`.*'/][1..-2]
      raise NotImplementedError.new "The method '#{calling_method}' must be overriden by the class #{self.class.to_s}."
    end

    def communicate!
      @communication.communicate(@command_data, get_expected_response_size)
    end
  end
end
