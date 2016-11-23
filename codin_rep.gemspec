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

$:.push File.expand_path("../lib", __FILE__)
require "codin_rep/version"

Gem::Specification.new do |gem|
  gem.name        = "codin_rep"
  gem.version     = CodinRep::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["O.S. Systems Softwares Ltda."]
  gem.email       = "contato@ossystems.com.br"
  gem.homepage    = "http://www.ossystems.com.br/"
  gem.summary     = "Gem to manage Telebyte eletronic timeclocks"
  gem.description = <<-END.gsub(/^ */, '').split("\n").join(' ')
    Use this gem to manage several features of the Telebyte eletronic
    timeclocks, like report creation, user management, configuration etc.
  END

  gem.files         = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*"]
  gem.test_files    = Dir['{test}/**/*']
  gem.require_paths = ["lib"]
end
