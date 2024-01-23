function clamp(x, lower_inclusive, upper_inclusive)
  if x < lower_inclusive then return lower_inclusive end
  if x > upper_inclusive then return upper_inclusive end
  return x
end

function index_mod(index, length)
  return (index - 1) % length + 1
end

function show_status(s)
  renoise.app():show_status(s)
end


function selected_pattern_track_is_empty()
  return renoise.song().selected_pattern_track.is_empty
end

