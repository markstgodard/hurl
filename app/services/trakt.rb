require 'httparty'
require 'json'

class TraktMissingApiKeyError < RuntimeError
end

#
# Trakt API support for fetching media info for
#  movies, TV shows using
#
# For more information: http://trakt.tv/api-docs
#
module Trakt

  # load Trakt API Key from config or environment
  # variable: TRAKT_API_KEY
  def self.api_key

    api_key = APP_CONFIG['trakt_api_key']
    if api_key == "<Trakt API KEY>"
      # not set in config, check/use environment variable
      api_key = ENV["TRAKT_API_KEY"]

      # Ensure Trakt API KEY is in hurlconfig.yml OR
      # TRAKT_API_KEY environment variable set!!!
      raise TraktMissingApiKeyError if api_key == nil or api_key.empty?
    end
    api_key

  end

  # load information for a media file from trakt.tv
  def self.fetch_media_info(api_key, name, type)
    info = Hash.new
    # i.e. name = Flight+Club
    #      type = "movies" or "shows"
    query_type = type.to_s

    # if "TV show", check to see if has S01E02 syntax, if so check episode specific

    url = determine_url(query_type, api_key, name)
    #puts "url: #{url}"

    response = HTTParty.get(url)
    json = JSON.parse(response.body)

    if episode?(url, json)
      load_episode(info, json)
    elsif movie?(url, json)
      load_movie(info, json)
    else
      load_show(info, json)
    end

    info
  end


  # is the request url for a specific episode (S01E02) or
  # or just a regular show
  def self.episode?(url, json)
    url =~ /show\/episode\/summary.json/ and json != nil
  end

  # is the request url for a specific episode movie
  def self.movie?(url, json)
    url =~ /movie\/summary.json/ and json != nil
  end

  # load epsisode info (i.e. Breaking Bad S01E03)
  def self.load_episode(info, json)

    show = json["show"]
    if show != nil # show
      load_image_info(info, show["images"])
      load_genre_info(info, show["genres"])
      info[:year] = show["year"]
      info[:runtime] = show["runtime"]

    end

    load_episode_info(info, json["episode"])
  end

  # load specific movie
  def self.load_movie(info, json)
    if json != nil and json.size > 0

      load_image_info(info, json["images"])
      load_genre_info(info, json["genres"])
      load_ratings_info(info, json["ratings"])

      info[:year] = json["year"]
      info[:runtime] = json["runtime"]
      info[:overview] = json["overview"]
    end
  end

  # load generic show info
  def self.load_show(info, json)
    # we are going to use the first hit
    if json != nil and json.size > 0
      first = json[0]
      #puts "First: #{JSON.pretty_generate(first)}"

      load_image_info(info, first["images"])
      load_genre_info(info, first["genres"])
      load_ratings_info(info, first["ratings"])

      info[:year] = first["year"]
      info[:runtime] = first["runtime"]
      info[:overview] = first["overview"]
    end
  end

  def self.load_image_info(info, images)
    if images != nil
      info[:poster] = images["poster"]
      info[:art] = images["fanart"]
      info[:banner] = images["banner"]
    end
  end

  def self.load_genre_info(info, genres)
    # genre (get first)
    if genres != nil and genres.size > 0
      info[:genre] = genres[0]
    end
  end

  def self.load_episode_info(info, episode)
    if episode != nil
      # screen cap of the episode
      images = episode["images"]
      if images != nil
        info[:poster] = images["screen"]
      end

      # rating
      load_ratings_info(info, episode["ratings"])

      # overview
      info[:overview] = episode["overview"]

    end
  end


  def self.load_ratings_info(info, ratings)
    if ratings != nil and ratings["percentage"] != nil
      info[:rating] = ratings["percentage"]
    end
  end


  # either generates url for a looking up a regular
  # movie/show or a specific episode if we can determine
  # that based on the file (i.e.  Breaking Bad S01E02 vs.
  # Fight Club)
  def self.determine_url(query_type, api_key, name)

    last_part = name.split("+").last

    # i.e. S02E04
    #puts "checking if this is a Season/Episode format: #{last_part}"

    match = last_part.upcase.scan(/S(\d+)E(\d+)/)
    if match != nil and match.size == 1 and match[0].size == 2
      s = match[0][0].to_i
      e = match[0][1].to_i

      # Breaking+Bad+S05E12+
      hyphen_name = name.gsub!(/\+/,"-").gsub!(last_part,"").gsub!("--","").downcase
      "http://api.trakt.tv/show/episode/summary.json/#{api_key}/#{hyphen_name}/#{s}/#{e}"

    else

      # check if is "movie" and has name "name.of.movie.yyyy.mp4"
      if query_type == "movies" and last_part =~ /^\d{4}$/
        hyphen_name = name.gsub!(/\+/,"-").gsub!(last_part + "-", last_part).downcase
        "http://api.trakt.tv/movie/summary.json/#{api_key}/#{hyphen_name}"
      else
        "http://api.trakt.tv/search/#{query_type}.json/#{api_key}?query=#{name}"
      end
    end


  end

  def self.hyphenated_name(name, last_part)
    hyphen_name = name.gsub!(/\+/,"-").gsub!(last_part,"").gsub!("--","").downcase
  end


end
