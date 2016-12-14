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
  class SetTime < Command
    COMMAND_CODE = "016A".freeze
    EXPECTED_HEADER = 'REP008A'.freeze

    def initialize(time, *args)
      super(*args)
      @time = time
    end

    def generate_command_payload
      CodinRep::TimeUtil.pack @time
    end

    def get_expected_response_size
      14
    end

    def check_response_header
      unless @response.match(/^#{EXPECTED_HEADER}/)
        raise UnknownHeader.new @response[0..6], 'set time', EXPECTED_HEADER
      end
    end

    def get_response_payload
      @response_payload = @response[7..-1]
    end

    def get_data_from_response_payload
      new_time = nil
      begin
        new_time = CodinRep::TimeUtil.unpack @response_payload
      rescue ArgumentError
        raise MalformedResponsePayload.new 'set time'
      end
      return new_time
    end
  end
end
