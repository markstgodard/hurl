#
# Media manager is responsible for fetching
# mp4 files from a given directory
# and returning a list of media files
# including names, thumbnail images, etc.
#
class MediaManager

  # fetch media files from accessible directory
  # and return list of media entities
  def self.load_media_files(dir, type, server, api_key)
    files = []
    # get the subdir from main server (i.e. TV, Movies)
    subdir = dir.split("/").reverse.first

    # list of files
    load_media(dir).sort.each { |file|
      file.slice! (dir + '/')
      full_name = "#{server}/#{subdir}/#{file}"

      # try and lookup from db first (to avoid hitting Trakt)
      media = Media.where(full_name: full_name).first
      if media == nil
        media = create_media(file, type, full_name, api_key)
      end

      files << media
    }
    files
  end


  # get list of media
  def self.load_media(dir)
  	Dir.glob("#{dir}/**/*").select { |file|
      #File.file?(file) and file.downcase =~ /(mp4|mp3)$/
      File.file?(file) and file.downcase =~ /mp4$/
    }
  end

  def self.create_media(file, type, full_name, api_key)
    short_name = friendly_name(file)

    info = Trakt::fetch_media_info(api_key, query_name(short_name), type)

    media = Media.create(name: short_name, full_name: full_name,
                         poster: info[:poster], media_type: type.to_s,
                         art: info[:art],  genre: info[:genre],
                         year: info[:year], overview: info[:overview],
                         rating: info[:rating], runtime: info[:runtime])

  end


  # convert file to a more friendly name
  # i.e. BreakingBad/Breaking.Bad.S01E01.mp4 ->
  #      Breaking Bad S01E01
  def self.friendly_name(file)
    short_name = file.split('/').reverse.first
    short_name.slice!(".mp4")
    short_name.gsub!(/\./, ' ')
    short_name
  end

  # convert a file name to a queryable name
  # i.e. Breaking.Bad.mp4 => Breaking+Bad
  def self.query_name(file)
    clean = ""
    file.split(".").each do |p|
      if p.downcase =~ /mp4$/ or is_number?(p)
        # excluding
      else
        p.gsub!(/ /, '+')
        clean << p + "+"
      end
    end
    clean
  end

  # seriously, is this a number 
  def self.is_number?(val)
    true if Float(val) rescue false
  end

end
