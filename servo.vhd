library ieee;
use ieee.std_logic_1164.all;

entity servo is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        acionar     : in  std_logic;
        pwm         : out std_logic;
        closing_led : out std_logic;
        lid_open    : out std_logic;
        db_estado   : out std_logic_vector(6 downto 0);
        db_reset    : out std_logic;
        db_acionar  : out std_logic;
        db_pwm      : out std_logic
    );
end entity;

architecture servo_arch of servo is

    component servo_uc port(
        clock       : in  std_logic;
        reset       : in  std_logic;
        acionar     : in  std_logic;
        close_mid   : in  std_logic;
        close_end   : in  std_logic;
        lid_open    : out std_logic;
        reset_timer : out std_logic;
        count_mid   : out std_logic;
        count_end   : out std_logic;
        estado_hex  : out std_logic_vector(3 downto 0)
    );
    end component;

    component servo_fd port(
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
    end component;

    component hex7seg is port (
        hexa: in std_logic_vector (3 downto 0);
        sseg: out std_logic_vector (6 downto 0)
    );
    end component;

    component edge_detector is port ( 
        clk       : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
    end component;

    signal s_reset, s_acionar, s_acionar_ed, s_close_mid, s_close_end, s_lid_open, s_reset_timer, s_count_mid, s_count_end, s_pwm, s_state : std_logic;

begin

    s_reset <= reset;
    s_acionar <= acionar;

    UC: servo_uc port map(clock, s_reset, s_acionar_ed, s_close_mid, s_close_end, s_lid_open, s_reset_timer, s_count_mid, s_count_end, s_state);

    FD: servo_fd port map(clock, s_reset, s_lid_open, s_reset_timer, s_count_mid, s_count_end, s_pwm, s_close_mid, s_close_end);

    ED: edge_detector port map(clock, s_acionar, s_acionar_ed);

    SSEG: hex7seg port map(s_state, db_estado);

    pwm <= s_pwm;
    closing_led <= s_close_mid;
    lid_open <= s_lid_open;

    db_reset <= s_reset;
    db_acionar <= s_acionar;
    db_pwm <= s_pwm;

end architecture;