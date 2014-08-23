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


  test "hash for list of media" do
    list = []
    list <<  media(:fightclub)
    hash = Media.hash_for(list)

    cat = hash['categories']
    assert cat != nil
    assert cat.size == 1
    assert cat[0][:name] == "media"

    # array with a hash for :videos
    assert cat[0][:videos][0]["title"] == "Fight Club"
  end

end
