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

require 'codin_rep'
require 'socket'

class MockTimeClock
  include CodinRep

  attr_reader :data, :ip

  def initialize
    @data = OpenStruct.new
    @ip = '127.0.0.1'
    @server = TCPServer.new(@ip, 0)
    @running = false
    @served_connections = 0
    @threads = []
    @threadsMutex = Mutex.new
    @served_connections = 0
    @time = true
  end

  def tcp_port
    @server.addr[1]
  end

  def serve(socket)
    Thread.new do
      Thread.current.abort_on_exception = true
      @threadsMutex.synchronize {
        @threads << Thread.current
        @served_connections += 1
      }
      begin
        raw_command = []

        # Read command type
        raw_command = read_from_socket_with_timeout(socket, 9)

        response = process_command(raw_command)

        socket.write response
      ensure
        socket.close unless socket.closed?
        @threadsMutex.synchronize {
          @threads.delete(Thread.current)
        }
      end
    end
  end

  def start
    @server_thread = Thread.new do
      Thread.current.abort_on_exception = true
      @running = true
      while @running
        break if @server.closed?
        socket = @server.accept
        serve(socket)
      end
    end
    self
  end

  def stop
    @threadsMutex.synchronize {
      @threads.each{|thread| thread.kill}
      @threads = []
    }
    @server_thread.kill if @server_thread
    @server.close unless @server.closed?
    @server_thread.join
    @running = false
    true
  end

  def running?
    @running
  end

  private
  def process_command(raw_command)
    case raw_command
    when "PGREP009b"
      response = get_timeclock_time
    else
      raise StandardError.new("Unknown command \"#{raw_command}\"!")
    end
    response
  end

  def read_from_socket_with_timeout(socket, bytes_to_be_read, timeout_value=5)
    data_to_receive = nil
    timeout(timeout_value) { data_to_receive = socket.readpartial( bytes_to_be_read ) }
    return data_to_receive
  end

  def get_timeclock_time
    # The current weekday is expected by the REP in the following format: 1 for
    # Sunday, 2 for Monday and so on. However there's no direct transformation
    # using Time#strftime for the weekday.
    # So we use String#next, which adds + 1 to the last character on it, which
    # is exactly what the format requires.
    formated_time = @data.time.strftime('%H %M %S %d %m %y 0%w').next
    codified_time = formated_time.split.collect{|c| c.to_i(16)}.pack('C*')
    'REP008b' + codified_time
  end
end
