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

  def to_s
    "Name: #{@name} type [#{media_type}] full_name [#{@full_name}] year #{year}"
  end

end
