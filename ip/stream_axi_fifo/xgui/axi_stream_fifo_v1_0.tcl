# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "RX_DEPTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "TX_DEPTH" -parent ${Page_0} -widget comboBox


}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.RX_DEPTH { PARAM_VALUE.RX_DEPTH } {
	# Procedure called to update RX_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_DEPTH { PARAM_VALUE.RX_DEPTH } {
	# Procedure called to validate RX_DEPTH
	return true
}

proc update_PARAM_VALUE.TX_DEPTH { PARAM_VALUE.TX_DEPTH } {
	# Procedure called to update TX_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TX_DEPTH { PARAM_VALUE.TX_DEPTH } {
	# Procedure called to validate TX_DEPTH
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.RX_DEPTH { MODELPARAM_VALUE.RX_DEPTH PARAM_VALUE.RX_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_DEPTH}] ${MODELPARAM_VALUE.RX_DEPTH}
}

proc update_MODELPARAM_VALUE.TX_DEPTH { MODELPARAM_VALUE.TX_DEPTH PARAM_VALUE.TX_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TX_DEPTH}] ${MODELPARAM_VALUE.TX_DEPTH}
}

