# I2C Master-Slave Communication System

## Overview
I2C (Inter-Integrated Circuit) is a two-wire communication protocol typically used for communication between multiple devices. It uses two lines:
- **SCL (Serial Clock Line)**: Controls the timing of the communication.
- **SDA (Serial Data Line)**: Carries the data between master and slave devices.

This project simulates an I2C communication system between a master (controller) and a slave (device).

## Basic I2C Operations
1. **Start Condition**: The master initiates communication by pulling the SDA line low while SCL is high.
2. **Address Transfer**: The master sends the 7-bit address of the slave it wants to communicate with, followed by a read/write (R/W) bit.
3. **ACK/NACK**: After the address is sent, the slave responds with an ACK (0) or NACK (1).
4. **Data Transfer**:
   - **Write Operation**: The master sends data to the slave.
   - **Read Operation**: The slave sends data to the master.
5. **Stop Condition**: The master signals the end of communication by pulling SDA high while SCL is high.


## I2C Master Controller States

The I2C master controller uses a finite state machine (FSM) with **8 states** to control the communication process:

1. **IDLE**:  
   - The controller remains in this state until communication is initiated. 
   - Transition: Moves to the START state when `enable` is set high and `rst` is low.
  
2. **START**:  
   - The master generates the I2C start condition by pulling the SDA line low while SCL is high. 
   - Transition: Moves to the ADDRESS state after initiating the start condition.

3. **ADDRESS**:  
   - In this state, the 7-bit slave address is transferred bit by bit over the SDA line, along with the read/write (R/W) bit.
   - Transition: Moves to the READ_ACK state after sending the address.

4. **READ_ACK**:  
   - The master waits for an acknowledgment (ACK) from the slave, indicating the slave has successfully received the address.
   - If ACK is received (`i2c_sda == 0`), the master moves to the appropriate state:
     - **WRITE_DATA** if the operation is a write.
     - **READ_DATA** if the operation is a read.
   - If no ACK is received, the master transitions to the STOP state.

5. **WRITE_DATA**:  
   - The master sends 8 bits of data to the slave, synchronized with the SCL clock.
   - Transition: Moves to the READ_ACK2 state after sending the data.

6. **READ_ACK2**:  
   - The master waits for a second acknowledgment from the slave after transmitting data.
   - Transition: Moves to the STOP state if the ACK is received. If not, it will either retry or go back to IDLE based on your design.

7. **READ_DATA**:  
   - In this state, the master receives 8 bits of data from the slave over the SDA line.
   - The data is captured in the `data_out` register of the master.
   - Transition: Moves to the WRITE_ACK state after receiving the data.

8. **STOP**:  
   - The master generates the I2C stop condition by releasing the SDA line (pulling it high) while SCL is high, signaling the end of communication.
   - Transition: The FSM returns to the IDLE state, ready for the next communication cycle.


## I2C Slave Controller

1. **Start Detection**: 
   - The slave detects the start condition when SDA goes low while SCL is high. This triggers the slave to start listening for the address from the master.

2. **Address Reception**: 
   - The slave enters the **READ_ADDR** state and stores the 7-bit address from the master in the `addr` register.
   - After receiving the address, the slave checks if it matches its own address. If a match is found, the slave sends an ACK in the **SEND_ACK** state.

3. **Read/write Operations**: 
   - If the master wants to write data, the slave moves to the **READ_DATA** state and captures the data bit by bit on the SDA line.
   - If the master wants to read data, the slave enters the **WRITE_DATA** state and sends the `data_out` register back to the master on the SDA line.
   - After the read or write is complete, the slave sends an ACK in the **SEND_ACK2** state and waits for the next communication cycle.

## Testbench (`tb.v`)

### Clock Generation
- The testbench generates a clock signal (`clk`) that toggles every 1 time unit to simulate real-time clock behavior.

### Test Stimulus
- The system is initially reset (`rst = 1`), followed by a release of the reset signal (`rst = 0`) after 100 time units.
- The master is configured with:
  - **Slave Address**: `addr = 7'b0101010`
  - **Data to Write**: `data_in = 8'b10101010`
  - **Read/Write Flag**: `rw = 0` (write operation)
- The `enable` signal is set to 1 to initiate communication, and then set back to 0 after a short delay.

### Result Logging
- The simulation results are saved in the `my_design.vcd` file for analysis using a waveform viewer like GTKWave.

## How to Run the Simulation
1. Compile the Verilog files.
2. Run the simulation for the master-slave communication.
3. Use a waveform viewer to analyze the generated `my_design.vcd` file.

## Conclusion
This project simulates an I2C communication system where a master controller communicates with a slave controller. The master initiates a write operation by sending the slave address and data over the SDA line, followed by an acknowledgment and stop condition. The testbench verifies the functionality by generating clock signals, resetting the system, and logging the results for analysis.
