library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity modulo_medida is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        aberto       : in  std_logic;
        echo         : in  std_logic;
        saida_serial : out std_logic;
        trigger      : out std_logic;
        db_estado    : out std_logic
    );
end entity;

architecture modulo_medida_arch of modulo_medida is

    component modulo_medida_fd
        port (
            clock        : in  std_logic;
            reset        : in  std_logic;
            echo         : in  std_logic;
            aberto       : in  std_logic;
            medir        : in  std_logic;
            transmitir   : in  std_logic;
            saida_serial : out std_logic;
            pronto       : out std_logic;
            trigger      : out std_logic
        );
    end component;

    component modulo_medida_uc
        port (
            clock      : in  std_logic;
            reset      : in  std_logic;
            tx_pronto  : in  std_logic;
            medir      : out std_logic;
            transmitir : out std_logic;
            estado_hex : out std_logic_vector (3 downto 0)
        );
    end component;

    signal s_reset, s_aberto, s_echo, s_saida_serial, s_trigger, s_abrir : std_logic;
    signal s_transmitir, s_pronto, s_medir : std_logic;
	signal s_db_estado : std_logic_vector (3 downto 0);

begin

    s_reset <= reset;
    s_aberto <= aberto;
    s_echo <= echo;

    FD: modulo_medida_fd port map (clock, s_reset, s_echo, s_aberto, s_medir, s_transmitir, 
                                    s_saida_serial, s_pronto, s_trigger); 
    
    UC: modulo_medida_uc port map (clock, s_reset, s_pronto, s_medir, s_transmitir, s_db_estado);

    saida_serial <= s_saida_serial;
    trigger <= s_trigger;
    db_estado <= s_db_estado;


end architecture;