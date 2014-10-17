#
# Main controller for serving up all media (movies, shows)
#
class PlayController < ApplicationController

  SERVER      = APP_CONFIG['media_http_server']
  MOVIES_DIR  = APP_CONFIG['movies_directory']
  TV_DIR      = APP_CONFIG['tv_directory']

  # main page
  def index
  end

  # fetch media info for movies and tv shows
  def media
    movies = MediaManager.load_media(MOVIES_DIR, :movies, SERVER)
    tv = MediaManager.load_media(TV_DIR, :shows, SERVER)

    media = Media.hash_for(movies + tv)

    flash[:notice] = "No media found" if media.empty?

    respond_to do |format|
      format.json { render :json => media.to_json }
    end
  end

end
