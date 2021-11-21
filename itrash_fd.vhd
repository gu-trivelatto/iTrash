library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity servo_fd is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        mede         : in  std_logic;
        acionar      : in  std_logic;
        echo         : in  std_logic;
        pwm          : out std_logic;
        closing_led  : out std_logic;
        lid_open     : out std_logic;
        medida       : out std_logic_vector(7 downto 0);
        saida_serial : out std_logic;
        trigger      : out std_logic
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

    component modulo_medida is
        port (
            clock        : in  std_logic;
            reset        : in  std_logic;
            aberto       : in  std_logic;
            echo         : in  std_logic;
            saida_serial : out std_logic;
            trigger      : out std_logic;
            db_estado    : out std_logic
        );
    end component;

    signal s_reset, s_mede, s_acionar, s_pwm, s_closing_led : std_logic;
    signal s_lid_open, s_echo, s_saida_serial, s_trigger : std_logic;
    signal s_medida : std_logic_vector(7 downto 0);
    signal s_db_estado_medida : std_logic_vector(3 downto 0);

begin

    s_reset <= reset;
    s_acionar <= acionar;
    s_echo <= echo;

    SERVO: servo port map(clock, s_reset, s_acionar, s_pwm, s_closing_led, s_lid_open, open, open, open, open);

    MEDIDA: modulo_medida port map(clock, s_reset, s_lid_open, s_echo, s_saida_serial, s_trigger, s_db_estado_medida);

    pwm <= s_pwm;
    closing_led <= s_closing_led;
    lid_open <= s_lid_open;
    saida_serial <= s_saida_serial;
    trigger <= s_trigger;

end architecture;