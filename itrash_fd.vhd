library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity servo_fd is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        mede        : in  std_logic;
        acionar     : in  std_logic;
        pwm         : out std_logic;
        closing_led : out std_logic;
        lid_open    : out std_logic;
        medida      : out std_logic_vector(7 downto 0)
    );
end entity;

architecture servo_fd_arch of servo_fd is

    component servo port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        acionar     : in  std_logic;
        pwm         : out std_logic;
        closing_led : out std_logic;
        lid_open    : out std_logic;
        db_estado   : out std_logic_vector(6 downto 0); -- TODO tirar sinais de depuração (deixar só estado)
        db_reset    : out std_logic;
        db_acionar  : out std_logic;
        db_pwm      : out std_logic
    );
    end component;

    signal s_reset, s_mede, s_acionar, s_pwm, s_closing_led, s_lid_open : std_logic;
    signal s_medida : std_logic_vector(7 downto 0);

begin

    s_reset <= reset;
    s_acionar <= acionar;

    SERVO: servo port map(clock, s_reset, s_acionar, s_pwm, s_closing_led, s_lid_open, open, open, open, open)

    pwm <= s_pwm;
    closing_led <= s_closing_led;
    lid_open <= s_lid_open;

end architecture;