#
# Entity that represents a media file including
#  - name of the media file (i.e. Fight Club.mp4 )
#  - full_name of the link to the media file to play via http
#  - poster image link
#  - art image link
#  - banner image link
#  - media_type (i.e. movies or shows)
#  - genre (i.e. Drama, Comedy)
#  - year of release
#  - overview (description) of the movie or show
#  - rating  (i.e. 90%)
#  - runtime (i.e. 60 minutes)
#
#  Note: most of the information is fetched from Trakt.tv
#  see http://trakt.tv for more information
#
class Media < ActiveRecord::Base

  validates :name, :full_name, :media_type, presence: true

  def movie?
    media_type == :movies.to_s
  end

  def show?
    media_type == :shows.to_s
  end

  def to_s
    "Name: #{name} type [#{media_type}] full_name [#{full_name}] year #{year}"
  end

  # not a direct to_json, slightly different format
  def json
    h = Hash.new

    h["description"] = overview # add "..." if over certain size
    h["sources"] = [full_name]
    h["subtitle"] = "(#{year}) #{genre}"
    h["thumb"] = poster
    h["art"] = art

    t = name[0..32]
    t = t + ".." if t.size > 32
    h["title"] = t

    h["rating"] = rating
    h["runtime"] = runtime

    h
  end

  # generate a hash for a list media entities 
  def self.hash_for(media_files)
    media = Hash.new
    if media_files.size > 0
      content = { name: "media", videos: media_files.map(&:json) }
      media["categories"] = [ content ]
    end
    media
  end

end
