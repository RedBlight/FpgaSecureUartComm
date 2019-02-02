# FpgaSecureUartComm

This is an FPGA project for secure UART communication between 2 nodes, written in VHDL.  
  
This FPGA module has 2 main parts.  
  
Transmitter part receives 16 byte data by UART from the computer (or any other source that does UART communication), encrypts each byte with an XOR key, packs it in a data frame, and sends it to other modules with UART communication.  
  
Receiver part receives the sent data frame, decrypts it, and then sends the 16 byte data to the computer (or any other receiver that accepts UART).  
  
This way, 2 of these modules can be used to transmit data securely. (Well, as secure as 8 bit XOR encryption gets to be.)  
  
Transmitter output and receiver input can be connected to test a module.  
  
2 bits of the XOR key can be changed via switches on the FPGA board.