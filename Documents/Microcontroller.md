
# Entity: Microcontroller 
- **File**: Microcontroller.v

## Diagram
![Diagram](Microcontroller.svg "Diagram")
## Ports

| Port name | Direction | Type | Description |
| --------- | --------- | ---- | ----------- |
| clk       | input     |      |             |
| rst       | input     |      |             |

## Signals

| Name              | Type        | Description |
| ----------------- | ----------- | ----------- |
| current_state     | reg [1:0]   |             |
| next_state        | reg [1:0]   |             |
| program_mem [9:0] | reg [11:0]  |             |
| load_done         | reg         |             |
| load_addr         | reg [7:0]   |             |
| PC                | reg [7:0]   |             |
| DR                | reg [7:0]   |             |
| Acc               | reg [7:0]   |             |
| IR                | reg [11:0]  |             |
| SR                | reg [3:0]   |             |
| PC_clr            | reg         |             |
| Acc_clr           | reg         |             |
| SR_clr            | reg         |             |
| DR_clr            | reg         |             |
| IR_clr            | reg         |             |
| load_instr        | wire [11:0] |             |
| PC_E              | wire        |             |
| Acc_E             | wire        |             |
| SR_E              | wire        |             |
| DR_E              | wire        |             |
| IR_E              | wire        |             |
| PC_updated        | wire [7:0]  |             |
| DR_updated        | wire [7:0]  |             |
| IR_updated        | wire [11:0] |             |
| SR_updated        | wire [3:0]  |             |
| PMem_E            | wire        |             |
| DMem_E            | wire        |             |
| DMem_WE           | wire        |             |
| ALU_E             | wire        |             |
| PMem_LE           | wire        |             |
| MUX1_Sel          | wire        |             |
| MUX2_Sel          | wire        |             |
| ALU_Mode          | wire [3:0]  |             |
| Adder_Out         | wire [7:0]  |             |
| ALU_Out           | wire [7:0]  |             |
| ALU_Oper2         | wire [7:0]  |             |

## Constants

| Name    | Type | Value | Description |
| ------- | ---- | ----- | ----------- |
| LOAD    |      | 2'b00 |             |
| FETCH   |      | 2'b01 |             |
| DECODE  |      | 2'B10 |             |
| EXECUTE |      | 2'B11 |             |

## Processes
- unnamed: ( @(posedge clk) )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always
- unnamed: ( @(*) )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always

## Instantiations

- ALU_unit: ALU
- MUX2_unit: MUX1
- DMem_unit: Data_Memory
- PMem_unit: PMem
- PC_Adder_unit: Adder
- MUX1_unit: MUX1
- Control_Logic_Unit: Control_Unit

## State machines

![Diagram_state_machine_0]( fsm_Microcontroller_00.svg "Diagram")