wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/users/course/2021S/aml9000000/u106072139/huffman/filter.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/gaparr_sram"
wvGetSignalSetScope -win $_nWave1 "/testbench"
wvGetSignalSetScope -win $_nWave1 "/testbench/top01"
wvSetPosition -win $_nWave1 {("G1" 11)}
wvSetPosition -win $_nWave1 {("G1" 11)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/testbench/top01/encodeADDR\[15:0\]} \
{/testbench/top01/index\[7:0\]} \
{/testbench/top01/inputADDR\[15:0\]} \
{/testbench/top01/input_i\[15:0\]} \
{/testbench/top01/lengthADDR\[15:0\]} \
{/testbench/top01/next_index\[7:0\]} \
{/testbench/top01/next_inputADDR\[15:0\]} \
{/testbench/top01/next_input_i\[15:0\]} \
{/testbench/top01/next_state\[7:0\]} \
{/testbench/top01/state\[7:0\]} \
{/testbench/top01/symbolADDR\[15:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 )} 
wvSetPosition -win $_nWave1 {("G1" 11)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 )} 
wvSetRadix -win $_nWave1 -format UDec
wvZoomAll -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 6569836862.919400
wvSetCursor -win $_nWave1 6569807450.405910 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 6569138593.717088 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 6569157548.448004
wvSetCursor -win $_nWave1 226803.159582
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvExit
