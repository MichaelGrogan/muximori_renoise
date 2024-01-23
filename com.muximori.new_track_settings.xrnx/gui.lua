local vb = renoise.ViewBuilder()

local LABEL_WIDTH = 120
local DIALOG_MARGIN = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
local DIALOG_SPACING = renoise.ViewBuilder.DEFAULT_DIALOG_SPACING
local CONTROL_MARGIN = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN
local CONTROL_SPACING = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING

class 'PickerEntry'
  --we need an observable, and a label
  function PickerEntry:__init(arg)
    self.label = arg.label
    self.target_observable = arg.target_observable
    self.view = vb:column{style="invisible"}
    self._row = vb:horizontal_aligner{
      margin = CONTROL_MARGIN, 
      spacing = CONTROL_SPACING,
      vb:text{
        width = LABEL_WIDTH,
        align = "left",
        text = self.label
      }
    }
    self.view:add_child(self._row)
  end
  function PickerEntry:focus()
    self.view.style = "border"
  end
  function PickerEntry:unfocus()
    self.view.style = "invisible"
  end
  function PickerEntry:__tostring()
    return "a picker entry"
  end

class 'BooleanPickerEntry'(PickerEntry)
  function BooleanPickerEntry:__init(arg)
    PickerEntry.__init(self, arg)
    --TODO: assert observable is bool
    self._control = vb:checkbox{
      bind = self.target_observable
    }
    self._row:add_child(self._control)
  end
  function BooleanPickerEntry:__tostring()
    return "a boolean picker entry"
  end
  function BooleanPickerEntry:toggle()
    self.target_observable.value = not self.target_observable.value
  end
  function BooleanPickerEntry:increment()
    self:toggle()
  end
  function BooleanPickerEntry:decrement()
    self:toggle()
  end

class 'ValueBoxPickerEntry'(PickerEntry)
  --{label, target_observable, min, max, steps}
  function ValueBoxPickerEntry:__init(arg)
    PickerEntry.__init(self, arg)
    self.min = arg.min
    self.max = arg.max
    self.steps = arg.steps
    self._control = vb:valuebox {
      bind = self.target_observable, 
      min = self.min, 
      max = self.max,
      steps = self.steps
    }
    self._row:add_child(self._control)

  end

  function ValueBoxPickerEntry:_increment_value(x)
    local new_value = clamp(self.target_observable.value + x, self.min, self.max)
    self.target_observable.value = new_value
  end

  function ValueBoxPickerEntry:increment()
    self:_increment_value(self.steps[1])
  end
  function ValueBoxPickerEntry:decrement()
    self:_increment_value(0 - self.steps[1])
  end



class 'PickerDialog'
  -- {title, picker_entries}
  function PickerDialog:__init(arg)
    self.title = arg.title
    self.dialog_content = vb:column {
      margin = DIALOG_MARGIN,
      spacing = DIALOG_SPACING,
      uniform = true
    }
    self.bound_values = {}
    self.picker_entries = arg.picker_entries
    for i, picker_entry in ipairs(self.picker_entries) do
      self.dialog_content:add_child(picker_entry.view)
    end
    self.focus_index = 1
    self.picker_entries[self.focus_index]:focus()

-- > key = {  
-- >   name,      -- name of the key, like 'esc' or 'a' - always valid  
-- >   modifiers, -- modifier states. 'shift + control' - always valid  
-- >   character, -- character representation of the key or nil  
-- >   note,      -- virtual keyboard piano key value (starting from 0) or nil  
-- >   state,     -- optional (see below) - is the key getting pressed or released?
-- >   repeated,  -- optional (see below) - true when the key is soft repeated (held down)
-- > }

    self._key_handler_func = function(dialog, key)
      local keyname = key.name
      if keyname == "up" then
        self:focus_up()
      elseif keyname == "down" then
        self:focus_down()
      elseif keyname == "left" then
        self:decrement_focused_entry()
      elseif keyname == "right" then
        self:increment_focused_entry()
      else
        self:hide()
      end
    end
  end

  function PickerDialog:show()
    if self.dialog == nil or not self.dialog.visible then 
      self.dialog = renoise.app():show_custom_dialog( self.title, self.dialog_content, self._key_handler_func)
    end
  end
  function PickerDialog:hide()
    if self.dialog then self.dialog:close() end
  end
  function PickerDialog:increment_focus(increment_value)
    local old_focus_index = self.focus_index
    local new_focus_index = index_mod(old_focus_index + increment_value, #self.picker_entries)
    self.picker_entries[old_focus_index]:unfocus()
    self.picker_entries[new_focus_index]:focus()
    self.focus_index = new_focus_index
  end
  function PickerDialog:focus_up()
    self:increment_focus(-1)
  end
  function PickerDialog:focus_down()
    self:increment_focus(1)
  end
  function PickerDialog:increment_focused_entry()
    self.picker_entries[self.focus_index]:increment()
  end
function PickerDialog:decrement_focused_entry()
    self.picker_entries[self.focus_index]:decrement()
  end
