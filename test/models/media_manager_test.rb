class MediaManagerTest < ActiveSupport::TestCase

  test "query name" do
    assert_equal "Breaking+Bad+S01E01+", MediaManager.query_name("Breaking.Bad.S01E01.mp4")
  end

  # House of Cards 2013 S02E05
  test "query name that excludes certain words" do
    assert_equal "House+of+Cards+2013+S02E05+", MediaManager.query_name("House.of.Cards.2013.S02E05.SomeUnwantedToken.SomeOtherUnwantedToken.mp4")
  end

  test "query name for movie" do
    assert_equal "The+Amazing+Spiderman+2012+", MediaManager.query_name("The.Amazing.Spiderman.2012.mp4")
  end

  test "friendly name" do
    assert_equal "Breaking Bad S01E01", MediaManager.friendly_name("BreakingBad/Breaking.Bad.S01E01.mp4")
  end

  test "friendly name that excludes certain words" do
    assert_equal "House of Cards 2013 S02E05", MediaManager.friendly_name("House.of.Cards.2013.S02E05.SomeUnwantedToken.SomeOtherUnwantedToken.mp4")
  end


end
