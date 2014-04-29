
#
# Main controller for serving up all media (movies, shows)
#
class PlayController < ApplicationController

  SERVER = APP_CONFIG['media_http_server']

  # main page
  def index
  end

  # fetch all media (movies, tv shows)
  def media

    movies = MediaManager.load_media_files(APP_CONFIG['movies_directory'], :movies, SERVER)
    tv = MediaManager.load_media_files(APP_CONFIG['tv_directory'], :shows, SERVER)
    
    media = hash_for(movies + tv)

    flash[:notice] = "No media found" if media.empty?

    respond_to do |format|
      format.json { render :json => media.to_json }
    end
  end


  private

  def hash_for(all_files)
    media = Hash.new
    if all_files.size > 0
      movies = all_files.map(&:json)
      content = { name: "media", videos: movies}
      media["categories"] = [ content ]
    end
    media
  end


end
