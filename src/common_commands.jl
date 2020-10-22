## Utils
instrument_reset(obj)    = write(obj, "*RST")
instrument_clear(obj)    = write(obj, "*CLS")
instrument_get_id(obj)   = query(obj, "*IDN?")
instrument_beep_on(obj)  = write(obj,"SYST:BEEP:STAT on")
instrument_beep_off(obj) = write(obj,"SYST:BEEP:STAT off")
instrument_query_complete(obj) = query(obj,"*OPC?")
instrument_wait_complete(obj)  = query(obj,"*WAI")
instrument_query_error(obj)    = query(obj,"SYST:ERR?")

## TRIGGER
instrument_trigger_set_source(obj;ch="1",sour="BUS")    = write(obj,"TRIG$ch:SOUR $sour")
instrument_trigger_set_delay(obj;ch="1",del=0)          = write(obj,"TRIG$ch:DEL $del")
instrument_trigger_set_slope(obj;ch="1",slp="positive") = write(obj,"TRIG$ch:SLOP $slp")
instrument_trigger_set_out_stat(obj;st="normal")        = write(obj,"OUTP:TRIG $st")
instrument_set_out_trig_slope(obj;slp="positive")       = write(obj,"OUTP:TRIG:SLOP $slp")
instrument_send_software_trigger(obj)                   = write(obj,"*TRG")

## OUTPUT FUNCTION
instrument_set_waveform(obj;ch="1",func="sin") = write(obj,"SOURce$ch:FUNC $func")
instrument_set_arbitrary_waveform(obj;ch="1",arb="mywfm") = write(obj,"SOURce$ch:FUNCtion:ARBitrary $arb")
instrument_set_amplitude(obj;ch="1",unit="vpp",volt=0.01) = write(obj,"SOURce$ch:VOLT:UNIT $unit\n;SOURce$ch:VOLT $volt")
instrument_set_offset(obj;ch="1",volt=0.01) = write(obj,"SOURce$ch:VOLT:OFFset $volt")
instrument_set_hilevel(obj;ch="1",volt=0.01) = write(obj,"SOURce$ch:VOLT:HIGH $volt")
instrument_set_lolevel(obj;ch="1",volt=0.01) = write(obj,"SOURce$ch:VOLT:LOW $volt")
instrument_set_frequency(obj;ch="1",fr=1000) = write(obj,"SOURce$ch:FREQ $fr")
instrument_set_period(obj;ch="1",func="sin",per=0.001) = write(obj,"SOURce$ch:FUNC:$func:PER $per")
instrument_set_phase(obj;ch="1",unit="deg",phase=90) = write(obj,"UNIT:ANGL $unit\n;SOURce$ch:PHAS $phase")
instrument_set_symmetry(obj;ch="1",func="ramp",sym=50) = write(obj,"SOURce$ch:FUNC:$func:SYMM $sym")
instrument_set_both_edge_times(obj;ch="1",func="pulse",dt=10e-9) = write(obj,"SOURce$ch:FUNC:$func:TRAN $dt")
instrument_set_lead_edge_time(obj;ch="1",func="pulse",dt=10e-9) where {T<:F335x2} = write(obj,"SOURce$ch:FUNC:$func:TRAN:LEAD $dt")
instrument_set_trail_edge_time(obj;ch="1",func="pulse",dt=10e-9) where {T<:F335x2} = write(obj,"SOURce$ch:FUNC:$func:TRAN:TRA $dt")
instrument_set_width_time(obj;ch="1",func="pulse",wd=1e-4) = write(obj,"SOURce$ch:FUNC:$func:WIDTh $wd")

## OUTPUT
instrument_set_load(obj;ch="1",load="INF") = write(obj,"OUTP$ch:LOAD $load")
instrument_set_polarity(obj;ch="1",pol="normal") = write(obj,"OUTP$ch:POL $pol")
instrument_set_output(obj;ch="1",st="off") = write(obj,"OUTP$ch $st")

## SYNC
instrument_sync_state_on(obj;ch="1") = write(obj,"OUTP$ch:SYNC on")
instrument_sync_state_off(obj;ch="1") = write(obj,"OUTP$ch:SYNC off")

## ARBITRARY WAVEFORMS
instrument_abritrary_waveform_sample_rate(obj;ch="1",srate=1e6) = write(obj,"SOURce$ch:FUNC:ARB:SRAT $srate")
instrument_arbitrary_waveforms_clear(obj;ch="1") = write(obj,"SOURce$ch:DATA:VOLatile:CLEar")