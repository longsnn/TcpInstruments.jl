using TcpInstruments
tcpi = TcpInstruments
####################################
# Instantiate obj
psu1 = tcpi.initialize(:KeysightE3645A, "10.0.1.156") #single ch psu
psu2 = tcpi.initialize(:AgilentE3646A,  "10.0.1.157") #dual ch psu
####################################
# USAGE
####################################
# Power supply
tcpi.connect!(psu1)
tcpi.connect!(psu2)
# IDN
tcpi.get_id(psu1)
tcpi.get_id(psu2)
# Reset
tcpi.reset_instr(psu1)
tcpi.reset_instr(psu2)
# Set range
tcpi.set_range(psu1, ch="1", vrang="low")
tcpi.set_range(psu2, ch="1", vrang="high")
# Set voltage
tcpi.set_volt(psu1, ch="1", volt=5)
tcpi.set_volt(psu2, ch="1", volt=3)
# Set current compliance
tcpi.set_compl(psu1, ch="1", crtlim=0.6)
tcpi.set_compl(psu2, ch="1", crtlim=1.1)
# Output on/off
tcpi.set_outp(psu1, ch="1", st="on")
tcpi.set_outp(psu2, ch="1", st="on")
# Disconnect everything
tcpi.disconnect!(psu1)
tcpi.disconnect!(psu2)