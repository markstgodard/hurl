require 'open-uri'

#
# Main controller for serving up all media (movies, shows)
#
class PlayController < ApplicationController

  SERVER = APP_CONFIG['media_http_server']

  #
  # main page that serves up all movies, shows
  #
  def index
    # default to movies if not specified
    if :shows.to_s == params[:media_type]
      @media = MediaManager.load_media_files(APP_CONFIG['tv_directory'], :shows, SERVER)
      session[:media_type] = :shows.to_s
    else
      @media = MediaManager.load_media_files(APP_CONFIG['movies_directory'], :movies, SERVER)
      session[:media_type] = :movies.to_s
    end

  end

  #
  # action when media is played, this just sets the
  # background of the show being played or clears out
  #
  def play
    id = params[:id]

    if id == "stop"
      stop
      media = nil
    else
      media = Media.find(id)

      session[:now_playing_title] = media.name
      session[:now_playing] = media.art
      if session[:now_playing] != nil
        File.open("#{Rails.root}/app/assets/images/background.jpg", 'wb') do |fo|
          fo.write open(media.art).read
        end
      end
    end

    respond_to do |format|
      format.json { render :json => media.to_json }
    end
  end

  # clear session and background
  def stop
    # clear session
    session.delete(:now_playing_title)
    session.delete(:now_playing)

    # copy over background
    FileUtils.cp "#{Rails.root}/app/assets/images/Blank.JPG",
                 "#{Rails.root}/app/assets/images/background.jpg"
  end

end
