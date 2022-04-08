# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "fifo_depth" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "clkdiv_val" -parent ${Page_0}


}

proc update_PARAM_VALUE.clkdiv_val { PARAM_VALUE.clkdiv_val } {
	# Procedure called to update clkdiv_val when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.clkdiv_val { PARAM_VALUE.clkdiv_val } {
	# Procedure called to validate clkdiv_val
	return true
}

proc update_PARAM_VALUE.fifo_depth { PARAM_VALUE.fifo_depth } {
	# Procedure called to update fifo_depth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.fifo_depth { PARAM_VALUE.fifo_depth } {
	# Procedure called to validate fifo_depth
	return true
}


proc update_MODELPARAM_VALUE.clkdiv_val { MODELPARAM_VALUE.clkdiv_val PARAM_VALUE.clkdiv_val } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.clkdiv_val}] ${MODELPARAM_VALUE.clkdiv_val}
}

proc update_MODELPARAM_VALUE.fifo_depth { MODELPARAM_VALUE.fifo_depth PARAM_VALUE.fifo_depth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.fifo_depth}] ${MODELPARAM_VALUE.fifo_depth}
}

