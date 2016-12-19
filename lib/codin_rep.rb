# -*- coding: utf-8 -*-
# codinrep - Gem para acesso de REPs da Telebyte
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

require "codin_rep/get_time"
require "codin_rep/set_time"

module CodinRep
  class << self
    def included(base)
      return if base.included_modules.include?(InstanceMethods)
      base.send(:include, InstanceMethods)
    end
  end

  module InstanceMethods
    def get_time
      command = CodinRep::GetTime.new(self.ip, self.tcp_port)
      response = command.execute
      return response
    end

    def set_time(time)
      command = CodinRep::SetTime.new(time, self.ip, self.tcp_port)
      response = command.execute
      return response
    end
  end
end
