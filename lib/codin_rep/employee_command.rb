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

require "codin_rep/command"

module CodinRep
  class EmployeeCommand < Command
    CODE_MAX_SIZE = 12

    class UnknownEmployeeOperation < StandardError
      def initialize(operation_type)
        @operation_type = operation_type
      end

      def message
        message = "Unknown employee operation type '#{@operation_type}'."
      end
    end

    class InvalidInteger < StandardError
      def initialize(invalid_integer)
        @invalid_integer = invalid_integer
      end

      def message
        message = "Invalid integer for employee operation '#{@invalid_integer}'. Integer must be only numbers and at most #{CodinRep::EmployeeCommand::CODE_MAX_SIZE} digits."
      end
    end

    def initialize(*args)
      super(*args)
      @sent_registration = false
    end

    def execute
      @command_data = generate_header
      @command_data += generate_command_payload
      @response = communicate!
      check_response_header
      @sent_registration = true
      @command_data = self.class::REGISTRATION_COMPLETED_HEADER
      @response = communicate!
      # The REP requires some time to process the employee commands, so there's
      # this artificial sleep here to do it.
      sleep 0.1
      return get_data_from_response_payload
    rescue
      @communication.close
      raise
    ensure
      @communication.close if should_close_connection?
    end

    def get_expected_response_size
      @sent_registration ? 0 : self.class::EXPECTED_HEADER.size
    end

    def check_response_header
      expected_header = self.class::EXPECTED_HEADER
      unless @response.match(/^#{expected_header}/)
        raise UnknownHeader.new @response[0..expected_header.size], 'set employee', expected_header
      end
    end

    def get_response_payload
      @sent_employee_data = true
    end

    def get_data_from_response_payload
      true
    end

    private
    def convert_integer_to_byte_string(original_integer)
      integer = original_integer.to_s
      raise InvalidInteger.new(original_integer) if integer.size > CODE_MAX_SIZE
      [integer.to_s.rjust(CODE_MAX_SIZE, '0')].pack('H*')
    end
  end
end
