library ieee;
use ieee.std_logic_1164.all;

entity sensor is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        ligar       : in  std_logic;
        echo        : in  std_logic;
        aberto      : in  std_logic;
        trigger     : out std_logic;
        unidade     : out std_logic_vector(3 downto 0);
        dezena      : out std_logic_vector(3 downto 0);
        centena     : out std_logic_vector(3 downto 0);
        db_estado   : out std_logic_vector(6 downto 0);
        db_uni_hex  : out std_logic_vector(6 downto 0);
        db_dec_hex  : out std_logic_vector(6 downto 0);
        db_cent_hex : out std_logic_vector(6 downto 0);
        db_reset    : out std_logic;
        db_ligar    : out std_logic;
        db_trigger  : out std_logic
    );
end entity;

architecture sensor_arch of sensor is

    component sensor_uc port(
        clock         : in  std_logic;
        reset         : in  std_logic;
        ligar         : in  std_logic;
        aberto        : in  std_logic;
        medida_pronto : in  std_logic;
        mede          : out std_logic;
        estado_hex    : out std_logic_vector(3 downto 0)
    );
    end component;

    component sensor_fd port(
        clock       : in  std_logic;
        reset       : in  std_logic;
        mede        : in  std_logic;
        echo        : in  std_logic;
        pronto      : out std_logic;
        trigger     : out std_logic;
        medida      : out std_logic_vector(11 downto 0)
    );
    end component;

    component hex7seg is port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
    end component;

    signal s_reset, s_ligar, s_mede, s_aberto, s_echo, s_pronto, s_trigger : std_logic;
    signal s_medida : std_logic_vector(11 downto 0);
    signal s_estado : std_logic_vector(3 downto 0);

begin

    s_reset <= reset;
    s_ligar <= ligar;
    s_aberto <= aberto;
    s_echo <= echo;

    UC: sensor_uc port map(clock, s_reset, s_ligar, s_aberto, s_pronto, s_mede, s_estado);

    FD: sensor_fd port map(clock, s_reset, s_mede, s_echo, s_pronto, s_trigger, s_medida);

    SSEG_UC: hex7seg port map(s_estado, db_estado);

    SSEG_UNI: hex7seg port map(s_medida(3 downto 0), db_uni_hex);
    
    SSEG_DEC: hex7seg port map(s_medida(7 downto 4), db_dec_hex);

    SSEG_CENT: hex7seg port map(s_medida(11 downto 8), db_cent_hex);

    trigger <= s_trigger;
    unidade <= s_medida(3 downto 0);
    dezena <= s_medida(7 downto 4);
    centena <= s_medida(11 downto 8);

    db_reset <= reset;
    db_ligar <= ligar;
    db_trigger <= s_trigger;

end architecture;