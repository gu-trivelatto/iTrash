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
		  cap_led      : out std_logic_vector(1 downto 0);
        db_estado    : out std_logic_vector(3 downto 0);
        entrada_serial : in std_logic
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
            contar       : in  std_logic;
            reset_sensor : in  std_logic;
            saida_serial : out std_logic;
            pronto       : out std_logic;
            timer_end    : out std_logic;
            cap_led      : out std_logic_vector(1 downto 0);
            trigger      : out std_logic;
            entrada_serial : in std_logic;
            pronto_rx : out std_logic;
            receber : in std_logic
        );
    end component;

    component modulo_medida_uc
        port (
            clock        : in  std_logic;
			  reset        : in  std_logic;
			  tx_pronto    : in  std_logic;
			  timer_end    : in  std_logic;
			  medir        : out std_logic;
			  transmitir   : out std_logic;
			  contar       : out std_logic;
			  reset_sensor : out std_logic;
			  estado_hex   : out std_logic_vector (3 downto 0);
            pronto_rx : in std_logic;
            receber : out std_logic
        );
    end component;

    signal s_reset, s_aberto, s_echo, s_saida_serial, s_trigger, s_abrir, s_entrada_serial, s_pronto_rx, s_recebe_dado : std_logic;
    signal s_transmitir, s_pronto, s_medir, s_timer_end, s_contar, s_reset_sensor : std_logic;
	signal s_db_estado : std_logic_vector (3 downto 0);
	signal s_cap_led : std_logic_vector (1 downto 0);

begin

    s_reset <= reset;
    s_aberto <= aberto;
    s_echo <= echo;
    s_entrada_serial <= entrada_serial;

    FD: modulo_medida_fd port map (clock, s_reset, s_echo, s_aberto, s_medir, s_transmitir, 
                                    s_contar, s_reset_sensor, s_saida_serial, s_pronto, s_timer_end, s_cap_led, s_trigger, s_entrada_serial, s_pronto_rx, s_recebe_dado); 
    
    UC: modulo_medida_uc port map (clock, s_reset, s_pronto, s_timer_end, s_medir, s_transmitir, s_contar, s_reset_sensor, s_db_estado, s_pronto_rx, s_recebe_dado);

    saida_serial <= s_saida_serial;
    trigger <= s_trigger;
    db_estado <= s_db_estado;
	 cap_led <= s_cap_led;


end architecture;