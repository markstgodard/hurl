require 'test_helper'

class TraktTest < ActiveSupport::TestCase

  setup do
    @api_key = APP_CONFIG['trakt_api_key']
  end


  test "search by episode" do
      json = Trakt::fetch_media_info(@api_key, "Breaking+Bad+S05E12+", :shows)
      puts json
      assert_equal "http://slurm.trakt.us/images/fanart/126.54.jpg",
                    json[:art]

      # this will be the screen shot not the regular poster
      assert_equal "http://slurm.trakt.us/images/episodes/126-5-12.54.jpg",
                    json[:poster]
  end

  test "search by tv show" do
      json = Trakt::fetch_media_info(@api_key, "Breaking+Bad+", :shows)
      puts json

      # this will be a generic poster
      assert_equal "http://slurm.trakt.us/images/posters/126.54.jpg",
                    json[:poster]
  end

  test "search by movie" do

      json = Trakt::fetch_media_info(@api_key, "Fight+Club+", :movies)
      puts json

      # this will be the movie poster
      assert_equal "http://slurm.trakt.us/images/posters_movies/346.2.jpg",
                    json[:poster]
  end





end
