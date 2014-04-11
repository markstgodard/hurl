module PlayHelper

  # if index in in range, set class, super hacky
  # but blur.js is super slow, so lets only take a
  # small hit vs. bluring all
  def blur(index)
    (0..8).include?(index.to_i) ? "blurred-thumbnail" : ""
  end

  # helper to return true if this index
  # is an nth row (i.e. every 3rd row)
  def nth_row(idx, n)
    idx % n == 0
  end


end
