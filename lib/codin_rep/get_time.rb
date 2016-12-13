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
  class GetTime < Command
    COMMAND_CODE = "009b".freeze
    EXPECTED_HEADER = 'REP008b'.freeze

    def generate_command_payload
      ""
    end

    def get_expected_response_size
      14
    end

    def check_response_header
      unless @response.match(/^#{EXPECTED_HEADER}/)
        raise UnknownHeader.new @response[0..6], 'get time', EXPECTED_HEADER
      end
    end

    def get_response_payload
      @hours, @minutes, @seconds, @day, @month, @year, @weekday = @response[7..-1].unpack('H2H2H2H2H2H2C').collect{|c| c.to_i}
      # Year is in 2-digit format, so add 2000 to it:
      @year += 2000
    end

    def get_data_from_response_payload
      @time = nil
      begin
        @time = Time.new(@year, @month, @day, @hours, @minutes, @seconds)
      rescue ArgumentError
        raise MalformedResponsePayload.new 'get time'
      end
      return @time
    end
  end
end
