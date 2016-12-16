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

class GetEmployerTest < Minitest::Test
  def setup
    @mock_time_clock = MockTimeClock.new
    @mock_time_clock.start
  end

  def teardown
    @mock_time_clock.stop
  end

  def test_get_employer
    # The REP doesn't have a millisecond resolution, so round it to the closest
    # second.
    time = Time.now.round
    afd = AfdParser.new(true)
    afd.parse_line "0000000001108682040000172000000000000O.S. SYSTEMS SOFTWARE LTDA.                                                                                                                           123456789012345670101000101010001191220160957", 0
    @mock_time_clock.data.afd = afd
    expected = {
      document_type: :cnpj,
      document_number: 8682040000172,
      cei_document: 0,
      company_name: 'O.S. SYSTEMS SOFTWARE LTDA.'
    }
    assert_equal expected, @mock_time_clock.get_employer
  end
end
