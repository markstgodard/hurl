module Configurable

  def configure(setting)
    config = APP_CONFIG[setting.to_s] != nil ? APP_CONFIG[setting.to_s] : ""

    # optionally add more from ENV
    more = ENV[setting.to_s.upcase] != nil ? ENV[setting.to_s.upcase] : ""
    config << " " + more

    config.split(" ")

  end
end
