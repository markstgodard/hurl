require 'test_helper'

class TraktTest < ActiveSupport::TestCase

  setup do
    @api_key = Trakt::api_key
  end


  test "search by episode" do
    json = Trakt::fetch_media_info(@api_key, "Breaking+Bad+S05E12+", :shows)
    assert_equal "https://walter.trakt.us/images/shows/000/001/388/fanarts/original/fdbc0cb02d.jpg",
                  json[:art]

    # this will be the screen shot not the regular poster
    assert_equal "https://walter.trakt.us/images/episodes/000/073/539/screenshots/original/cb6155ad7e.jpg",
                  json[:poster]

  end

  test "search by tv show" do
    json = Trakt::fetch_media_info(@api_key, "Breaking+Bad+", :shows)

    # this will be a generic poster
    assert_equal "https://walter.trakt.us/images/shows/000/001/388/posters/original/fa39b59954.jpg",
                  json[:poster]
  end

  test "search by movie" do
    json = Trakt::fetch_media_info(@api_key, "Fight+Club+", :movies)

    # this will be the movie poster
    assert_equal "https://walter.trakt.us/images/movies/000/000/432/posters/original/73f7237eec.jpg",
                  json[:poster]
  end

  # test "search by movie exact search" do
  #   json = Trakt::fetch_media_info(@api_key, "The+Amazing+Spiderman+2012+", :movies)

  #   # i.e. http://trakt.tv/movie/the-amazing-spiderman-2012

  #   # this will be the movie poster
  #   assert_equal "http://slurm.trakt.us/images/posters_movies/169003.3.jpg",
  #                 json[:poster]
  # end





end
