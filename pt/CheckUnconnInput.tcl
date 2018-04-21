proc UnconnIn { ExcludePins } {
  set allpins [get_pins -leaf -quiet -of [get_cells -hier * -filter is_hierarchical==false]]
  foreach ePin $ExcludePins { set allpins [remove_from_collection $allpins [filter_collection $allpins lib_pin_name==$ePin]] }

  set inpins [filter_collection $allpins "pin_direction==in"]
  set outpins [filter_collection $allpins "pin_direction==out"]
  append_to_collection outpins [filter_collection $allpins "pin_direction==internal"]

  set okinpins [get_pins -quiet -leaf -of [get_nets -quiet -of $outpins] -filter "pin_direction==in"]
  set TIE0PINS [get_pins * -hier -filter "constant_value==0"]
  set TIE1PINS [get_pins * -hier -filter "constant_value==1"]
  set InputPortPins [get_pins -quiet -leaf -of [get_nets -quiet -of [all_inputs]]  -filter "pin_direction==in"]
  set unDrivenPins [remove_from_collection [remove_from_collection [remove_from_collection [remove_from_collection $inpins $okinpins] $TIE0PINS] $TIE1PINS] $InputPortPins]
  return $unDrivenPins
}

