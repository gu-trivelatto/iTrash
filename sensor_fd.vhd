library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity sensor_fd is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        mede        : in  std_logic;
        echo        : in  std_logic;
        pronto      : out std_logic;
        trigger     : out std_logic;
        medida      : out std_logic_vector(11 downto 0)
    );
end entity;

architecture sensor_fd_arch of sensor_fd is

	component gerador_pulso is
		generic (
			largura: integer:= 25
		);
		port(
			clock:    in  std_logic;
			reset:    in  std_logic;
			gera:     in  std_logic;
			para:     in  std_logic;
			pulso:    out std_logic;
			pronto:   out std_logic
		);
	end component;

    component interface_hcsr04 port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        medir     : in  std_logic;
        echo      : in  std_logic;
        trigger   : out std_logic;
        medida    : out std_logic_vector (11 downto 0);
        pronto    : out std_logic;
        db_estado : out std_logic_vector (3 downto 0)
    );
    end component;

    signal s_reset, s_mede, s_echo, s_trigger, s_pronto : std_logic;
    signal s_medida : std_logic_vector(11 downto 0);

begin

    s_reset <= reset;
    s_mede <= mede;
	 
	 PULSO: gerador_pulso generic map (largura => 500) port map (clock, s_reset, s_mede, '0', s_trigger, open);

    trigger <= s_trigger;

end architecture;