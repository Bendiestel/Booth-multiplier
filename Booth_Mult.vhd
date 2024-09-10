library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Booth_Mult is
    Port (
        In_1, In_2 : in std_logic_vector(7 downto 0);
        clk : in std_logic;
        ready : in std_logic;
        done : buffer std_logic;  -- changed from out to buffer because it gave us an error
        S : out std_logic_vector(15 downto 0)
    );
end Booth_Mult;

architecture Booth_Mult_Implementation of Booth_Mult is
begin
    process(clk)  --  sensitivity list should contain clock
        variable M, A : std_logic_vector(7 downto 0);
        variable Q : std_logic_vector(8 downto 0);
        variable I : unsigned(3 downto 0);
    begin
        if rising_edge(clk) then
            if ready = '1' then
                -- Initialization mm   
                M := In_1;
                Q(8 downto 1) := In_2;
                Q(0) := '0';
                A := (others => '0');
                I := (others => '0');  
                done <= '0';  
				
				
				-- start arithmetic computation
            elsif ready = '0' and done = '0' then
                -- case 1: 00 or 11, shift right
                if Q(1 downto 0) = "00" or Q(1 downto 0) = "11" then
                    Q := A(0) & Q(8 downto 1);
                    A := A(7) & A(7 downto 1);
					-- case 2: 01, sum of A and M concatenated with Q is shifted to the right
                elsif Q(1 downto 0) = "01" then
                    A := std_logic_vector(signed(A) + signed(M));
                    Q := A(0) & Q(8 downto 1);
                    A := A(7) & A(7 downto 1);
                elsif Q(1 downto 0) = "10" then
					 -- case 2: 01, difference of A and M concatenated with Q is shifted to the right
                    A := std_logic_vector(signed(A) - signed(M));
                    Q := A(0) & Q(8 downto 1);
                    A := A(7) & A(7 downto 1);
                end if;

                I := I + 1;  -- repeat for n times
            end if;

            -- Check to output results
            if I = "1000" then
                done <= '1';
                S <= A & Q(8 downto 1);
            else
                done <= '0';
                S <= (others => '0');  -- Reset S to zero
            end if;
        end if;
    end process;
end Booth_Mult_Implementation;