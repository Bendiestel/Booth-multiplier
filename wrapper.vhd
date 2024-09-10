library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wrapper is
    Port (
        input_operand : in std_logic_vector(7 downto 0);
        B0, B1, B2, B3 : in std_logic;
		  clock: in std_logic;
        segment0 : out std_logic_vector(6 downto 0);
        segment1 : out std_logic_vector(6 downto 0);
        segment2 : out std_logic_vector(6 downto 0);
		  done : out std_logic;
		  segment3 : out std_logic_vector(6 downto 0)
    );
end wrapper;

architecture example of wrapper is
    signal in1, in2 : std_logic_vector(7 downto 0);
	 signal mult_out : std_logic_vector(15 downto 0);
    signal code0, code1, code2, code3 : std_logic_vector(3 downto 0);
    signal cond : std_logic_vector(1 downto 0);
    --signal S, M, E, L: std_logic_vector(3 downto 0);
	 signal ready : std_logic;
    component LED_decoder is
        port (
            code : in std_logic_vector(3 downto 0);
            segments_out : out std_logic_vector(6 downto 0)
        );
    end component;

    component Booth_Mult is
        Port (
           In_1, In_2 : in std_logic_vector(7 downto 0);
			  clk : in std_logic;
			  ready : in std_logic;
			  done : out std_logic;
			  S : out std_logic_vector(15 downto 0)
        );
    end component;

begin
    process (B0) is
    begin
        if (B0 = '0') then
            in1 <= input_operand;
        end if;
    end process;

    process (B1) is
    begin
        if (B1 = '0') then
            in2 <= input_operand;
        end if;
    end process;

    process (B2, B3) is
			variable ready_c: std_logic_vector(1 downto 0);
	 begin 
			ready_c := B3 & B2;
			if (ready_c = "00") then 
				ready <= '1';
			else 
				ready <= '0';
			end if;
	 end process;

	 process(B2, B3) is 
	 begin 
		cond <= B2 & B3;
		if (cond = "01") then 
			code0 <= in1(3 downto 0);
			code1 <= in1(7 downto 4);
			code2 <= "0000";
			code3 <= "0000";
		elsif (cond = "10") then 
			code0 <= in2(3 downto 0);
			code1 <= in2(7 downto 4);
			code2 <= "0000";
			code3 <= "0000";
		else 
			code0 <= mult_out(3 downto 0);
			code1 <= mult_out(7 downto 4);
			code2 <= mult_out(11 downto 8);
			code3 <= mult_out(15 downto 12);
		end if;
	 end process;
	--done <= doneI;
   

	 mult : Booth_Mult port map (In_1 => in1, In_2 => in2, S => mult_out, ready => ready, clk => clock, done => done);

    s0 : LED_decoder port map (code => code0, segments_out => segment0);
    s1 : LED_decoder port map (code => code1, segments_out => segment1);
    s2 : LED_decoder port map (code => code2, segments_out => segment2);
	 s3 : LED_decoder port map (code => code3, segments_out => segment3);

end example;
