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

require "codin_rep/get_records"

module CodinRep
  class GetAfdHeader < GetRecords
    ONLY_RECORD_COMMAND = "PGREP009Z".freeze

    def initialize(*args)
      super(nil, *args)
    end

    def get_first_command
      "#{START_COMMAND}000000000000000001"
    end

    def execute
      @command_data = get_first_command
      @response = ""
      @parser = AfdParser.new(false)
      @records = []

      begin
        @response = communicate!
        @command_data = ONLY_RECORD_COMMAND
        @response = communicate!
        raw_record = get_response_payload
        current_record = @parser.parse_line(raw_record, nil)
        return current_record
      ensure
        @communication.close if @communication
      end
    end
  end
end
