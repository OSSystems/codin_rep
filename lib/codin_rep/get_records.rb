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

require "afd_parser"
require "codin_rep/command"

module CodinRep
  class GetRecords < Command
    class UnknownAfdRecord < StandardError
      def initialize(afd_record_id)
        @afd_record_id = afd_record_id
      end

      def message
        message = "The REP returned an unknown AFD record of id '#{@afd_record_id}'"
      end
    end

    START_COMMAND = "PGREP0289".freeze
    NEXT_RECORD_COMMAND = "PGREP009,".freeze
    START_HEADER = 'REP0029['.freeze
    END_HEADER = 'REP0029]'.freeze
    AFD_DATA_START_HEADER = 'REP3029'.freeze
    AFD_DATA_CONTINUATION_HEADER = 'REP0379'.freeze
    AFD_DATA_ONLY_HEADER = 'REP2359'.freeze
    AFD_DATA_END_HEADER = 'REP0909'.freeze
    HEADER_SIZE = 8
    AFD_SIZES_BY_TYPE = {
      '1' => 233,
      '2' => 300,
      '3' => 35,
      '4' => 35,
      '5' => 88
    }.freeze

    def initialize(first_id, *args)
      super(*args)
      @first_id = first_id.to_i
      @first_id = 1 if @first_id < 1
    end

    def execute
      @command_data = get_first_command
      @response = ""
      @parser = AfdParser.new(false)
      @records = []

      get_afd_records

      return @parser
    end

    def get_afd_records
      begin
        while !@command_data.match(/^#{NEXT_RECORD_COMMAND}/) || @response != END_HEADER
          @response = communicate!
          current_record = nil
          if @has_response_payload
            raw_record = get_response_payload
            current_record = @parser.parse_line(raw_record, nil)
          end
          @records << current_record

          @command_data = NEXT_RECORD_COMMAND
        end
      ensure
        @communication.close if @communication
      end

      afd_start_date = @parser.first_creation_date
      afd_end_date = @parser.last_creation_date

      employer_command = CodinRep::GetAfdHeader.new(@host_address, @tcp_port)
      employer = employer_command.execute

      @parser.create_header(employer.employer_type, employer.employer_document,
                            employer.employer_cei, employer.employer_name,
                            employer.rep_serial_number, afd_start_date,
                            afd_end_date, Time.now)
      @parser.create_trailer
    end

    def get_expected_response_size
      proc do |partial_data|
        @has_response_payload = true
        case partial_data
        when START_HEADER
          @has_response_payload = false
          expected_size = 0
        when END_HEADER
          @has_response_payload = false
          expected_size = 0
        when /^#{AFD_DATA_START_HEADER}/
          @start_header_received = true
          expected_size = HEADER_SIZE + get_afd_data_type_size(partial_data)
        when /^#{AFD_DATA_ONLY_HEADER}/
          @start_header_received = true
          expected_size = HEADER_SIZE + get_afd_data_type_size(partial_data)
        when /^#{AFD_DATA_CONTINUATION_HEADER}/
          expected_size = HEADER_SIZE + get_afd_data_type_size(partial_data)
        when /^#{AFD_DATA_END_HEADER}/
          @end_header_received = true
          expected_size = HEADER_SIZE + get_afd_data_type_size(partial_data)
        else
          if partial_data.size < HEADER_SIZE
            # new command, get only the header:
            expected_size = HEADER_SIZE
          else
            header = partial_data[0..(HEADER_SIZE-1)]
            command_name = self.class.name.split('::')[1]
            raise UnknownHeader.new(header, command_name)
          end
        end
        expected_size
      end
    end

    def get_afd_data_type_size(partial_data)
      if partial_data.size < 17
        expected_size = 17
      else
        afd_record_id = partial_data[16]
        expected_size = AFD_SIZES_BY_TYPE[afd_record_id]
        raise UnknownAfdRecord.new(afd_record_id) if expected_size.nil?
      end
      expected_size
    end

    def get_response_payload
      @response_payload = @response[7..-1]
    end

    def get_first_command
      "#{START_COMMAND}#{@first_id.to_s.rjust(9, '0')}99999999"
    end
  end

  require "codin_rep/get_afd_header"
end
