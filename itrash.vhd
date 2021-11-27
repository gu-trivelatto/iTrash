library ieee;
use ieee.std_logic_1164.all;

entity itrash is
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        acionar        : in  std_logic;
        echo           : in  std_logic;
		  entrada_serial : in  std_logic;
        pwm            : out std_logic;
        closing_led    : out std_logic;
        slider         : out std_logic_vector(7 downto 0);
        saida_serial   : out std_logic;
        trigger        : out std_logic;
		  aberto         : out std_logic;
		  cap_led        : out std_logic_vector(1 downto 0);
        db_estado      : out std_logic_vector(6 downto 0);
        db_uni_hex     : out std_logic_vector(6 downto 0);
        db_dec_hex     : out std_logic_vector(6 downto 0);
        db_reset       : out std_logic;
        db_acionar     : out std_logic;
        db_pwm         : out std_logic
    );
end entity;

architecture itrash_arch of itrash is

    component itrash_uc port(
        clock      : in  std_logic;
        reset      : in  std_logic;
        lid_open   : in  std_logic;
        mede       : out std_logic;
        estado_hex : out std_logic_vector(3 downto 0)
    );
    end component;

    component itrash_fd port(
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
		  cap_led      : out std_logic_vector(1 downto 0);
        trigger      : out std_logic;
        entrada_serial : in std_logic
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

    signal s_reset, s_acionar, s_acionar_ed, s_mede, s_pwm, s_saida_serial, s_entrada_serial : std_logic;
    signal s_closing_led, s_lid_open, s_echo, s_trigger : std_logic;
    signal s_medida : std_logic_vector(7 downto 0);
    signal s_state : std_logic_vector(3 downto 0);
	 signal s_cap_led : std_logic_vector(1 downto 0);

begin

    s_reset <= reset;
    s_acionar <= acionar;
    s_echo <= echo;
    s_entrada_serial <= entrada_serial;

    UC: itrash_uc port map(clock, s_reset, s_lid_open, s_mede, s_state);

    FD: itrash_fd port map(clock, s_reset, s_mede, s_acionar_ed, s_echo, s_pwm, s_closing_led, 
                          s_lid_open, s_medida, s_saida_serial, s_cap_led, s_trigger, s_entrada_serial);

    ED: edge_detector port map(clock, s_acionar, s_acionar_ed);

    SSEG: hex7seg port map(s_state, db_estado);

    SSEG_UNI: hex7seg port map(s_medida(3 downto 0), db_uni_hex);
    
    SSEG_DEC: hex7seg port map(s_medida(7 downto 4), db_dec_hex);

    pwm <= s_pwm;
    closing_led <= s_closing_led;
    slider <= s_medida;
    saida_serial <= s_saida_serial;
    trigger <= s_trigger;
	 aberto <= s_lid_open;
	 cap_led <= s_cap_led;

    db_reset <= s_reset;
    db_acionar <= s_acionar;
    db_pwm <= s_pwm;

end architecture;