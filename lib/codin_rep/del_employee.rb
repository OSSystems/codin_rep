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

require "codin_rep/employee_command"

module CodinRep
  class DelEmployee < EmployeeCommand
    COMMAND_CODE = "016j1".freeze
    EXPECTED_HEADER = "REP003j1".freeze
    REGISTRATION_COMPLETED_HEADER = 'PGREP010j1'.freeze

    def initialize(registration, *args)
      super(*args)
      @registration = convert_integer_to_byte_string(registration)
    end

    def generate_command_payload
      @registration
    end
  end
end
