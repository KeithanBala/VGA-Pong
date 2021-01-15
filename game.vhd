library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USe IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity game is
	Port ( 
	clk		: in STD_LOGIC;
	H			: out STD_LOGIC;
	V			: out STD_LOGIC;
	DAC_CLK	: out STD_LOGIC;
	Rout		: out STD_LOGIC_VECTOR(7 downto 0);
	Gout		: out STD_LOGIC_VECTOR(7 downto 0);
	Bout		: out STD_LOGIC_VECTOR(7 downto 0);
	SW0		: in STD_LOGIC;
	SW1		: in STD_LOGIC;
	SW2		: in STD_LOGIC;
	SW3		: in STD_LOGIC
	);
end game;

architecture Behavioral of game is
signal halfclock : std_logic;
signal horizontal_res, vertical_res, wait1 : Integer := 0;
signal h_pixel : integer range 0 to 640;
signal v_pixel : integer range 0 to 480;
signal player1, player2 : Integer := 158;
signal ball_x  : Integer :=312;
signal ball_y : Integer := 232;
signal xMove, yMove : Integer := 4;

component icon
  PORT (
    CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));

end component;

component ila
  PORT (
    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    CLK : IN STD_LOGIC;
    DATA : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    TRIG0 : IN STD_LOGIC_VECTOR(0 TO 0));

end component;

signal control0: std_logic_vector(35 downto 0);
signal ila_data: std_logic_vector(1 downto 0);
signal trig0: std_logic_vector(0 to 0);
signal Hsync: std_logic;
signal Vsync: std_logic;

BEGIN


sys_icon: icon port map(control0);
sys_ila: ila port map(control0,clk,ila_data,trig0);
--Halves the clock time
PROCESS (clk)
BEGIN
	IF (rising_edge(clk)) THEN
		IF (halfclock = '1') THEN
			halfclock <= '0';
		ELSE
			halfclock <= '1';
		END IF;
	END IF;
END PROCESS;
DAC_CLK <= halfclock;

PROCESS(halfclock)
BEGIN
-- 25 MHz clock
IF (rising_edge(halfclock)) THEN

	IF (horizontal_res = 800) THEN
		vertical_res <= vertical_res + 1;
		horizontal_res <= 0;
	ELSE
		horizontal_res <= horizontal_res + 1;
	END IF;	
	IF (vertical_res = 525) THEN
		vertical_res <= 0;
	END IF;
	IF (horizontal_res >= 656 AND horizontal_res <= 751) THEN
		H <= '0'; -- Horizontal sync 
		Hsync <= '0';
	ELSE
		H <= '1';
		Hsync <= '1';
	END IF;
	IF (vertical_res >= 490 AND vertical_res <= 491) THEN
		V <= '0'; -- Vertical sync
		Vsync <= '0';		
	ELSE
		V <= '1'; 
		Vsync <= '1';
	END IF;
END IF;
END PROCESS;

-- Static
PROCESS (halfclock, horizontal_res, vertical_res)
BEGIN
IF (rising_edge(halfclock)) THEN
	
			h_pixel<=horizontal_res;
			v_pixel<=vertical_res;
			
			if(h_pixel > 0 and h_pixel < 640 and v_pixel > 0 and v_pixel < 12)then
					ROUT <= "00000000";		
					GOUT <= "11111111";
					BOUT <= "00000000";    --top green
			elsif(h_pixel > 0 and h_pixel < 12 and v_pixel > 0 and v_pixel < 480)then
					ROUT <= "00000000";		
					GOUT <= "11111111";
					BOUT <= "00000000"; --top left edge green
			elsif(h_pixel > 628 and h_pixel < 640 and v_pixel > 0 and v_pixel < 480)then
					ROUT <= "00000000";		
					GOUT <= "11111111";
					BOUT <= "00000000";  --top right edge green		
			elsif(h_pixel >= 12 and h_pixel <= 628 and v_pixel >= 12 and v_pixel <= 34)then
					ROUT <= "11111111";		
					GOUT <= "11111111";
					BOUT <= "11111111";  --top border
			elsif(h_pixel >= 12 and h_pixel <= 628 and v_pixel >= 450 and v_pixel <= 472)then
					ROUT <= "11111111";		
					GOUT <= "11111111";
					BOUT <= "11111111";   --bottom border		
			elsif(h_pixel > 0 and h_pixel < 640 and v_pixel > 472 and v_pixel < 480)then
					ROUT <= "00000000";		
					GOUT <= "11111111";
					BOUT <= "00000000";     --bottom green
			elsif(h_pixel >= 12 and h_pixel <= 36 and v_pixel >= 34 and v_pixel <= 150)then
					ROUT <= "11111111";		
					GOUT <= "11111111";
					BOUT <= "11111111";  --top left border
			elsif(h_pixel >= 604 and h_pixel <= 628 and v_pixel >= 34 and v_pixel <= 150)then
					ROUT <= "11111111";		
					GOUT <= "11111111";
					BOUT <= "11111111";  --top right border
			elsif(h_pixel >= 12 and h_pixel <= 36 and v_pixel >= 334 and v_pixel <= 472)then
					ROUT <= "11111111";		
					GOUT <= "11111111";
					BOUT <= "11111111";  --bottom left border
			elsif(h_pixel >= 604 and h_pixel <= 628 and v_pixel >=334 and v_pixel <= 472)then
					ROUT <= "11111111";		
					GOUT <= "11111111";
					BOUT <= "11111111";  --bottom right border
			elsif((h_pixel > 628 and h_pixel < 640 and v_pixel > 34 and v_pixel < 334) 
			or (not(h_pixel <= 324 and h_pixel >= 316) and h_pixel > 36 and h_pixel < 604 and v_pixel >34 and v_pixel < 472))then
					ROUT <= "00000000";		
					GOUT <= "11111111";
					BOUT <= "00000000";     --middle green	
			elsif(h_pixel <= 324 and h_pixel >= 316 and v_pixel >= 79 and v_pixel < 159)then
					ROUT <= "00000000";		
					GOUT <= "11111111";
					BOUT <= "00000000";     --middle green	
			elsif(h_pixel <= 324 and h_pixel >= 316 and v_pixel >= 202 and v_pixel < 282)then
					ROUT <= "00000000";		
					GOUT <= "11111111";
					BOUT <= "00000000";     --middle green	
			elsif(h_pixel <= 324 and h_pixel >= 316 and v_pixel >= 325 and v_pixel < 405)then
					ROUT <= "00000000";		
					GOUT <= "11111111";
					BOUT <= "00000000";     --middle green	
			elsif((h_pixel >= 12 and h_pixel <=36 and v_pixel>150 and v_pixel<334) or (h_pixel>=604 and h_pixel<=628 and v_pixel >150 and v_pixel <334))then
					ROUT<="00000000";
					GOUT<="11111111";
					BOUT<="00000000"; --goal posts
			elsif(h_pixel <= 324 and h_pixel >= 316 and v_pixel >= 34 and v_pixel < 78) then
					ROUT<="00000000";
					GOUT<="00000000";
					BOUT<="00000000"; --middle partitions
		   elsif(h_pixel <= 324 and h_pixel >= 316 and v_pixel >= 160 and v_pixel < 201) then
					ROUT<="00000000";
					GOUT<="00000000";
					BOUT<="00000000"; --middle partitions
			elsif(h_pixel <= 324 and h_pixel >= 316 and v_pixel >= 283 and v_pixel < 324) then
					ROUT<="00000000";
					GOUT<="00000000";
					BOUT<="00000000"; --middle partitions
			elsif(h_pixel <= 324 and h_pixel >= 316 and v_pixel >= 406 and v_pixel < 448) then
					ROUT<="00000000";
					GOUT<="00000000";
					BOUT<="00000000"; --middle partitions
			else
					ROUT <= (OTHERS => '0');		
					GOUT <= (OTHERS => '0');
					BOUT <= (OTHERS => '0');
			end if;	
		
	if(horizontal_res > 44 AND horizontal_res <=60 AND vertical_res> player1 AND vertical_res<= player1 + 117) THEN
		ROUT <= "00000000";
		GOUT <= "00000000";
		BOUT <= "11111111";

	elsif(horizontal_res > 580 AND horizontal_res <=596 AND vertical_res> player2 AND vertical_res<= player2 + 117) THEN
		ROUT <= "11111111";
		GOUT <= "00000000";
		BOUT <= "11111111";
	
	elsif(horizontal_res > ball_x AND horizontal_res <= ball_x+16 AND vertical_res>ball_y AND vertical_res<=(ball_y+16)) THEN
		if((ball_x <= 36 OR ball_x+16 >= 604) AND (ball_y > 150 AND ball_y+16 < 334)) THEN
			ROUT <= "11111111";
			GOUT <= "00000000";
			BOUT <= "00000000";
			if(wait1 = 2000) THEN
				ball_x <= 312;
				ball_y <= 232;
				wait1 <= 0;
			else
				wait1 <= wait1 + 1;
			end if;
		else
			ROUT <= "11111111";
			GOUT <= "11111111";
			BOUT <= "00000000";
		end if;		
	
	END IF;
	
	if(horizontal_res = 639 AND vertical_res = 479)THEN

		--Walls
		if(ball_x <= 36 OR ball_x+16 >= 604) THEN
			if(ball_y > 150 AND ball_y < 334) THEN

			else
				if(ball_x <= 36) THEN
					xMove <= 4;
				else
					xMove <= -4;
				end if;
			end if;
		end if;
		
		--Bottom and top
		if(ball_y <= 36) THEN
			yMove <= 4;
		end if;
		if(ball_y+16 >= 448) THEN
			yMove <= -4;
		end if;
		
		--players
		if((ball_x <= 60 AND ball_x+16 >=44) AND (ball_y+16 > player1 AND ball_y < player1+117)) THEN
			xMove <= 4;
		end if;
		
		if((ball_x+16 >= 581 AND ball_x<=597) AND(ball_y+16 > player2 AND ball_y < player2+117)) THEN
			xMove <= -4;
		end if;
		
		if ((SW2 XOR SW3) = '1') then		
			if (SW2 = '1' AND player2 >= 37) then 
				player2 <= player2 - 4;
			elsif (SW3 = '1' AND player2 + 117 <= 447) then  
				player2 <= player2 + 4;
			end if;
		end if;
		if ((SW0 XOR SW1) = '1') then		
			if (SW0 = '1' AND player1 >= 37) then 
				player1 <= player1 - 4;
			elsif (SW1 = '1' AND player1 + 117 <= 447) then  
				player1 <= player1 + 4;
			end if;
		end if;
		if(NOT((ball_x <= 36 OR ball_x+16 >= 604) AND (ball_y > 150 AND ball_y < 334))) THEN
			ball_x <= ball_x + xMove;
			ball_y <= ball_y + yMove;
		end if;
	end if;
End IF;
END PROCESS;	

ila_data(1) <= Hsync;
ila_data(0) <= Vsync;
end Behavioral;