require "util"
require "gui"

local options = renoise.Document.create("NewTrackSettingsPreferences") {
  visible_effect_columns = 1,
  volume_column_visible = true,
  panning_column_visible = false,
  delay_column_visible = false,
  notifier_enabled = true
}
renoise.tool().preferences = options

local function apply_options(track)
  if track.type == renoise.Track.TRACK_TYPE_SEQUENCER then
    track.visible_effect_columns  = options.visible_effect_columns.value
    track.volume_column_visible   = options.volume_column_visible.value
    track.panning_column_visible  = options.panning_column_visible.value
    track.delay_column_visible    = options.delay_column_visible.value
  end
end

function apply_options_to_selected_track()
  apply_options(renoise.song().selected_track)
end

--This function will add a track with preferences directly. It is redundant with the notifier method
function insert_track()
  local notifier_setting = options.notifier_enabled.value
  options.notifier_enabled.value = false
  local s = renoise.song()
  local index = s.selected_track.type ~= renoise.Track.TRACK_TYPE_GROUP and s.selected_track_index + 1 or s.selected_track_index
  local t = s:insert_track_at(index)
  apply_options(t)
  s.selected_track_index = index
  options.notifier_enabled.value = notifier_setting
end


local ntracks = 0

function song_init()
  ntracks = #renoise.song().tracks
  renoise.song().tracks_observable:add_notifier(function()
    local new_track_count = #renoise.song().tracks
    if options.notifier_enabled.value and new_track_count == ntracks + 1 and selected_pattern_track_is_empty() then
      apply_options_to_selected_track()
    end
    ntracks = new_track_count
  end)
end

renoise.tool().app_new_document_observable:add_notifier(function()
  song_init()
end)



-- This bind directly adds the track, disabling the notifier. It has less visual jitter but isn't really necessary
--renoise.tool():add_keybinding({
--  name = "Pattern Editor:Track Control:Insert Track (mikel)", 
--  invoke = function() 
--    insert_track()
--  end
--})



local track_preferences_gui_entries = {
  --ValueBoxPickerEntry(
  --  "visible effect columns",
  --  options.visible_effect_columns,
  --  0,
  --  8,
  --  {1,2}
  --),
  ValueBoxPickerEntry{
    label = "visible effect columns", 
    target_observable = options.visible_effect_columns, 
    min = 0,
    max = 8, 
    steps = {1,2}
  },
  BooleanPickerEntry{label = "volume column", target_observable = options.volume_column_visible},
  BooleanPickerEntry{label = "delay column", target_observable = options.delay_column_visible},
  BooleanPickerEntry{label = "panning column", target_observable = options.panning_column_visible}
}

local track_preferences_dialog = PickerDialog{
  title = "new track preferences",
  picker_entries = track_preferences_gui_entries
}
local function show_preference_gui()
  track_preferences_dialog:show()
end

renoise.tool():add_menu_entry({
  name = "Main Menu:Tools:New Track Preferences", 
  invoke = show_preference_gui
})

renoise.tool():add_keybinding({
  name = "Pattern Editor:Track Control:New Track Preferences", 
  invoke = show_preference_gui
})

_AUTO_RELOAD_DEBUG = function()
end
