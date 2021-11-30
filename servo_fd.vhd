library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity servo_fd is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        lid_open    : in  std_logic;
        reset_timer : in  std_logic;
        count_mid   : in  std_logic;
        count_end   : in  std_logic;
        pwm         : out std_logic;
        close_mid   : out std_logic;
        close_end   : out std_logic
    );
end entity;

architecture servo_fd_arch of servo_fd is

    component controle_servo port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        posicao     : in  std_logic;
        pwm         : out std_logic;
        db_reset    : out std_logic;
        db_pwm      : out std_logic;
        db_posicao  : out std_logic
    );
    end component;

    component contadorg_m
    generic (
        constant M: integer := 50
    );
    port (
        clock, zera_as, zera_s, conta : in  std_logic;
        Q                             : out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
        fim, meio                     : out std_logic 
    );
    end component;

    signal s_reset, s_lid_open, s_reset_timer, s_count_sec, s_count_end, s_close_mid, s_close_end, s_pwm, s_fim : std_logic;

begin

    s_reset <= reset;
    s_lid_open <= lid_open;
    s_reset_timer <= reset_timer;
    s_count_sec <= count_mid or count_end;
    s_count_end <= count_end and s_fim;

    SERVO: controle_servo port map(clock, s_reset, s_lid_open, s_pwm, open, open, open);

    ONE_SEC: contadorg_m generic map (M => 50000000) port map (clock, s_reset_timer, '0', s_count_sec, open, s_fim, open);

    -- original = 290
	 CONT1: contadorg_m generic map (M=>20) port map(clock, s_reset_timer, '0', s_fim, open, s_close_mid, open);

    CONT2: contadorg_m generic map (M=>10) port map(clock, s_reset_timer, '0', s_count_end, open, s_close_end, open);

    pwm <= s_pwm;
    close_mid <= s_close_mid;
    close_end <= s_close_end;

end architecture;