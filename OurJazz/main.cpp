#include "utils.h"
using namespace std;

/* Processor */

/* Maybe we should reduce the constraints for the first try */

// Parameters
const size_t word_size = 32;
const size_t page_size = 128;

const size_t addr_up_size = 22;
const size_t addr_down_size = 2;
const size_t addr_size = addr_up_size + addr_down_size;

const size_t reg_addr_size = 4;
const size_t nb_registers = (1 << reg_addr_size);

const size_t instr_size = 4 * word_size;

const size_t real_opcode_size = 4;
const size_t opcode_size = 16;
const size_t param_size = 16;
const size_t lhs_size = 32;
const size_t rhs_size = 32;
/* followed by addr and reg_res */

/* Named Wires */

// Ram
string ram_read, ram_write, ram_update, ram_output, ram_data;

// Instruction register
string reg_instr_update;
vector<string> reg_instr_output, reg_instr_input;

// Other registers
vector<vector<string>> reg_inputs, reg_outputs;
vector<string> reg_updates;

// Instruction

vector<string> lhs, rhs;

// ALU
vector<string> ret;

// Clock

string clock_bit;

int main() { 
   // Constant 4
   vector<string> quatre = vector<string>(word_size, "0");
   quatre[2] = "1";

   // Create clock
   
   clock_bit = decl_var();
   string nclock = op_not(clock_bit);
   reg(clock_bit, nclock);
   
   // Init ram
   ram_output = decl_var(page_size);
   ram_data = decl_var(page_size);
   ram_update = decl_var();
   ram_read = decl_var(addr_up_size);
   ram_write = decl_var(addr_up_size);
   
   ram(ram_output, addr_up_size, page_size, ram_read, ram_update, ram_write, ram_data);
   
   // Init instruction register
   reg_instr_update = decl_var();
   for(size_t iBit = 0;iBit < instr_size;iBit++) {
      reg_instr_output.push_back(decl_var());
      reg_instr_input.push_back(decl_var());
      memory(reg_instr_output[iBit], reg_instr_input[iBit], reg_instr_update);
   }
   
   // Init other registers
   for(size_t iReg = 0;iReg < nb_registers;iReg++) {
      reg_outputs.push_back(vector<string>());
      reg_inputs.push_back(vector<string>());
      reg_updates.push_back(decl_var());
      for(size_t iBit = 0;iBit < word_size;iBit++) {
         reg_outputs[iReg].push_back(decl_var());
         reg_inputs[iReg].push_back(decl_var());
         memory(reg_outputs[iReg][iBit], reg_inputs[iReg][iBit], reg_updates[iReg]);
      }
   }
   
   // RAM addr
   
   string addrIsReg = reg_instr_output[opcode_size + 6];
   
   vector<string> addr;
   
   vector<string> regNum;
   for(size_t iBit = 0;iBit < reg_addr_size;iBit++) {
      regNum.push_back(reg_instr_output[3 * word_size + iBit]);
   }
   
   vector<string> regCont = selector(reg_outputs, regNum);
   for(size_t iBit = 0;iBit < addr_size;iBit++) {
      addr.push_back(mux(reg_instr_output[3 * word_size + iBit], regCont[iBit], addrIsReg));
   }
   
   vector<string> addr_up;
   for(size_t iBit = 0;iBit < addr_up_size;iBit++) {
      addr_up.push_back(addr[addr_down_size + iBit]);
   }
   
   vector<string> addr_down;
   for(size_t iBit = 0;iBit < addr_down_size;iBit++) {
      addr_down.push_back(addr[iBit]);
   }
   
   // Select RAM read addr
   
   vector<string> read_addr_bits;
   for(size_t iBit = 0;iBit < addr_up_size;iBit++) {
      read_addr_bits.push_back(
         mux(reg_outputs[0][addr_down_size + iBit], addr_up[iBit], clock_bit)
      );
   }
   
   assign(ram_read, concat(read_addr_bits));
   
   // Cut RAM output into words
   
   vector<vector<string>> ram_words;
   for(size_t iWord = 0;iWord < 4;iWord++) {
      ram_words.push_back(vector<string>());
      
      for(size_t iBit = 0;iBit < word_size;iBit++) {
         ram_words.back().push_back(select(ram_output, iWord * word_size + iBit));
      }
   }
   
   // Update instruction register
   
   for(size_t iBit = 0;iBit < page_size;iBit++) {
      assign(reg_instr_input[iBit], ram_words[iBit / word_size][iBit % word_size]);
   }
   assign(reg_instr_update, "1");
   
   vector<string> incRip = add_bits(reg_outputs[0], quatre);
   
   // Decode instruction
   
   string aRam = reg_instr_output[opcode_size + 0];
   string bRam = reg_instr_output[opcode_size + 1];
   string wRam = reg_instr_output[opcode_size + 2];
   string wReg = reg_instr_output[opcode_size + 3];
   string aCst = reg_instr_output[opcode_size + 4];
   string bCst = reg_instr_output[opcode_size + 5];
   
   vector<string> op_code;
   for(size_t iBit = 0;iBit < real_opcode_size;iBit++) {
      op_code.push_back(reg_instr_output[iBit]);
   }
   
   vector<string> aReg, bReg, cReg;
   
   for(size_t iBit = 0;iBit < reg_addr_size;iBit++) {
      aReg.push_back(reg_instr_output[word_size + iBit]);
      bReg.push_back(reg_instr_output[2 * word_size + iBit]);
      cReg.push_back(reg_instr_output[3 * word_size + addr_size + iBit]);
   }
   
   // Select LHS and RHS
   
   vector<string> outputRegA = selector(reg_outputs, aReg);
   vector<string> outputRegB = selector(reg_outputs, bReg);
   vector<string> outputRam = selector(ram_words, addr_down);
   
   for(size_t iBit = 0;iBit < word_size;iBit++) {
      lhs.push_back(
         mux(mux(outputRegA[iBit], outputRam[iBit], aRam), reg_instr_output[word_size + iBit], aCst)
      );
      
      rhs.push_back(
         mux(mux(outputRegB[iBit], outputRam[iBit], bRam), reg_instr_output[2 * word_size + iBit], bCst)
      );
   }
   
   // ALU
   vector<vector<string>> gate_outputs;
   
   // MOV gate
   gate_outputs.push_back(lhs);
   
   // INC gate
   gate_outputs.push_back(inc_bits(lhs));
   
   // ADD gate
   gate_outputs.push_back(add_bits(lhs, rhs));
   
   // NOT gate
   gate_outputs.push_back(not_bits(lhs));
   
   // NEG gate
   gate_outputs.push_back(neg_bits(lhs));
   
   // SUB gate
   gate_outputs.push_back(sub_bits(lhs, rhs));
   
   // XOR gate
   gate_outputs.push_back(xor_bits(lhs, rhs));
   
   // OR gate
   gate_outputs.push_back(or_bits(lhs, rhs));
   
   // AND gate
   gate_outputs.push_back(and_bits(lhs, rhs));
   
   // MUL gate
   gate_outputs.push_back(mul_bits(lhs, rhs));
   
   string is_lhs_zero = is_zero(lhs);
   // JIZ gate
   gate_outputs.push_back(mux(incRip, rhs, is_lhs_zero));
   
   // JNZ gate
   gate_outputs.push_back(mux(incRip, rhs, op_not(is_lhs_zero)));
   
   while(gate_outputs.size() < (1 << real_opcode_size)) {
      gate_outputs.push_back(vector<string>(word_size, "0"));
   }
   
   ret = selector(gate_outputs, op_code);
   
   // Write result to RAM
   
   vector<string> select_ram = dispatcher(addr_down);
   vector<string> final_data;
   for(size_t iWord = 0;iWord < 4;iWord++) {
      for(size_t iBit = 0;iBit < word_size;iBit++) {
         final_data.push_back(mux(ram_words[iWord][iBit], ret[iBit], select_ram[iWord]));
      }
   }
   
   assign(ram_update, op_and(wRam, clock_bit));
   assign(ram_write, concat(addr_up));
   assign(ram_data, concat(final_data));
   
   // Write result to registers
   
   vector<string> select_reg = dispatcher(cReg);
   
   // For RIP
   
   string mustW = op_and(wReg, clock_bit);
   
   for(size_t iBit = 0;iBit < word_size;iBit++) {
      assign(reg_inputs[0][iBit], mux(incRip[iBit], ret[iBit], op_and(mustW, select_reg[0])));
   }
   assign(reg_updates[0], clock_bit);
   
   // For other registers
   
   for(size_t iReg = 1;iReg < nb_registers;iReg++) {
      for(size_t iBit = 0;iBit < word_size;iBit++) {
         assign(reg_inputs[iReg][iBit], ret[iBit]);
      }
      assign(reg_updates[iReg], op_and(mustW, select_reg[iReg]));
   }
   
   // Debug section : put here every non-useful variable
   
   
   //decl_output(concat(ret));
   decl_output(concat(reg_outputs[0]));
   decl_output(ram_output);
   decl_output(concat(reg_outputs[1]));
   
   // Write netlist to stdout
   write();
   
   return 0;
}
