require 'test_helper'

class PlayHelperTest < ActionView::TestCase


  test "blur" do
    assert_equal "blurred-thumbnail", blur(0)
    assert_equal "blurred-thumbnail", blur(8)
    assert_equal "", blur(9)
  end

  test "nth row" do
    assert nth_row(3, 3)
    assert_not nth_row(1, 3)
  end

  test "tv media type selected" do
    session[:media_type] = "shows"
    assert_equal "TV", media_type_selected
    session[:media_type] = nil
  end

  test "Movie media type selected" do
    session[:media_type] = "movies"
    assert_equal "Movies", media_type_selected
    session[:media_type] = nil
  end

end
