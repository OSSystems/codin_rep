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

require File.dirname(__FILE__) + '/../test_helper'

class DelEmployeeTest < Minitest::Test
  def setup
    @mock_time_clock = CodinRep::MockTimeClock.new
    @mock_time_clock.start
  end

  def teardown
    @mock_time_clock.stop
  end

  def test_remove_employee
    @mock_time_clock.data.employees = [
      {
        :name => "Lucas",
        :pis => "123456789012",
        :registration => "987654321098"
      }
      ]
    @mock_time_clock.set_employee(:remove, "987654321098", "123456789012", "Lucas")
    assert_equal [], @mock_time_clock.data.employees
  end
end
