--Implementation based upon http://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf

--MIT License
--
--Copyright (c) 2018 Balazs Valer Fekete
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY asynchronFIFOasymmetricPorts_TB IS
END asynchronFIFOasymmetricPorts_TB;
 
ARCHITECTURE behavior OF asynchronFIFOasymmetricPorts_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT asynchronFIFOasymmetricPorts
    PORT(
         resetR : IN  std_logic;
         resetW : IN  std_logic;
         clockR : IN  std_logic;
         clockW : IN  std_logic;
         enR : IN  std_logic;
         enW : IN  std_logic;
         emptyR : OUT  std_logic;
         fullW : OUT  std_logic;
         dataR : OUT  std_logic_vector(7 downto 0);
         dataW : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal resetR : std_logic := '0';
   signal resetW : std_logic := '0';
   signal clockR : std_logic := '0';
   signal clockW : std_logic := '0';
   signal enR : std_logic := '0';
   signal enW : std_logic := '0';
   signal dataW : std_logic_vector(15 downto 0) := (others => '0');

    --Outputs
   signal emptyR : std_logic;
   signal fullW : std_logic;
   signal dataR : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clockR_period : time := 16 ns;
   constant clockW_period : time := 12.5 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut: asynchronFIFOasymmetricPorts PORT MAP (
          resetR => resetR,
          resetW => resetW,
          clockR => clockR,
          clockW => clockW,
          enR => enR,
          enW => enW,
          emptyR => emptyR,
          fullW => fullW,
          dataR => dataR,
          dataW => dataW
        );

   -- Clock process definitions
   clockR_process :process
   begin
        clockR <= '0';
        wait for clockR_period/2;
        clockR <= '1';
        wait for clockR_period/2;
   end process;
 
   clockW_process :process
   begin
        clockW <= '0';
        wait for clockW_period/2;
        clockW <= '1';
        wait for clockW_period/2;
   end process;
 
   -- Stimulus process
   stim_proc_reset: process
   begin        
      -- hold reset state for 100 ns.
        resetR <= '1';
        resetW <= '1';
      wait for 100 ns;  
        resetR <= '0';
        resetW <= '0';
      wait;
   end process;

   stim_proc_write: process
   begin        
      wait for 100 ns;  
      -- insert stimulus here
      wait for clockW_period*10;
        enW <= '1';
        dataW <= x"dead";
      wait for clockW_period;
        dataW <= x"beef";
      wait for clockW_period;
        enW <= '0';
      wait for clockW_period*30;
        enW <= '1';
        dataW <= x"abcd";
      wait for clockW_period;
        dataW <= x"ef01";
      wait for clockW_period*40;
        enW <= '0';
      wait;
   end process;
    
   stim_proc_read: process
   begin        
      wait for 100 ns;  
      -- insert stimulus here
      wait for clockR_period*20;
        enR <= '1';
      wait for clockR_period*8;
      enR <= '0';
      wait for clockR_period*8;
      enR <= '1';
        wait;
   end process;

END;
