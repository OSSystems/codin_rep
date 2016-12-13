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

class GetTimeTest < Minitest::Test
  def setup
    @mock_time_clock = MockTimeClock.new
    @mock_time_clock.start
  end

  def teardown
    @mock_time_clock.stop
  end

  def test_get_time
    # The REP doesn't have a millisecond resolution, so round it to the closest
    # second.
    time = Time.now.round
    @mock_time_clock.data.time = time
    assert_equal time, @mock_time_clock.get_time
  end
end
