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

module CodinRep
  module TimeUtil
    class << self
      def pack(time=nil)
        # The current weekday is expected by the REP in the following format: 1
        # for Sunday, 2 for Monday and so on. However there's no direct
        # transformation using Time#strftime for the weekday.  So we use
        # String#next, which adds + 1 to the last character on it, which is
        # exactly what the format requires.
        formated_time = time.strftime('%H %M %S %d %m %y 0%w').next
        codified_time = formated_time.split.collect{|c| c.to_i(16)}.pack('C*')
        codified_time
      end

      def unpack(time)
        hours, minutes, seconds,
        day, month, year,
        weekday = time.unpack('H2H2H2H2H2H2C').collect{|c| c.to_i}
        # Year is in 2-digit format, so add 2000 to it:
        year += 2000
        time = Time.new(year, month, day, hours, minutes, seconds)
        if weekday - 1 != time.wday
          message = "Received weekday is wrong. Expected: #{time.wday + 1}; " +
                    "received: #{weekday}"
          raise WrongWeekday.new(message)
        end
        time
      end
    end
  end
end
