class MediaManagerTest < ActiveSupport::TestCase

  test "query name" do
    assert_equal "Breaking+Bad+S01E01+", MediaManager.query_name("Breaking.Bad.S01E01.mp4")
  end



  test "query name for movie" do
    assert_equal "The+Amazing+Spiderman+2012+", MediaManager.query_name("The.Amazing.Spiderman.2012.mp4")
  end

  test "friendly name" do
    assert_equal "Breaking Bad S01E01", MediaManager.friendly_name("BreakingBad/Breaking.Bad.S01E01.mp4")
  end

end
