require 'test_helper'

class MediaTest < ActiveSupport::TestCase

  fixtures :media

  test "valid media" do

    movie = media(:fightclub)

    assert movie.valid?

  end

  test "invalid media" do
    m = Media.new
    assert m.invalid?
  end


end
