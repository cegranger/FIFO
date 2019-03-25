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
 
ENTITY synchronousFIFOwithBlockRAM_TB IS
END synchronousFIFOwithBlockRAM_TB;
 
ARCHITECTURE behavior OF synchronousFIFOwithBlockRAM_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT synchronousFIFOwithBlockRAM
    PORT(
         reset : IN  std_logic;
         clock : IN  std_logic;
         enR : IN  std_logic;
         enW : IN  std_logic;
         emptyR : OUT  std_logic;
         fullW : OUT  std_logic;
         dataR : OUT  std_logic_vector(15 downto 0);
         dataW : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
   
    --Tester hw 
    signal enLate : std_logic;
    signal reg : std_logic_vector(15 downto 0);
    
   --Inputs
   signal reset : std_logic := '0';
   signal clock : std_logic := '0';
   signal enR : std_logic := '0';
   signal enW : std_logic := '0';
   signal dataW : std_logic_vector(15 downto 0) := (others => '0');

    --Outputs
   signal emptyR : std_logic;
   signal fullW : std_logic;
   signal dataR : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut: synchronousFIFOwithBlockRAM PORT MAP (
          reset => reset,
          clock => clock,
          enR => enR,
          enW => enW,
          emptyR => emptyR,
          fullW => fullW,
          dataR => dataR,
          dataW => dataW
        );

   -- Clock process definitions
   clock_process :process
   begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin        
      -- hold reset state for 100 ns.
        reset <= '1';
      wait for 100 ns;  
        reset <= '0';
      wait for clock_period*10;
      dataW <= x"dead";
        enW <= '1';
        wait for clock_period;
        dataW <= x"beef";
        wait for clock_period;
        dataW <= x"abcd";
        wait for clock_period;
        dataW <= x"ef01";
        wait for clock_period;
        dataW <= x"2345";
        wait for clock_period;
        enW <= '0';
      wait for clock_period*10;
        --enR <= '1';
      --wait for clock_period;
        
      -- insert stimulus here 

      wait;
   end process;
    
    enR <= not emptyR;
    
    process(clock)
        begin
        if rising_edge(clock) then
            enLate <= not emptyR;
            if enLate = '1' then
                reg <= dataR;
            end if;
        end if;
    end process;
END;
