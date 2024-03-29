library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity modulo_medida_fd is
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
          receber : in std_logic;
			 estado_tx : out std_logic_vector(3 downto 0)
    );
end entity;

architecture modulo_medida_fd_arch of modulo_medida_fd is
     
    component sensor is
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
            db_trigger  : out std_logic;
				pronto_rx   : in  std_logic
        );
    end component;

    component tx_dados_sensor is
        port (
            clock: in std_logic;
            reset: in std_logic;
            transmitir: in std_logic;
            distancia2: in std_logic_vector(3 downto 0);
            distancia1: in std_logic_vector(3 downto 0);
            distancia0: in std_logic_vector(3 downto 0);
            saida_serial: out std_logic;
            pronto: out std_logic;
            cap_led: out std_logic_vector(1 downto 0);
            db_dado_tx: out std_logic_vector (7 downto 0);
            db_estado_tx_dados_sensor, db_estado_tx: out std_logic_vector (3 downto 0);
            entrada_serial : in std_logic;
            pronto_rx : out std_logic;
            receber : in std_logic;
				aberto : in std_logic
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
    
    signal s_distancia2, s_distancia1, s_distancia0 : std_logic_vector (3 downto 0);
    signal s_reset, s_transmite, s_fim, s_proximo, s_saida_serial, s_medir, s_reset_sensor, s_receber : std_logic;
    signal s_echo, s_aberto, s_transmitir, s_trigger, s_pronto, s_contar, s_timer_end, s_entrada_serial, s_pronto_rx : std_logic;
    signal s_posicao, s_cap_led : std_logic_vector (1 downto 0);
    signal s_mux_out : std_logic_vector (7 downto 0);
	 signal s_dado_tx: std_logic_vector (7 downto 0);
    signal s_estado_tx : std_logic_vector (3 downto 0);
    signal s_porcentagem : std_logic_vector (11 downto 0);

begin

    s_reset <= reset;
    s_echo <= echo;
    s_aberto <= aberto;
    s_transmitir <= transmitir;
    s_medir <= medir;
    s_contar <= contar;
	 s_reset_sensor <= reset_sensor;
     s_entrada_serial <= entrada_serial;
     s_receber <= receber;

    SENS: sensor port map (clock, s_reset_sensor, s_medir, s_echo, s_aberto, s_trigger, s_distancia0,
                             s_distancia1, s_distancia2, open, open, open, open, open, open, open, s_pronto_rx); 

    TX: tx_dados_sensor port map (clock, s_reset, s_transmitir, s_distancia2, s_distancia1,
                                  s_distancia0, s_saida_serial, s_pronto, s_cap_led, open, S_estado_tx, open, s_entrada_serial, s_pronto_rx, s_receber, s_aberto);

    ONE_SEC: contadorg_m generic map (M => 50000000) port map (clock, s_reset, '0', s_contar, open, s_timer_end, open);

    saida_serial <= s_saida_serial;
    pronto <= s_pronto;
    trigger <= s_trigger;
    timer_end <= s_timer_end;
	 cap_led <= s_cap_led;
     pronto_rx <= s_pronto_rx;
	  estado_tx <= s_estado_tx;
    
end architecture;