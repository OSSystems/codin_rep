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

require 'socket'
require 'timeout'

module CodinRep
  class Communication
    READ_SIZE = 4096

    include Timeout

    def self.finalize(socket)
      proc { socket.close }
    end

    def initialize(host_address, port, timeout_time=60, max_attempts=3)
      @host_address = host_address
      @port = port
      @timeout_time = timeout_time
      @max_attempts = max_attempts
      @socket = nil
    end

    def open_socket
      if @socket
        @socket.close
        @socket = nil
      end

      @attempt = 0
      while @attempt < @max_attempts do
        begin
          Timeout.timeout(@timeout_time) {
            @socket = TCPSocket.open(@host_address, @port)
          }
          # Use a finalizer to close the socket if "self" is going to be
          # destroyed.
          ObjectSpace.define_finalizer( self, self.class.finalize(@socket) )
        rescue Timeout::Error
          @socket = nil
        end
        break if @socket

        @attempt += 1
      end

      raise "Timeout error" if @attempt >= @max_attempts
      @socket
    end

    def communicate(payload, expected_response_size)
      open_socket if @socket.nil?

      @payload = payload
      @expected_response_size = expected_response_size

      while @attempt < @max_attempts do
        @received_data = nil

        @received_data = send_receive_data(@payload)

        break unless @received_data.nil?
        @attempt += 1
      end

      raise "Timeout error" if @attempt >= @max_attempts
      @received_data
    end

    def close
      if @socket
        @socket.close
        @socket = nil
      end
    end

    private

    def send_receive_data(data_to_send)
      @socket.write(data_to_send)
      @socket.flush
      data_to_receive = ""

      # expected_response_size can be a Fixnum, for fixed responses sizes, or
      # a proc, where the response size comes inside the response itself.
      if @expected_response_size.is_a?(Proc)
        expected_size = @expected_response_size.call(data_to_receive)
      else
        expected_size = @expected_response_size
      end

      while data_to_receive.size < expected_size
        bytes_to_be_read = expected_size - data_to_receive.size
        bytes_to_be_read = READ_SIZE if bytes_to_be_read > READ_SIZE

        timeout(@timeout_time) {
          data_to_receive += @socket.readpartial( bytes_to_be_read )
        }
        if @expected_response_size.is_a?(Proc)
          expected_size = @expected_response_size.call(data_to_receive)
        end
      end
      data_to_receive
    end
  end
end
