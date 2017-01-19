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
require 'codin_rep/time_util'
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
    @is_sending_records = false
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
        @keep_connected = true
        @first_connection = true
        # Read command type
        while @keep_connected && raw_command = read_from_socket_with_timeout(socket, 9)
          response = process_command(raw_command, socket)
          socket.write response
          @first_connection = false
        end
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
  def process_command(raw_command, socket)
    case raw_command
    when "PGREP009b" # Get time
      response = 'REP008b' + get_timeclock_time
    when "PGREP016A" # Set time
      payload = read_from_socket_with_timeout(socket, 7)
      response = 'REP008A' + payload
      set_timeclock_time(payload)
    when "PGREP009Z"
      response = 'REP2359' + @data.afd.header.export + "\r\n"
      @keep_connected = false
    when "PGREP0289"
      @afd_read_start_id = read_from_socket_with_timeout(socket, 9).to_i
      @afd_read_end_id = read_from_socket_with_timeout(socket, 9).to_i
      @afd_read_current_id = nil
      @afd_read_finished = false
      response = "REP0029["
    when "PGREP009,"
      if @afd_read_finished
        response = "REP0029]"
        @keep_connected = false
      else
        if @afd_read_current_id.nil?
          @afd_read_current_id = @afd_read_start_id
          response = 'REP3029'
        elsif @afd_read_current_id == @afd_read_end_id or @afd_read_current_id >= @data.afd.records.size
          response = 'REP0909'
          @afd_read_finished = true
        else
          response = 'REP0379'
        end
        afd_records = ([@data.afd.header] + @data.afd.records)
        response += afd_records[@afd_read_current_id].export + "\r\n"
      end
      @afd_read_current_id += 1
    when "PGREP075h"
      payload = read_from_socket_with_timeout(socket, 66)
      raw_registration, raw_pis, raw_name = payload.scan(/.(.{6})(.{6})(.+)/).flatten
      registration = convert_bytes_to_string(raw_registration)
      pis = convert_bytes_to_string(raw_pis)
      name = raw_name.strip
      @data.employees << {name: name, pis: pis, registration: registration}
      response = "REP003h1\0"
    when "PGREP016j"
      payload = read_from_socket_with_timeout(socket, 7)
      raw_registration = payload.scan(/.(.{6})/).flatten[0]
      registration = convert_bytes_to_string(raw_registration)
      @data.employees.delete_if{|employee| employee[:registration] == registration}
      response = "REP003j1\0"
    when 'PGREP010h', 'PGREP010j'
      # Don't care for the result of these comands, just disconnect when
      # possible.
      @keep_connected = false
      response = ""
    else
      raise StandardError.new("Unknown command \"#{raw_command}\"!")
    end
    response
  end

  def read_from_socket_with_timeout(socket, bytes_to_be_read, timeout_value=5)
    data_to_receive = nil
    timeout_value = 600 if @first_connection # use a large timeout on first connection
    timeout(timeout_value) { data_to_receive = socket.readpartial( bytes_to_be_read ) }
    return data_to_receive
  end

  def get_timeclock_time(current_time=nil)
    current_time ||= @data.time
    CodinRep::TimeUtil.pack current_time
  end

  def set_timeclock_time(payload)
    time = CodinRep::TimeUtil.unpack payload
    @data.time = time
    return time
  end

  def convert_bytes_to_string(bytes)
    bytes.unpack('H*')[0]
  end
end
