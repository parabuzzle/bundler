require 'spec_helper'

describe "parallel", :realworld => true do
  it "installs" do
    gemfile <<-G
      source "https://rubygems.org"
      gem 'activesupport', '~> 3.2.13'
      gem 'faker', '~> 1.1.2'
      gem 'i18n', '~> 0.6.0' # Because 0.7+ requires Ruby 1.9.3+
    G

    bundle :install, :jobs => 4, :env => {"DEBUG" => "1"}

    if Bundler.rubygems.provides?(">= 2.1.0")
      expect(out).to match(/[1-3]: /)
    else
      expect(out).to include("is not threadsafe")
    end

    bundle "show activesupport"
    expect(out).to match(/activesupport/)

    bundle "show faker"
    expect(out).to match(/faker/)

    bundle "config jobs"
    expect(out).to match(/: "4"/)
  end

  it "updates" do
    install_gemfile <<-G
      source "https://rubygems.org"
      gem 'activesupport', '3.2.12'
      gem 'faker', '~> 1.1.2'
    G

    gemfile <<-G
      source "https://rubygems.org"
      gem 'activesupport', '~> 3.2.12'
      gem 'faker', '~> 1.1.2'
      gem 'i18n', '~> 0.6.0' # Because 0.7+ requires Ruby 1.9.3+
    G

    bundle :update, :jobs => 4, :env => {"DEBUG" => "1"}

    if Bundler.rubygems.provides?(">= 2.1.0")
      expect(out).to match(/[1-3]: /)
    else
      expect(out).to include("is not threadsafe")
    end

    bundle "show activesupport"
    expect(out).to match(/activesupport-3\.2\.\d+/)

    bundle "show faker"
    expect(out).to match(/faker/)

    bundle "config jobs"
    expect(out).to match(/: "4"/)
  end

  it "works with --standalone" do
    gemfile <<-G, :standalone => true
      source "https://rubygems.org"
      gem "diff-lcs"
    G

    bundle :install, :standalone => true, :jobs => 4

    ruby <<-RUBY, :no_lib => true
      $:.unshift File.expand_path("bundle")
      require "bundler/setup"

      require "diff/lcs"
      puts Diff::LCS
    RUBY

    expect(out).to eq("Diff::LCS")
  end
end
