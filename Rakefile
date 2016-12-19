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

loaded_simplecov = false
begin
  require 'simplecov'
  require 'simplecov-rcov'
  loaded_simplecov = true
rescue LoadError
  # simplecov wasn't loaded... We're probably in a production environment.
end

if loaded_simplecov
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::RcovFormatter
    ]
  )

  SimpleCov.start 'rails' do
    coverage_dir(File.expand_path(__dir__ + '/test/coverage'))
  end
end

require 'rake'
require 'rake/testtask'
require 'bundler'
Bundler::GemHelper.install_tasks

desc 'Default: run unit tests.'
task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/unit/**/*_test.rb'
  t.warning = false
end

if loaded_simplecov
  task :disable_coverage do
    SimpleCov.running = false
  end

  unless ENV['CI_TESTS'].nil? or ENV['CI_TESTS'] == ''
    require 'ci/reporter/rake/minitest'
    task :test => 'ci:setup:minitest'
  else
    Rake::Task.tasks.each do |t|
      t.enhance do
        Rake::Task["disable_coverage"].invoke
      end
    end
  end
end
