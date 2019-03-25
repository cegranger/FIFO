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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity synchronous_FIFO_with_block_RAM is
     Generic ( W : natural := 16;    -- RAM address Width in bits
                  D : natural := 65536; -- RAM Depth in lines, equals to 2^W - Maximum Frequency: 106.199MHz
                  --W : natural := 6;    -- RAM address Width in bits
                  --D : natural := 64; -- RAM Depth in lines, equals to 2^W
                  B : natural := 16     -- Bus width
     );
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           enR : in  STD_LOGIC;
           enW : in  STD_LOGIC;
           emptyR : out  STD_LOGIC;
           fullW : out  STD_LOGIC;
           dataR : out  STD_LOGIC_VECTOR (B-1 downto 0);
           dataW : in  STD_LOGIC_VECTOR (B-1 downto 0));
end synchronous_FIFO_with_block_RAM;

architecture Behavioral of synchronous_FIFO_with_block_RAM is
    
    signal
        full,
        empty
            : std_logic;
    signal 
        writePtr,
        readPtr
            : std_logic_vector(W-1 downto 0);
    type
        ramT
            is array (D-1 downto 0) of std_logic_vector(B-1 downto 0);
    signal
        ram
            : ramT;

begin
    write_side : process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                writePtr <= (others => '0');
            else
                -- write pointer handling
                if enW = '1' and not full = '1' then
                    writePtr <= writePtr + '1';
                end if;
            end if;
        end if;
    end process;
    --set full flag
    full <= '1' when writePtr + '1' = readPtr else '0';
    fullW <= full;
    
    read_side : process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                readPtr <= (others => '0');
            else
                -- read pointer handling
                if enR = '1' and not empty = '1' then
                    readPtr <= readPtr + '1';
                end if;
            end if;
        end if;
    end process;
    --set empty flag
    empty <= '1' when readPtr = writePtr else '0';
    emptyR <= empty;
    
    dual_port_ram_write : process(clock)
    begin
        if rising_edge(clock) then
            if enW = '1' and not full = '1' then
                ram(conv_integer(writePtr)) <= dataW;
            end if;
      end if;
    end process;
    
    dual_port_ram_read : process(clock)
    begin
        if rising_edge(clock) then
            if enR = '1' and not empty = '1' then
                dataR <= ram(conv_integer(readPtr));
            end if;
      end if;
    end process;
    
end Behavioral;

