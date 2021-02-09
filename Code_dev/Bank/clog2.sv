`ifndef _CLOG2_
`define _CLOG2_

function integer clog2(input integer depth);
integer i;
begin
	i = 1;
	
	while (depth > 2**i)
		i = i + 1;
	
	clog2 = i;
end
endfunction

`endif
