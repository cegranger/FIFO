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

entity asynchron_FIFO_asymmetric_ports is
     Generic ( W : natural := 8;   -- RAM address Width in bits
                  D : natural := 256; -- RAM Depth in lines, equals to 2^W - 256 depth Maximum Frequency: 145.773MHz
                  --W : natural := 4;   -- RAM address Width in bits
                  --D : natural := 16; -- RAM Depth in lines, equals to 2^W - 256 depth Maximum Frequency: 145.773MHz
                  B : natural := 16   -- Input bus width
     );
    Port ( resetR : in  STD_LOGIC;
           resetW : in  STD_LOGIC;
           clockR : in  STD_LOGIC;
           clockW : in  STD_LOGIC;
           enR : in  STD_LOGIC;
           enW : in  STD_LOGIC;
           emptyR : out  STD_LOGIC;
           fullW : out  STD_LOGIC;
           dataR : out  STD_LOGIC_VECTOR (B/2-1 downto 0);
           dataW : in  STD_LOGIC_VECTOR (B-1 downto 0));
end asynchron_FIFO_asymmetric_ports;

architecture Behavioral of asynchron_FIFO_asymmetric_ports is
    
    signal
        full,
        empty,
        toggle
            : std_logic;
    signal 
        writePtr,
        syncReadPtrBin,
        readPtrGraySync0,
        readPtrGraySync1,
        writePtrGray,
        readPtrBin,
        readPtr,
        syncWritePtrBin,
        writePtrGraySync0,
        writePtrGraySync1,
        readPtrGray,
        writePtrBin
            : std_logic_vector(W-1 downto 0);
    type
        ramT
            is array (D-1 downto 0) of std_logic_vector(B-1 downto 0);
    signal
        ram
            : ramT;

begin
    write_side : process(clockW)
    begin
        if rising_edge(clockW) then
            if resetW = '1' then
                writePtr <= (others => '0');
                writePtrGray <= (others => '0');
                syncReadPtrBin <= (others => '0');
                readPtrGraySync0 <= (others => '0');
                readPtrGraySync1 <= (others => '0');
            else
                -- write pointer handling
                if enW = '1' and not full = '1' then
                    writePtr <= writePtr + '1';
                end if;
                --write pointer to gray code conversion
                writePtrGray <= writePtr xor ('0' & writePtr(W-1 downto 1));
                --gray coded read pointer synchronisation
                readPtrGraySync0 <= readPtrGray;
                readPtrGraySync1 <= readPtrGraySync0;
                --register read pointer in order to be resetable
                syncReadPtrBin <= readPtrBin;
            end if;
        end if;
    end process;
    --read pointer to binary conversion
    readPtrBin(W-1) <= readPtrGraySync1(W-1);
    gray2binW : for i in W-2 downto 0 generate
        readPtrBin(i) <= readPtrBin(i+1) xor readPtrGraySync1(i);
    end generate;
    --set full flag
    full <= '1' when writePtr + '1' = syncReadPtrBin else '0';
    fullW <= full;
    
    read_side : process(clockR)
    begin
        if rising_edge(clockR) then
            if resetR = '1' then
                toggle <= '0';
                readPtr <= (others => '0');
                readPtrGray <= (others => '0');
                syncWritePtrBin <= (others => '0');
                writePtrGraySync0 <= (others => '0');
                writePtrGraySync1 <= (others => '0');
            else
                -- read pointer handling
                if enR = '1' and not empty = '1' then
                    if toggle = '1' then
                        toggle <= '0';
                        readPtr <= readPtr + '1';
                    else
                        toggle <= '1';
                    end if;
                end if;
                --read pointer to gray code conversion
                readPtrGray <= readPtr xor ('0' & readPtr(W-1 downto 1));
                --gray coded write pointer synchronisation
                writePtrGraySync0 <= writePtrGray;
                writePtrGraySync1 <= writePtrGraySync0;
                --register write pointer in order to be resetable
                syncWritePtrBin <= writePtrBin;
            end if;
        end if;
    end process;
    --write pointer to binary conversion
    writePtrBin(W-1) <= writePtrGraySync1(W-1);
    gray2binR : for i in W-2 downto 0 generate
        writePtrBin(i) <= writePtrBin(i+1) xor writePtrGraySync1(i);
    end generate;
    --set empty flag
    empty <= '1' when readPtr = syncWritePtrBin else '0';
    emptyR <= empty;
    
    dual_port_ram : process(clockW)
    begin
        if rising_edge(clockW) then
            if enW = '1' and not full = '1' then
                ram(conv_integer(writePtr)) <= dataW;
            end if;
      end if;
    end process;
    dataR <= ram(conv_integer(readPtr))(B-1 downto B/2) when toggle = '1' else
                ram(conv_integer(readPtr))(B/2-1 downto 0) when toggle = '0';
    
end Behavioral;

