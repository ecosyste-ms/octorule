# frozen_string_literal: true

require "test_helper"

class TestOctorule < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Octorule::VERSION
  end

  def test_version_format
    assert_match(/\d+\.\d+\.\d+/, ::Octorule::VERSION)
  end
end
